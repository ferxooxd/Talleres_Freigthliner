import inspect

import pytest

from app.core.Enum import UserRole
from app.models.ServiceOrderEntity import ServiceOrderState
from app.models.TechnicalReportEntity import TechnicalReport
from app.models.VehicleUserEntity import VehicleUser
from app.schemas.ServiceOrderSchema import ServiceOrderUpdate
from app.services.NotificationService import NotificationService, NotificationType
from app.services.ServiceOrderService import ServiceOrderService
from tests.conftest import auth_header, create_user
from tests.test_order_assignment_notifications import create_service_order, create_vehicle


class FakeBackgroundTasks:
    def __init__(self):
        self.tasks = []

    def add_task(self, func, *args, **kwargs):
        self.tasks.append((func, args, kwargs))


async def run_background_task(task):
    func, args, kwargs = task
    result = func(*args, **kwargs)
    if inspect.isawaitable(result):
        await result


def link_vehicle_owner(db, *, user_id: int, vehicle_id: int):
    link = VehicleUser(
        id_usuario=user_id,
        id_vehiculo=vehicle_id,
        rol_vehiculo="Propietario",
    )
    db.add(link)
    db.commit()
    db.refresh(link)
    return link


def create_technical_report(db, *, order_id: int, mechanic_id: int):
    report = TechnicalReport(
        id_usuario=mechanic_id,
        id_orden=order_id,
        diagnostico="Revision completada",
        recomendaciones="Listo para entrega",
        estado_revision="PENDIENTE",
    )
    db.add(report)
    db.commit()
    db.refresh(report)
    return report


def test_ready_state_notifies_order_vehicle_owner(db, monkeypatch):
    client_user = create_user(db, 1, UserRole.client, "client")
    mechanic = create_user(db, 2, UserRole.mechanic, "mechanic")
    vehicle = create_vehicle(db)
    link_vehicle_owner(
        db,
        user_id=client_user.id_usuario,
        vehicle_id=vehicle.id_vehiculo,
    )
    order = create_service_order(db, vehicle=vehicle, mechanic_id=mechanic.id_usuario)
    create_technical_report(db, order_id=order.id_orden, mechanic_id=mechanic.id_usuario)
    calls = []

    def fake_notify(**kwargs):
        calls.append(kwargs)

    monkeypatch.setattr(NotificationService, "notify", fake_notify)

    updated_order = ServiceOrderService.update_order(
        db,
        order.id_orden,
        ServiceOrderUpdate(estado_orden=ServiceOrderState.LISTO_PARA_ENTREGA),
    )

    assert updated_order.estado_orden == ServiceOrderState.LISTO_PARA_ENTREGA
    assert len(calls) == 1
    assert calls[0]["user_ids"] == [client_user.id_usuario]
    assert calls[0]["type"] == NotificationType.order_ready
    assert calls[0]["data"] == {
        "type": "order_ready",
        "order_id": str(order.id_orden),
    }


def test_non_ready_state_does_not_trigger_ready_notification(db, monkeypatch):
    client_user = create_user(db, 1, UserRole.client, "client")
    vehicle = create_vehicle(db)
    link_vehicle_owner(
        db,
        user_id=client_user.id_usuario,
        vehicle_id=vehicle.id_vehiculo,
    )
    order = create_service_order(db, vehicle=vehicle)
    calls = []

    def fake_notify(**kwargs):
        calls.append(kwargs)

    monkeypatch.setattr(NotificationService, "notify", fake_notify)

    updated_order = ServiceOrderService.update_order(
        db,
        order.id_orden,
        ServiceOrderUpdate(estado_orden=ServiceOrderState.EN_REPARACION),
    )

    assert updated_order.estado_orden == ServiceOrderState.EN_REPARACION
    assert calls == []


def test_client_cannot_update_order_or_trigger_ready_notification(
    client,
    db,
    monkeypatch,
):
    client_user = create_user(db, 1, UserRole.client, "client")
    mechanic = create_user(db, 2, UserRole.mechanic, "mechanic")
    vehicle = create_vehicle(db)
    link_vehicle_owner(
        db,
        user_id=client_user.id_usuario,
        vehicle_id=vehicle.id_vehiculo,
    )
    order = create_service_order(db, vehicle=vehicle, mechanic_id=mechanic.id_usuario)
    create_technical_report(db, order_id=order.id_orden, mechanic_id=mechanic.id_usuario)
    calls = []

    def fake_notify(**kwargs):
        calls.append(kwargs)

    monkeypatch.setattr(NotificationService, "notify", fake_notify)

    response = client.patch(
        f"/api/v1/service-orders/{order.id_orden}",
        json={"estado_orden": ServiceOrderState.LISTO_PARA_ENTREGA.value},
        headers=auth_header(client_user),
    )

    db.refresh(order)
    assert response.status_code == 403
    assert order.estado_orden == ServiceOrderState.EN_DIAGNOSTICO
    assert calls == []


@pytest.mark.asyncio
async def test_ready_state_with_owner_without_tokens_does_not_break_update(db):
    client_user = create_user(db, 1, UserRole.client, "client")
    mechanic = create_user(db, 2, UserRole.mechanic, "mechanic")
    vehicle = create_vehicle(db)
    link_vehicle_owner(
        db,
        user_id=client_user.id_usuario,
        vehicle_id=vehicle.id_vehiculo,
    )
    order = create_service_order(db, vehicle=vehicle, mechanic_id=mechanic.id_usuario)
    create_technical_report(db, order_id=order.id_orden, mechanic_id=mechanic.id_usuario)
    background_tasks = FakeBackgroundTasks()

    updated_order = ServiceOrderService.update_order(
        db,
        order.id_orden,
        ServiceOrderUpdate(estado_orden=ServiceOrderState.LISTO_PARA_ENTREGA),
        background_tasks=background_tasks,
    )

    assert updated_order.estado_orden == ServiceOrderState.LISTO_PARA_ENTREGA
    assert len(background_tasks.tasks) == 1
    await run_background_task(background_tasks.tasks[0])

import pytest

from fastapi import HTTPException

from app.core.Enum import UserRole
from app.schemas.TechnicalReportSchema import TechnicalReportRegister
from app.services.NotificationService import NotificationService, NotificationType
from app.services.TechnicalReportService import TechnicalReportService
from tests.conftest import create_user
from tests.test_order_assignment_notifications import create_service_order, create_vehicle


def report_payload(*, order_id: int) -> TechnicalReportRegister:
    return TechnicalReportRegister(
        id_orden=order_id,
        diagnostico="Falla corregida",
        recomendaciones="Validar en ruta",
        repuestos_usados="Filtro",
    )


def test_mechanic_submit_report_notifies_admins_with_context(db, monkeypatch):
    admin = create_user(db, 1, UserRole.admin, "admin")
    second_admin = create_user(db, 4, UserRole.admin, "admin-dos")
    mechanic = create_user(db, 2, UserRole.mechanic, "mechanic")
    vehicle = create_vehicle(db)
    order = create_service_order(db, vehicle=vehicle, mechanic_id=mechanic.id_usuario)
    background_tasks = object()
    calls = []

    def fake_notify(**kwargs):
        calls.append(kwargs)

    monkeypatch.setattr(NotificationService, "notify", fake_notify)

    report = TechnicalReportService.create_report(
        db,
        report_payload(order_id=order.id_orden),
        mechanic.id_usuario,
        background_tasks=background_tasks,
    )

    assert report.id_informe_tecnico is not None
    assert len(calls) == 1
    assert calls[0]["user_ids"] == [admin.id_usuario, second_admin.id_usuario]
    assert calls[0]["type"] == NotificationType.technical_report_submitted
    assert calls[0]["title"] == "Reporte tecnico finalizado"
    assert "Mechanic User" in calls[0]["body"]
    assert order.numero_orden in calls[0]["body"]
    assert "ABC001" in calls[0]["body"]
    assert calls[0]["data"] == {
        "type": "technical_report_submitted",
        "report_id": str(report.id_informe_tecnico),
        "order_id": str(order.id_orden),
    }
    assert calls[0]["background_tasks"] is background_tasks


def test_mechanic_submit_report_without_admins_does_not_break_flow(db, monkeypatch):
    mechanic = create_user(db, 2, UserRole.mechanic, "mechanic")
    vehicle = create_vehicle(db)
    order = create_service_order(db, vehicle=vehicle, mechanic_id=mechanic.id_usuario)
    calls = []

    monkeypatch.setattr(NotificationService, "notify", lambda **kwargs: calls.append(kwargs))

    report = TechnicalReportService.create_report(
        db,
        report_payload(order_id=order.id_orden),
        mechanic.id_usuario,
    )

    assert report.id_informe_tecnico is not None
    assert calls == []


def test_non_mechanic_cannot_submit_report_or_trigger_notification(db, monkeypatch):
    client = create_user(db, 1, UserRole.client, "client")
    vehicle = create_vehicle(db)
    order = create_service_order(db, vehicle=vehicle)
    calls = []

    monkeypatch.setattr(NotificationService, "notify", lambda **kwargs: calls.append(kwargs))

    with pytest.raises(HTTPException) as exc_info:
        TechnicalReportService.create_report(
            db,
            report_payload(order_id=order.id_orden),
            client.id_usuario,
        )

    assert exc_info.value.status_code == 403
    assert calls == []


def test_mechanic_cannot_submit_report_for_unassigned_order(db, monkeypatch):
    assigned_mechanic = create_user(db, 1, UserRole.mechanic, "assigned")
    other_mechanic = create_user(db, 2, UserRole.mechanic, "other")
    vehicle = create_vehicle(db)
    order = create_service_order(
        db,
        vehicle=vehicle,
        mechanic_id=assigned_mechanic.id_usuario,
    )
    calls = []

    monkeypatch.setattr(NotificationService, "notify", lambda **kwargs: calls.append(kwargs))

    with pytest.raises(HTTPException) as exc_info:
        TechnicalReportService.create_report(
            db,
            report_payload(order_id=order.id_orden),
            other_mechanic.id_usuario,
        )

    assert exc_info.value.status_code == 403
    assert calls == []

from datetime import date, time

from app.core.Enum import UserRole
from app.models.VehicleEntity import TipoVehiculoEnum, Vehicle
from app.schemas.BookingSchema import BookingCreate
from app.services.BookingService import BookingService
from app.services.NotificationService import NotificationService, NotificationType
from tests.conftest import create_user


def create_vehicle(db, vehicle_id: int = 1) -> Vehicle:
    vehicle = Vehicle(
        id_vehiculo=vehicle_id,
        placa=f"ABC{vehicle_id:03d}",
        marca="Freightliner",
        modelo="Cascadia",
        tipo_vehiculo=TipoVehiculoEnum.camion,
    )
    db.add(vehicle)
    db.commit()
    db.refresh(vehicle)
    return vehicle


def booking_payload(*, user_id: int, vehicle_id: int) -> BookingCreate:
    return BookingCreate(
        id_usuario=user_id,
        id_vehiculo=vehicle_id,
        fecha_solicitud=date(2026, 7, 20),
        fecha_cita=date(2026, 7, 22),
        hora_cita=time(14, 30),
        observaciones="Revision general",
    )


def test_create_booking_notifies_admins_with_context(db, monkeypatch):
    admin = create_user(db, 1, UserRole.admin, "admin")
    second_admin = create_user(db, 4, UserRole.admin, "admin-dos")
    client = create_user(db, 2, UserRole.client, "cliente")
    vehicle = create_vehicle(db)
    background_tasks = object()
    calls = []

    def fake_notify(**kwargs):
        calls.append(kwargs)

    monkeypatch.setattr(NotificationService, "notify", fake_notify)

    booking = BookingService.create_booking(
        db,
        booking_payload(user_id=client.id_usuario, vehicle_id=vehicle.id_vehiculo),
        background_tasks=background_tasks,
    )

    assert booking.id_agendamiento is not None
    assert len(calls) == 1
    assert calls[0]["user_ids"] == [admin.id_usuario, second_admin.id_usuario]
    assert calls[0]["type"] == NotificationType.booking_created
    assert calls[0]["title"] == "Nueva cita agendada"
    assert "Cliente User" in calls[0]["body"]
    assert "ABC001" in calls[0]["body"]
    assert "2026-07-22" in calls[0]["body"]
    assert "14:30" in calls[0]["body"]
    assert calls[0]["data"] == {
        "type": "booking_created",
        "booking_id": str(booking.id_agendamiento),
        "booking_date": "2026-07-22",
    }
    assert calls[0]["background_tasks"] is background_tasks


def test_create_booking_without_admins_does_not_break_flow(db, monkeypatch):
    client = create_user(db, 2, UserRole.client, "cliente")
    vehicle = create_vehicle(db)
    calls = []

    def fake_notify(**kwargs):
        calls.append(kwargs)

    monkeypatch.setattr(NotificationService, "notify", fake_notify)

    booking = BookingService.create_booking(
        db,
        booking_payload(user_id=client.id_usuario, vehicle_id=vehicle.id_vehiculo),
    )

    assert booking.id_agendamiento is not None
    assert calls == []

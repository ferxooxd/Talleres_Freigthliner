from datetime import datetime, timezone

from app.core.Enum import UserRole
from app.models.MessageEntity import Message
from tests.conftest import auth_header, create_user


def add_message(db, *, sender_id: int, receiver_id: int, timestamp: datetime):
    message = Message(
        sender_id=sender_id,
        receiver_id=receiver_id,
        content="Mensaje de prueba",
        timestamp=timestamp,
    )
    db.add(message)
    db.commit()
    db.refresh(message)
    return message


def test_admin_chat_contacts_are_sorted_by_latest_message(client, db):
    admin = create_user(db, 1, UserRole.admin, "admin")
    client_user = create_user(db, 2, UserRole.client, "cliente")
    mechanic = create_user(db, 3, UserRole.mechanic, "tecnico")
    secretary = create_user(db, 4, UserRole.secretary, "secretario")

    add_message(
        db,
        sender_id=client_user.id_usuario,
        receiver_id=admin.id_usuario,
        timestamp=datetime(2026, 7, 17, 9, 0, tzinfo=timezone.utc),
    )
    add_message(
        db,
        sender_id=admin.id_usuario,
        receiver_id=mechanic.id_usuario,
        timestamp=datetime(2026, 7, 17, 10, 30, tzinfo=timezone.utc),
    )

    response = client.get(
        "/api/v1/chat/contacts",
        headers=auth_header(admin),
    )

    assert response.status_code == 200
    data = response.json()
    assert [item["id_usuario"] for item in data] == [
        mechanic.id_usuario,
        client_user.id_usuario,
        secretary.id_usuario,
    ]
    assert data[0]["last_message_at"] is not None
    assert data[1]["last_message_at"] is not None
    assert data[2]["last_message_at"] is None


def test_admin_chat_contacts_require_admin_role(client, db):
    client_user = create_user(db, 2, UserRole.client, "cliente")

    response = client.get(
        "/api/v1/chat/contacts",
        headers=auth_header(client_user),
    )

    assert response.status_code == 403

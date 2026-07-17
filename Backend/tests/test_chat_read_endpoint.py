import pytest

from app.api.v1.endpoints import ChatEndpoint
from app.core.Enum import UserRole
from app.models.MessageEntity import Message
from tests.conftest import auth_header, create_message, create_user


class SpyConnectionManager:
    def __init__(self):
        self.sent = []

    async def send_personal_json(self, data: dict, user_id: int) -> bool:
        self.sent.append((user_id, data))
        return True


@pytest.fixture()
def spy_manager(monkeypatch):
    spy = SpyConnectionManager()
    monkeypatch.setattr(ChatEndpoint, "manager", spy)
    return spy


def test_receiver_marks_message_as_read(client, db, spy_manager):
    sender = create_user(db, 1, UserRole.admin, "admin")
    receiver = create_user(db, 2, UserRole.client, "client")
    message = create_message(db, sender, receiver)

    response = client.patch(
        f"/api/v1/chat/messages/{message.id}/read",
        headers=auth_header(receiver),
    )

    assert response.status_code == 200
    payload = response.json()
    assert payload["id"] == message.id
    assert payload["is_read"] is True
    assert payload["read_at"] is not None

    db.expire_all()
    stored = db.get(Message, message.id)
    assert stored.is_read is True
    assert stored.read_at is not None
    assert spy_manager.sent == [
        (
            sender.id_usuario,
            {
                "type": "message_read",
                "message_id": message.id,
                "reader_id": receiver.id_usuario,
                "read_at": stored.read_at.isoformat(),
            },
        )
    ]


def test_non_receiver_cannot_mark_message_as_read(client, db, spy_manager):
    sender = create_user(db, 1, UserRole.admin, "admin")
    receiver = create_user(db, 2, UserRole.client, "client")
    stranger = create_user(db, 3, UserRole.client, "stranger")
    message = create_message(db, sender, receiver)

    response = client.patch(
        f"/api/v1/chat/messages/{message.id}/read",
        headers=auth_header(stranger),
    )

    assert response.status_code == 403
    db.expire_all()
    stored = db.get(Message, message.id)
    assert stored.is_read is False
    assert stored.read_at is None
    assert spy_manager.sent == []


def test_mark_read_is_idempotent_and_does_not_duplicate_events(
    client,
    db,
    spy_manager,
):
    sender = create_user(db, 1, UserRole.admin, "admin")
    receiver = create_user(db, 2, UserRole.client, "client")
    message = create_message(db, sender, receiver)

    first = client.patch(
        f"/api/v1/chat/messages/{message.id}/read",
        headers=auth_header(receiver),
    )
    second = client.patch(
        f"/api/v1/chat/messages/{message.id}/read",
        headers=auth_header(receiver),
    )

    assert first.status_code == 200
    assert second.status_code == 200
    db.expire_all()
    stored = db.get(Message, message.id)
    assert stored.is_read is True
    assert stored.read_at is not None
    assert len(spy_manager.sent) == 1

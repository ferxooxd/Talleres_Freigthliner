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


def test_unread_counts_are_grouped_for_current_receiver(client, db):
    admin = create_user(db, 1, UserRole.admin, "admin")
    client_user = create_user(db, 2, UserRole.client, "client")
    mechanic = create_user(db, 3, UserRole.mechanic, "mechanic")

    create_message(db, admin, client_user, "unread 1")
    create_message(db, admin, client_user, "unread 2")
    read_message = create_message(db, admin, client_user, "read")
    read_message.is_read = True
    create_message(db, mechanic, client_user, "mechanic unread")
    create_message(db, client_user, admin, "outbound")
    db.commit()

    response = client.get(
        "/api/v1/chat/unread-counts",
        headers=auth_header(client_user),
    )

    assert response.status_code == 200
    payload = response.json()
    assert payload["total"] == 3
    assert {
        item["contact_id"]: item["unread_count"]
        for item in payload["counts"]
    } == {
        admin.id_usuario: 2,
        mechanic.id_usuario: 1,
    }


def test_bulk_mark_conversation_read_is_idempotent_and_notifies_senders(
    client,
    db,
    spy_manager,
):
    sender = create_user(db, 1, UserRole.admin, "admin")
    receiver = create_user(db, 2, UserRole.client, "client")
    other = create_user(db, 3, UserRole.mechanic, "mechanic")
    first = create_message(db, sender, receiver, "first")
    second = create_message(db, sender, receiver, "second")
    create_message(db, other, receiver, "other unread")
    create_message(db, receiver, sender, "outbound")

    first_response = client.patch(
        f"/api/v1/chat/conversations/{sender.id_usuario}/read",
        headers=auth_header(receiver),
    )
    second_response = client.patch(
        f"/api/v1/chat/conversations/{sender.id_usuario}/read",
        headers=auth_header(receiver),
    )

    assert first_response.status_code == 200
    assert second_response.status_code == 200
    assert first_response.json()["updated_count"] == 2
    assert set(first_response.json()["message_ids"]) == {first.id, second.id}
    assert second_response.json()["updated_count"] == 0
    assert second_response.json()["message_ids"] == []

    db.expire_all()
    stored_first = db.get(Message, first.id)
    stored_second = db.get(Message, second.id)
    assert stored_first.is_read is True
    assert stored_first.read_at is not None
    assert stored_second.is_read is True
    assert stored_second.read_at is not None
    assert len(spy_manager.sent) == 2
    assert {event[1]["message_id"] for event in spy_manager.sent} == {
        first.id,
        second.id,
    }
    assert all(event[0] == sender.id_usuario for event in spy_manager.sent)

from typing import Dict
from fastapi import WebSocket
import json

class ConnectionManager:
    def __init__(self):
        # Maps user_id to an active WebSocket connection
        self.active_connections: Dict[int, WebSocket] = {}

    async def connect(self, websocket: WebSocket, user_id: int):
        await websocket.accept()
        self.active_connections[user_id] = websocket

    def disconnect(self, user_id: int):
        if user_id in self.active_connections:
            del self.active_connections[user_id]

    async def send_personal_message(self, message: str, user_id: int) -> bool:
        """
        Sends a message to a specific user if they are connected.
        Returns True if sent, False if the user is not connected.
        """
        if user_id in self.active_connections:
            websocket = self.active_connections[user_id]
            try:
                await websocket.send_text(message)
                return True
            except Exception:
                self.disconnect(user_id)
                return False
        return False

    async def send_personal_json(self, data: dict, user_id: int) -> bool:
        if user_id in self.active_connections:
            websocket = self.active_connections[user_id]
            try:
                await websocket.send_json(data)
                return True
            except Exception:
                self.disconnect(user_id)
                return False
        return False

# Global instance to be used across the app
manager = ConnectionManager()

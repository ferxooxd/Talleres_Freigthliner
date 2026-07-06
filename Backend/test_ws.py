import asyncio
import websockets
import json
import jwt
import sys
from app.core.config import settings

token = jwt.encode({'sub': '10', 'role': 'Administrador'}, settings.JWT_SECRET_KEY, algorithm=settings.JWT_ALGORITHM)

async def test():
    async with websockets.connect(f'ws://127.0.0.1:8000/api/v1/chat/ws?token={token}') as ws:
        await ws.send(json.dumps({'receiver_id': 9, 'content': 'Hello from python test'}))
        res = await ws.recv()
        print('Response:', res)

asyncio.run(test())

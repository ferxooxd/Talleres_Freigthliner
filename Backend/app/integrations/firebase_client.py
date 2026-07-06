import asyncio
import json
import firebase_admin
from firebase_admin import credentials, messaging
from app.core.config import settings
import logging

logger = logging.getLogger(__name__)

def get_firebase_app():
    if not firebase_admin._apps:
        if settings.FIREBASE_CREDENTIALS_JSON:
            try:
                cred_dict = json.loads(settings.FIREBASE_CREDENTIALS_JSON)
                cred = credentials.Certificate(cred_dict)
                firebase_admin.initialize_app(cred)
                logger.info("Firebase inicializado correctamente desde variable de entorno.")
            except Exception as e:
                logger.error(f"Error al inicializar Firebase: {e}")
        else:
            logger.warning("FIREBASE_CREDENTIALS_JSON no está definida en el entorno. Firebase no inicializado.")
    return firebase_admin.get_app() if firebase_admin._apps else None

# Initialize on import
get_firebase_app()


def _send_fcm_sync(user_id: int, message_content: str) -> bool:
    """
    Lógica síncrona de envío FCM. Se ejecuta en un thread pool
    para no bloquear el event loop de asyncio.
    """
    topic = f"user_{user_id}"
    message = messaging.Message(
        notification=messaging.Notification(
            title="Nuevo mensaje",
            body=message_content,
        ),
        topic=topic,
    )
    try:
        response = messaging.send(message)
        logger.info(f"Notificación enviada con éxito a {topic}: {response}")
        return True
    except Exception as e:
        logger.error(f"Error al enviar notificación a {topic}: {e}")
        return False


async def send_push_notification(user_id: int, message_content: str) -> bool:
    """
    Envía una notificación Push al usuario mediante Firebase Cloud Messaging (FCM).
    Usa asyncio.to_thread() para ejecutar la llamada síncrona del SDK de Firebase
    en un thread pool, evitando bloquear el event loop de uvicorn.
    """
    if not firebase_admin._apps:
        logger.warning("Intento de enviar notificación Push, pero Firebase no está inicializado.")
        return False

    return await asyncio.to_thread(_send_fcm_sync, user_id, message_content)

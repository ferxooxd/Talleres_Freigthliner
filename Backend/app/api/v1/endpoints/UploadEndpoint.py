from fastapi import APIRouter, Depends, UploadFile, File, HTTPException, status
from pydantic import BaseModel
import os
import uuid
import shutil

from app.api.deps import get_current_user
from app.models.UserEntity import User

router = APIRouter()

class UploadResponse(BaseModel):
    url: str

@router.post("/", response_model=UploadResponse, status_code=status.HTTP_201_CREATED)
def upload_image(
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user)
):
    """
    Sube una imagen al servidor y devuelve la URL para accederla.
    """
    if not file.content_type.startswith("image/"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="El archivo debe ser una imagen válida."
        )

    # Generar un nombre único para la imagen
    file_extension = os.path.splitext(file.filename)[1]
    if not file_extension:
        file_extension = ".jpg"  # fallback
    
    unique_filename = f"{uuid.uuid4()}{file_extension}"
    file_path = os.path.join("uploads", unique_filename)

    try:
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"No se pudo guardar la imagen: {str(e)}"
        )

    # La URL estática dependerá de dónde se está sirviendo el backend.
    # Usaremos una ruta relativa que el frontend pueda concatenar con el host.
    url = f"/static/uploads/{unique_filename}"
    return UploadResponse(url=url)

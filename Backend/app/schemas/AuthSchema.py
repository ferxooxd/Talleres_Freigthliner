from pydantic import BaseModel, EmailStr


class ClientRegister(BaseModel):
    nombre: str
    apellido: str
    telefono: str | None = None
    correo: EmailStr
    password: str


class LoginRequest(BaseModel):
    correo: EmailStr
    password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"

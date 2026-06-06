# app/Core/Exceptions.py

class UserAlreadyExistsError(Exception):
    """Excepción lanzada cuando se intenta registrar un usuario que ya existe."""
    pass


class InvalidCredentialsError(Exception):
    """Excepción lanzada cuando las credenciales de login son incorrectas."""
    pass

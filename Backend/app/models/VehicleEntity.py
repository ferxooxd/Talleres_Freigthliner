import enum
from sqlalchemy import Column, Integer, String, Enum as SQLEnum
from app.db.base import Base

class TipoVehiculoEnum(str, enum.Enum):
    camion = "Camion"
    volqueta = "Volqueta"
    patineta = "Patineta"
    mula = "Mula"
    bus = "Bus"
    otro = "Otro"

class Vehicle(Base):
    __tablename__ = "vehiculos" 

    id_vehiculo = Column(Integer, primary_key=True, index=True)
    placa = Column(String, unique=True, index=True, nullable=False)
    marca = Column(String, nullable=False)
    modelo = Column(String, nullable=False)
    
    tipo_vehiculo = Column(SQLEnum(TipoVehiculoEnum), nullable=False)


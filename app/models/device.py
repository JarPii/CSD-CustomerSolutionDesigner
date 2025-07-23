"""Device and Function models."""
from sqlalchemy import Column, Integer, String, Boolean, ForeignKey
from ..database import Base


class Device(Base):
    """Device model for storing device information."""
    __tablename__ = "device"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    manufacturer = Column(String)
    model = Column(String)
    type = Column(String)
    generic = Column(Boolean, nullable=False, default=False)


class Function(Base):
    """Function model for storing function information."""
    __tablename__ = "function"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    functional_description = Column(String)


class FunctionDevice(Base):
    """Association table between Function and Device."""
    __tablename__ = "function_device"
    
    function_id = Column(Integer, ForeignKey("function.id", ondelete="CASCADE"), primary_key=True)
    device_id = Column(Integer, ForeignKey("device.id", ondelete="CASCADE"), primary_key=True)

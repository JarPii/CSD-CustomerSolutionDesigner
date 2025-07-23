from sqlalchemy import Column, Integer, String, Text, TIMESTAMP, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.database import Base

class TankGroup(Base):
    __tablename__ = "tank_group"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False)
    number = Column(Integer, nullable=True)  # Tank group number for ordering/identification
    plant_id = Column(Integer, ForeignKey("plant.id", ondelete="CASCADE"), nullable=False)
    line_id = Column(Integer, ForeignKey("line.id", ondelete="CASCADE"), nullable=False)
    created_at = Column(TIMESTAMP, server_default=func.now(), nullable=False)
    updated_at = Column(TIMESTAMP, server_default=func.now(), onupdate=func.now(), nullable=False)
    
    # Relationships
    plant = relationship("Plant", back_populates="tank_groups")
    line = relationship("Line", back_populates="tank_groups")
    tanks = relationship("Tank", back_populates="tank_group", cascade="all, delete-orphan")

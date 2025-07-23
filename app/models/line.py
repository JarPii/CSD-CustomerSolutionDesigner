"""Line model for SQLAlchemy."""
from sqlalchemy import Column, Integer, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from ..database import Base


class Line(Base):
    """Line model representing production lines within plants."""
    
    __tablename__ = "line"
    
    id = Column(Integer, primary_key=True, index=True)
    plant_id = Column(Integer, ForeignKey("plant.id"), nullable=False)
    line_number = Column(Integer, nullable=False)
    min_x = Column(Integer, nullable=True)
    max_x = Column(Integer, nullable=True)
    min_y = Column(Integer, nullable=True)
    max_y = Column(Integer, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationship to plant
    plant = relationship("Plant", back_populates="lines")
    tank_groups = relationship("TankGroup", back_populates="line")

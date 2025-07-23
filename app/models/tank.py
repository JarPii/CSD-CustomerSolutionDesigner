from sqlalchemy import Column, Integer, String, TIMESTAMP, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.database import Base

class Tank(Base):
    __tablename__ = "tank"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False)
    number = Column(Integer, nullable=True)  # Tank number for ordering/identification within tank group
    tank_group_id = Column(Integer, ForeignKey("tank_group.id", ondelete="CASCADE"), nullable=True)
    plant_id = Column(Integer, ForeignKey("plant.id", ondelete="CASCADE"), nullable=False)
    width = Column(Integer, nullable=True)
    length = Column(Integer, nullable=True)
    depth = Column(Integer, nullable=True)
    x_position = Column(Integer, nullable=False, default=0, server_default="0")  # X coordinate of tank position
    y_position = Column(Integer, nullable=False, default=0, server_default="0")  # Y coordinate of tank position
    z_position = Column(Integer, nullable=False, default=0, server_default="0")  # Z coordinate of tank position
    space = Column(Integer, nullable=True)  # Spacing between tanks in millimeters
    created_at = Column(TIMESTAMP, server_default=func.now(), nullable=False)
    updated_at = Column(TIMESTAMP, server_default=func.now(), onupdate=func.now(), nullable=False)
    
    # Relationships
    tank_group = relationship("TankGroup", back_populates="tanks")
    plant = relationship("Plant", back_populates="tanks")

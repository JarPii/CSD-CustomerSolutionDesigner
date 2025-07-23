"""
Plant Database Model

SQLAlchemy model for plant table representing customer facilities/plants.
Each plant belongs to one customer, but a customer can have multiple plants.
Supports revision control system for configuration management.
"""
from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Boolean
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship

from app.models.customer import Base


class Plant(Base):
    """
    Plant model representing customer facilities/plants with revision control
    
    Relationships:
    - Belongs to one Customer (many-to-one)
    - Customer can have multiple Plants (one-to-many)
    - Supports revision hierarchy (self-referencing)
    """
    __tablename__ = "plant"
    
    # Primary key
    id = Column(Integer, primary_key=True, index=True)
    
    # Foreign key to customer
    customer_id = Column(Integer, ForeignKey("customer.id", ondelete="CASCADE"), nullable=False, index=True)
    
    # Plant information
    name = Column(String, nullable=False, index=True)
    town = Column(String, nullable=True)
    country = Column(String, nullable=True)
    
    # Revision control fields
    revision = Column(Integer, nullable=False, default=1, index=True)
    revision_name = Column(String(255), default='Initial Design')
    base_revision_id = Column(Integer, ForeignKey("plant.id", ondelete="SET NULL"), nullable=True)
    created_from_revision = Column(Integer, nullable=True)
    is_active_revision = Column(Boolean, default=True, index=True)
    revision_status = Column(String(20), default='DRAFT', index=True)
    created_by = Column(String(255), nullable=True)
    
    # Timestamps
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    customer = relationship("Customer", back_populates="plants")
    lines = relationship("Line", back_populates="plant")
    tank_groups = relationship("TankGroup", back_populates="plant")
    tanks = relationship("Tank", back_populates="plant")
    
    # Self-referencing relationship for revision hierarchy
    base_revision = relationship("Plant", remote_side=[id], backref="derived_revisions")
    
    def __repr__(self):
        return f"<Plant(id={self.id}, name='{self.name}', customer_id={self.customer_id}, revision={self.revision})>"
    
    def __str__(self):
        location = f" ({self.town}, {self.country})" if self.town else ""
        return f"{self.name}{location} (Rev {self.revision})"
    
    @property
    def is_draft(self):
        """Check if this revision is in draft status"""
        return self.revision_status == 'DRAFT'
    
    @property
    def is_active(self):
        """Check if this revision is active"""
        return self.revision_status == 'ACTIVE' and self.is_active_revision
    
    @property
    def is_archived(self):
        """Check if this revision is archived"""
        return self.revision_status == 'ARCHIVE'
        return f"{self.name}{location}"

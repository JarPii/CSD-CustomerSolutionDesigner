"""
Customer Database Model

SQLAlchemy model for customer table.
"""
from sqlalchemy import Column, Integer, String, DateTime
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship

from ..database import Base


class Customer(Base):
    """
    Customer model representing company customers
    
    Relationships:
    - Can have multiple Plants (one-to-many)
    """
    __tablename__ = "customer"
    
    # Primary key
    id = Column(Integer, primary_key=True, index=True)
    
    # Customer information
    name = Column(String, nullable=False, index=True)
    town = Column(String, nullable=True)
    country = Column(String, nullable=True)
    
    # Timestamps
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    plants = relationship("Plant", back_populates="customer", cascade="all, delete-orphan")
    
    def __repr__(self):
        return f"<Customer(id={self.id}, name='{self.name}')>"
    
    def __str__(self):
        location = f" ({self.town}, {self.country})" if self.town else ""
        return f"{self.name}{location}"

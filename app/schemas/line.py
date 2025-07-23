"""Pydantic schemas for Line model."""
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field


class LineBase(BaseModel):
    """Base schema for Line with common fields."""
    number: int = Field(..., description="Line number (e.g. 100, 200, 300)")
    min_x: Optional[int] = Field(None, description="Minimum X coordinate in millimeters")
    max_x: Optional[int] = Field(None, description="Maximum X coordinate in millimeters")
    min_y: Optional[int] = Field(None, description="Minimum Y coordinate in millimeters")
    max_y: Optional[int] = Field(None, description="Maximum Y coordinate in millimeters")


class LineCreate(LineBase):
    """Schema for creating a new line."""
    plant_id: int = Field(..., description="ID of the plant this line belongs to")
    count: int = Field(..., description="Kuinka monta tankkia luodaan")
    width: int = Field(..., description="Tankin leveys (mm)")
    length: int = Field(..., description="Tankin pituus (mm)")
    depth: int = Field(..., description="Tankin syvyys (mm)")
    gap: int = Field(..., description="Tankkien välinen väli (mm)")
    x_position: int = Field(..., description="Ensimmäisen tankin x-koordinaatti")
    y_position: int = Field(..., description="Tankin y-koordinaatti")
    z_position: int = Field(..., description="Tankin z-koordinaatti")


class LineUpdate(LineBase):
    """Schema for updating an existing line."""
    pass


class LineOut(LineBase):
    """Schema for line output with all fields."""
    id: int
    plant_id: int
    created_at: datetime
    updated_at: Optional[datetime] = None
    
    class Config:
        from_attributes = True

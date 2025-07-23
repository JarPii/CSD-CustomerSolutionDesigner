from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime

# Tank Schemas
class TankBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=255, description="Tank name")
    number: Optional[int] = Field(None, gt=0, description="Tank number for ordering/identification within tank group")
    tank_group_id: int = Field(..., gt=0, description="Tank group ID")
    plant_id: int = Field(..., gt=0, description="Plant ID")
    width: Optional[int] = Field(None, gt=0, description="Tank width")
    length: Optional[int] = Field(None, gt=0, description="Tank length")
    depth: Optional[int] = Field(None, gt=0, description="Tank depth")
    space: Optional[int] = Field(None, gt=0, description="Spacing between tanks in millimeters")

class TankCreate(TankBase):
    pass

class TankUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=255, description="Tank name")
    number: Optional[int] = Field(None, gt=0, description="Tank number for ordering/identification within tank group")
    tank_group_id: Optional[int] = Field(None, gt=0, description="Tank group ID")
    plant_id: Optional[int] = Field(None, gt=0, description="Plant ID")
    width: Optional[int] = Field(None, gt=0, description="Tank width")
    length: Optional[int] = Field(None, gt=0, description="Tank length")
    depth: Optional[int] = Field(None, gt=0, description="Tank depth")
    space: Optional[int] = Field(None, gt=0, description="Spacing between tanks in millimeters")

class TankResponse(TankBase):
    id: int
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True

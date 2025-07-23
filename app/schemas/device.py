"""Device and Function schemas."""
from pydantic import BaseModel
from typing import List, Optional


class DeviceCreate(BaseModel):
    """Schema for creating a new device."""
    name: str


class DeviceOut(BaseModel):
    """Schema for device output."""
    id: int
    name: str
    
    class Config:
        orm_mode = True


class FunctionCreate(BaseModel):
    """Schema for creating a new function."""
    name: str
    functional_description: Optional[str] = None
    device_ids: List[int] = []


class FunctionOut(BaseModel):
    """Schema for function output."""
    id: int
    name: str
    functional_description: Optional[str]
    device_ids: List[int] = []
    
    class Config:
        orm_mode = True

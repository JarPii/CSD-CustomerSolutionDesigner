from pydantic import BaseModel
from typing import Optional

class CustomerCreate(BaseModel):
    name: str
    town: Optional[str] = None
    country: Optional[str] = None

class CustomerUpdate(BaseModel):
    name: Optional[str] = None
    town: Optional[str] = None
    country: Optional[str] = None

class CustomerOut(BaseModel):
    id: int
    name: str
    town: Optional[str] = None
    country: Optional[str] = None
    
    class Config:
        from_attributes = True

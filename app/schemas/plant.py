"""
Plant Pydantic Schemas

Data validation and serialization schemas for Plant API endpoints.
Includes revision control support for plant configuration management.
"""
from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional, Literal


class PlantBase(BaseModel):
    """Base schema for Plant with common fields"""
    name: str = Field(..., min_length=1, max_length=200, description="Plant name")
    town: Optional[str] = Field(None, max_length=100, description="Plant location - town/city")
    country: Optional[str] = Field(None, max_length=100, description="Plant location - country")


class PlantCreate(PlantBase):
    """Schema for creating a new plant"""
    customer_id: int = Field(..., gt=0, description="Customer ID that owns this plant")
    revision_name: Optional[str] = Field("Initial Design", max_length=255, description="Revision name")
    created_by: Optional[str] = Field(None, max_length=255, description="User who created this revision")


class PlantUpdate(BaseModel):
    """Schema for updating plant information (only allowed fields in revision system)"""
    name: Optional[str] = Field(None, min_length=1, max_length=200, description="Plant name")
    town: Optional[str] = Field(None, max_length=100, description="Plant location - town/city")  
    country: Optional[str] = Field(None, max_length=100, description="Plant location - country")
    revision_name: Optional[str] = Field(None, max_length=255, description="Revision name")


class RevisionCreate(BaseModel):
    """Schema for creating a new revision"""
    revision_name: str = Field(..., min_length=1, max_length=255, description="New revision name")
    copy_from_revision_id: Optional[int] = Field(None, description="Source revision ID to copy from")
    created_by: Optional[str] = Field(None, max_length=255, description="User creating the revision")


class RevisionActivate(BaseModel):
    """Schema for activating a revision"""
    plant_id: int = Field(..., gt=0, description="Plant revision ID to activate")


class PlantOut(PlantBase):
    """Schema for plant output/response with revision information"""
    id: int
    customer_id: int
    revision: int
    revision_name: str
    base_revision_id: Optional[int] = None
    created_from_revision: Optional[int] = None
    is_active_revision: bool
    revision_status: Literal["DRAFT", "ACTIVE", "ARCHIVED"]
    created_by: Optional[str] = None
    created_at: datetime
    updated_at: Optional[datetime] = None
    
    class Config:
        from_attributes = True


class PlantWithCustomer(PlantOut):
    """Schema for plant with customer information included"""
    customer_name: str = Field(..., description="Name of the customer that owns this plant")
    
    class Config:
        from_attributes = True


class PlantRevisionSummary(BaseModel):
    """Schema for plant revision summary (for revision lists)"""
    id: int
    revision: int
    revision_name: str
    revision_status: Literal["DRAFT", "ACTIVE", "ARCHIVE"]
    is_active_revision: bool
    created_by: Optional[str] = None
    created_at: datetime
    tank_count: Optional[int] = None
    line_count: Optional[int] = None
    
    class Config:
        from_attributes = True

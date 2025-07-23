from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from app.database import get_db
from app.models.tank_group import TankGroup
from app.schemas.tank_group import TankGroupCreate, TankGroupUpdate, TankGroupResponse, TankGroupWithTanks

router = APIRouter(prefix="/tank-groups", tags=["tank-groups"])

@router.get("/", response_model=List[TankGroupResponse])
async def get_tank_groups(
    skip: int = Query(0, ge=0, description="Number of records to skip"),
    limit: int = Query(100, ge=1, le=1000, description="Maximum number of records to return"),
    plant_id: Optional[int] = Query(None, gt=0, description="Filter by plant ID"),
    line_id: Optional[int] = Query(None, gt=0, description="Filter by line ID"),
    search: Optional[str] = Query(None, description="Search by name"),
    db: Session = Depends(get_db)
):
    """Get all tank groups with optional filtering."""
    query = db.query(TankGroup)
    
    if plant_id:
        query = query.filter(TankGroup.plant_id == plant_id)
    
    if line_id:
        query = query.filter(TankGroup.line_id == line_id)
    
    if search:
        query = query.filter(TankGroup.name.ilike(f"%{search}%"))
    
    tank_groups = query.offset(skip).limit(limit).all()
    return tank_groups

@router.get("/{tank_group_id}", response_model=TankGroupWithTanks)
async def get_tank_group(tank_group_id: int, db: Session = Depends(get_db)):
    """Get a specific tank group with its tanks."""
    tank_group = db.query(TankGroup).filter(TankGroup.id == tank_group_id).first()
    if not tank_group:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Tank group with id {tank_group_id} not found"
        )
    return tank_group

@router.post("/", response_model=TankGroupResponse, status_code=status.HTTP_201_CREATED)
async def create_tank_group(tank_group: TankGroupCreate, db: Session = Depends(get_db)):
    """Create a new tank group."""
    # Check if number already exists for the same plant and line (if number is provided)
    if tank_group.number:
        existing = db.query(TankGroup).filter(
            TankGroup.number == tank_group.number,
            TankGroup.plant_id == tank_group.plant_id,
            TankGroup.line_id == tank_group.line_id
        ).first()
        
        if existing:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Tank group with number '{tank_group.number}' already exists for this plant and line"
            )
    
    db_tank_group = TankGroup(**tank_group.model_dump())
    db.add(db_tank_group)
    db.commit()
    db.refresh(db_tank_group)
    return db_tank_group

@router.put("/{tank_group_id}", response_model=TankGroupResponse)
async def update_tank_group(
    tank_group_id: int,
    tank_group: TankGroupUpdate,
    db: Session = Depends(get_db)
):
    """Update a tank group."""
    db_tank_group = db.query(TankGroup).filter(TankGroup.id == tank_group_id).first()
    if not db_tank_group:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Tank group with id {tank_group_id} not found"
        )
    
    # Check for number conflicts if number is being updated
    if tank_group.number and tank_group.number != db_tank_group.number:
        plant_id = tank_group.plant_id if tank_group.plant_id else db_tank_group.plant_id
        line_id = tank_group.line_id if tank_group.line_id else db_tank_group.line_id
        
        existing = db.query(TankGroup).filter(
            TankGroup.number == tank_group.number,
            TankGroup.plant_id == plant_id,
            TankGroup.line_id == line_id,
            TankGroup.id != tank_group_id
        ).first()
        
        if existing:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Tank group with number '{tank_group.number}' already exists for this plant and line"
            )
    
    # Update fields
    update_data = tank_group.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(db_tank_group, field, value)
    
    db.commit()
    db.refresh(db_tank_group)
    return db_tank_group

@router.delete("/{tank_group_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_tank_group(tank_group_id: int, db: Session = Depends(get_db)):
    """Delete a tank group."""
    db_tank_group = db.query(TankGroup).filter(TankGroup.id == tank_group_id).first()
    if not db_tank_group:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Tank group with id {tank_group_id} not found"
        )
    
    db.delete(db_tank_group)
    db.commit()

@router.get("/{tank_group_id}/can-delete", response_model=dict)
async def can_delete_tank_group(tank_group_id: int, db: Session = Depends(get_db)):
    """Check if a tank group can be deleted."""
    db_tank_group = db.query(TankGroup).filter(TankGroup.id == tank_group_id).first()
    if not db_tank_group:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Tank group with id {tank_group_id} not found"
        )
    
    tank_count = len(db_tank_group.tanks)
    can_delete = tank_count == 0
    
    return {
        "can_delete": can_delete,
        "reason": None if can_delete else f"Tank group has {tank_count} tanks"
    }

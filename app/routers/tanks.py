from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from app.database import get_db
from app.models.tank import Tank
from app.schemas.tank import TankCreate, TankUpdate, TankResponse

router = APIRouter(prefix="/tanks", tags=["tanks"])

@router.get("/", response_model=List[TankResponse])
async def get_tanks(
    skip: int = Query(0, ge=0, description="Number of records to skip"),
    limit: int = Query(100, ge=1, le=1000, description="Maximum number of records to return"),
    plant_id: Optional[int] = Query(None, gt=0, description="Filter by plant ID"),
    tank_group_id: Optional[int] = Query(None, gt=0, description="Filter by tank group ID"),
    search: Optional[str] = Query(None, description="Search by name"),
    db: Session = Depends(get_db)
):
    """Get all tanks with optional filtering."""
    query = db.query(Tank)
    
    if plant_id:
        query = query.filter(Tank.plant_id == plant_id)
    
    if tank_group_id:
        query = query.filter(Tank.tank_group_id == tank_group_id)
    
    if search:
        query = query.filter(Tank.name.ilike(f"%{search}%"))
    
    tanks = query.offset(skip).limit(limit).all()
    return tanks

@router.get("/{tank_id}", response_model=TankResponse)
async def get_tank(tank_id: int, db: Session = Depends(get_db)):
    """Get a specific tank."""
    tank = db.query(Tank).filter(Tank.id == tank_id).first()
    if not tank:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Tank with id {tank_id} not found"
        )
    return tank

@router.post("/", response_model=TankResponse, status_code=status.HTTP_201_CREATED)
async def create_tank(tank: TankCreate, db: Session = Depends(get_db)):
    """Create a new tank."""
    # Check if number already exists for the same tank group (if number is provided)
    if tank.number:
        existing = db.query(Tank).filter(
            Tank.number == tank.number,
            Tank.tank_group_id == tank.tank_group_id
        ).first()
        
        if existing:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Tank with number '{tank.number}' already exists in this tank group"
            )
    new_tank = Tank(
        name=tank.name,
        number=tank.number,
        tank_group_id=tank.tank_group_id,
        plant_id=tank.plant_id,
        width=tank.width,
        length=tank.length,
        depth=tank.depth,
        x_position=tank.x_position,
        y_position=tank.y_position,
        z_position=tank.z_position,
        space=tank.space
    )
    db.add(new_tank)
    db.commit()
    db.refresh(new_tank)
    return new_tank
    db.add(db_tank)
    db.commit()
    db.refresh(db_tank)
    return db_tank

@router.put("/{tank_id}", response_model=TankResponse)
async def update_tank(
    tank_id: int,
    tank: TankUpdate,
    db: Session = Depends(get_db)
):
    """Update a tank."""
    db_tank = db.query(Tank).filter(Tank.id == tank_id).first()
    if not db_tank:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Tank with id {tank_id} not found"
        )
    
    # Check for number conflicts if number is being updated
    if tank.number and tank.number != db_tank.number:
        tank_group_id = tank.tank_group_id if tank.tank_group_id else db_tank.tank_group_id
        
        existing = db.query(Tank).filter(
            Tank.number == tank.number,
            Tank.tank_group_id == tank_group_id,
            Tank.id != tank_id
        ).first()
        
        if existing:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Tank with number '{tank.number}' already exists in this tank group"
            )
    
    # Update fields
    update_data = tank.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(db_tank, field, value)
    
    db.commit()
    db.refresh(db_tank)
    return db_tank

@router.delete("/{tank_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_tank(tank_id: int, db: Session = Depends(get_db)):
    """Delete a tank."""
    db_tank = db.query(Tank).filter(Tank.id == tank_id).first()
    if not db_tank:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Tank with id {tank_id} not found"
        )
    
    db.delete(db_tank)
    db.commit()

@router.get("/{tank_id}/can-delete", response_model=dict)
async def can_delete_tank(tank_id: int, db: Session = Depends(get_db)):
    """Check if a tank can be deleted."""
    db_tank = db.query(Tank).filter(Tank.id == tank_id).first()
    if not db_tank:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Tank with id {tank_id} not found"
        )
    
    # Tanks can always be deleted (leaf nodes in hierarchy)
    return {
        "can_delete": True,
        "reason": None
    }

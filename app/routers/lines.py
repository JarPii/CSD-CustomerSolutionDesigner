
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy.sql import func
from typing import List
from typing import List as _List
from ..database import get_db
from ..models.line import Line
from ..models.tank import Tank
from ..schemas.line import LineCreate, LineUpdate, LineOut
from ..schemas.tank import TankResponse

router = APIRouter()

@router.get("/plants/{plant_id}/lines", response_model=List[LineOut])
def get_plant_lines(plant_id: int, db: Session = Depends(get_db)):
    """Get all lines for a specific plant."""
    lines = db.query(Line).filter(Line.plant_id == plant_id).order_by(Line.number).all()
    return lines

@router.get("/lines/{line_id}/tanks", response_model=_List[TankResponse])
def get_line_tanks(line_id: int, db: Session = Depends(get_db)):
    """Get all tanks for a specific line."""
    from ..models.tank_group import TankGroup
    from ..models.line import Line
    # Hae linjan tank_groupit
    tank_groups = db.query(TankGroup).filter(TankGroup.line_id == line_id).all()
    tank_group_ids = [tg.id for tg in tank_groups]
    # Hae linjan plant_id
    line = db.query(Line).filter(Line.id == line_id).first()
    if not line:
        return []
    # Palauta tankit, jotka kuuluvat linjan tank_groupiin TAI joilla ei ole tank_groupia mutta plant_id täsmää
    tanks = db.query(Tank).filter(
        (Tank.tank_group_id.in_(tank_group_ids)) |
        ((Tank.tank_group_id == None) & (Tank.plant_id == line.plant_id))
    ).order_by(Tank.number).all()
    return tanks
"""Line API endpoints."""


@router.post("/lines", response_model=LineOut)
def create_line(
    line: LineCreate,
    db: Session = Depends(get_db)
):
    """Create a new line."""
    # Validate line_number is multiple of 100
    if line.number <= 0 or line.number % 100 != 0:
        raise HTTPException(
            status_code=400, 
            detail="Line number must be a positive multiple of 100 (e.g., 100, 200, 300)"
        )
    
    # Check if line number already exists for this plant
    existing_line = db.query(Line).filter(
        Line.plant_id == line.plant_id,
        Line.number == line.number
    ).first()
    
    if existing_line:
        raise HTTPException(
            status_code=400,
            detail=f"Line {line.number} already exists for this plant"
        )
    
    new_line = Line(
        plant_id=line.plant_id,
        number=line.number,
        min_x=line.min_x,
        max_x=line.max_x,
        min_y=line.min_y,
        max_y=line.max_y
    )
    db.add(new_line)
    db.commit()
    db.refresh(new_line)

    # Do not create tank group or assign number to tank/tank_group
    x_pos = line.x_position
    for i in range(line.count):
        tank = Tank(
            name="no name",
            number=None,
            tank_group_id=None,
            plant_id=line.plant_id,
            width=line.width,
            length=line.length,
            depth=line.depth,
            x_position=x_pos,
            y_position=line.y_position,
            z_position=line.z_position,
            space=line.gap
        )
        db.add(tank)
        x_pos += line.width + line.gap
    db.commit()
    return new_line


@router.get("/lines/{line_id}", response_model=LineOut)
def get_line(
    line_id: int,
    db: Session = Depends(get_db)
):
    """Get a specific line by ID."""
    line = db.query(Line).filter(Line.id == line_id).first()
    if not line:
        raise HTTPException(status_code=404, detail="Line not found")
    return line


@router.put("/lines/{line_id}", response_model=LineOut)
def update_line(
    line_id: int,
    line_update: LineUpdate,
    db: Session = Depends(get_db)
):
    """Update an existing line."""
    line = db.query(Line).filter(Line.id == line_id).first()
    if not line:
        raise HTTPException(status_code=404, detail="Line not found")
    
    # Validate line_number is multiple of 100
    if line_update.number <= 0 or line_update.number % 100 != 0:
        raise HTTPException(
            status_code=400, 
            detail="Line number must be a positive multiple of 100 (e.g., 100, 200, 300)"
        )
    
    # Check if new line number conflicts with existing lines (excluding current line)
    if line_update.number != line.number:
        existing_line = db.query(Line).filter(
            Line.plant_id == line.plant_id,
            Line.number == line_update.number,
            Line.id != line_id
        ).first()
        
        if existing_line:
            raise HTTPException(
                status_code=400,
                detail=f"Line {line_update.number} already exists for this plant"
            )
    
    # Update fields
    line.number = line_update.number
    line.min_x = line_update.min_x
    line.max_x = line_update.max_x
    line.min_y = line_update.min_y
    line.max_y = line_update.max_y
    line.updated_at = func.now()
    
    db.commit()
    db.refresh(line)
    return line


@router.delete("/lines/{line_id}")
def delete_line(
    line_id: int,
    db: Session = Depends(get_db)
):
    """Delete a line."""
    line = db.query(Line).filter(Line.id == line_id).first()
    if not line:
        raise HTTPException(status_code=404, detail="Line not found")
    
    db.delete(line)
    db.commit()
    return {"message": f"Line {line.number} deleted successfully"}


@router.get("/plants/{plant_id}/lines/next-number")
def get_next_line_number(
    plant_id: int,
    db: Session = Depends(get_db)
):
    """Get the next available line number for a plant."""
    # Get all existing line numbers for this plant
    existing_numbers = db.query(Line.number).filter(Line.plant_id == plant_id).all()
    existing_numbers = [num[0] for num in existing_numbers]
    
    # Find next available number starting from 100
    next_number = 100
    while next_number in existing_numbers:
        next_number += 100
    
    return {"next_number": next_number}

"""Line API endpoints."""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy.sql import func
from typing import List

from ..database import get_db
from ..models.line import Line
from ..schemas.line import LineCreate, LineUpdate, LineOut

router = APIRouter()


@router.get("/plants/{plant_id}/lines", response_model=List[LineOut])
def get_plant_lines(
    plant_id: int,
    db: Session = Depends(get_db)
):
    """Get all lines for a specific plant."""
    lines = db.query(Line).filter(Line.plant_id == plant_id).order_by(Line.line_number).all()
    return lines


@router.post("/lines", response_model=LineOut)
def create_line(
    line: LineCreate,
    db: Session = Depends(get_db)
):
    """Create a new line."""
    # Validate line_number is multiple of 100
    if line.line_number <= 0 or line.line_number % 100 != 0:
        raise HTTPException(
            status_code=400, 
            detail="Line number must be a positive multiple of 100 (e.g., 100, 200, 300)"
        )
    
    # Check if line number already exists for this plant
    existing_line = db.query(Line).filter(
        Line.plant_id == line.plant_id,
        Line.line_number == line.line_number
    ).first()
    
    if existing_line:
        raise HTTPException(
            status_code=400,
            detail=f"Line {line.line_number} already exists for this plant"
        )
    
    new_line = Line(
        plant_id=line.plant_id,
        line_number=line.line_number,
        min_x=line.min_x,
        max_x=line.max_x,
        min_y=line.min_y,
        max_y=line.max_y
    )
    db.add(new_line)
    db.commit()
    db.refresh(new_line)
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
    if line_update.line_number <= 0 or line_update.line_number % 100 != 0:
        raise HTTPException(
            status_code=400, 
            detail="Line number must be a positive multiple of 100 (e.g., 100, 200, 300)"
        )
    
    # Check if new line number conflicts with existing lines (excluding current line)
    if line_update.line_number != line.line_number:
        existing_line = db.query(Line).filter(
            Line.plant_id == line.plant_id,
            Line.line_number == line_update.line_number,
            Line.id != line_id
        ).first()
        
        if existing_line:
            raise HTTPException(
                status_code=400,
                detail=f"Line {line_update.line_number} already exists for this plant"
            )
    
    # Update fields
    line.line_number = line_update.line_number
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
    return {"message": f"Line {line.line_number} deleted successfully"}


@router.get("/plants/{plant_id}/lines/next-number")
def get_next_line_number(
    plant_id: int,
    db: Session = Depends(get_db)
):
    """Get the next available line number for a plant."""
    # Get all existing line numbers for this plant
    existing_numbers = db.query(Line.line_number).filter(Line.plant_id == plant_id).all()
    existing_numbers = [num[0] for num in existing_numbers]
    
    # Find next available number starting from 100
    next_number = 100
    while next_number in existing_numbers:
        next_number += 100
    
    return {"next_line_number": next_number}

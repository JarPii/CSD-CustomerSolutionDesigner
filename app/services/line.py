"""Line service layer."""
from typing import List, Optional
from sqlalchemy.orm import Session
from ..models.line import Line
from ..models.tank import Tank, TankGroup
from ..schemas.line import LineCreate


class LineService:
    """Service layer for line operations."""
    
    def __init__(self, db: Session):
        self.db = db
    
    def get_lines_for_plant(self, plant_id: int) -> List[Line]:
        """Get all lines for a specific plant."""
        lines = self.db.query(Line).filter(Line.plant_id == plant_id).all()
        # Korjaa mahdolliset None-arvot min_y ja max_y
        for line in lines:
            if line.min_y is None:
                line.min_y = 0
            if line.max_y is None:
                line.max_y = 1000
        return lines
    
    def create_line(self, line_data: LineCreate) -> Line:
        """Create a new line with associated tank groups and tanks."""
        min_y = 0
        max_y = line_data.length if line_data.length is not None else 1000
        
        new_line = Line(
            plant_id=line_data.plant_id,
            line_number=line_data.line_number,
            min_x=line_data.min_x,
            max_x=line_data.max_x,
            min_y=min_y,
            max_y=max_y
        )
        self.db.add(new_line)
        self.db.commit()
        self.db.refresh(new_line)

        # Luo tank_groupit ja tankit
        tank_group_number = 101
        tank_number = 101
        
        for group_idx in range(line_data.tank_group_count):
            tank_group = TankGroup(
                group_name="Not named",
                line_id=new_line.id,
                tank_group_number=tank_group_number,
                plant_id=new_line.plant_id
            )
            self.db.add(tank_group)
            self.db.commit()
            self.db.refresh(tank_group)

            for tank_idx in range(line_data.tanks_per_group):
                tank = Tank(
                    tank_group_id=tank_group.id,
                    tank_name="Not named",
                    tank_number=tank_number,
                    width=line_data.tank_width,
                    length=line_data.tank_length,
                    depth=line_data.tank_depth,
                    plant_id=new_line.plant_id
                )
                self.db.add(tank)
                tank_number += 1
            tank_group_number += 1
        
        self.db.commit()
        return new_line
    
    def get_line(self, line_id: int) -> Optional[Line]:
        """Get a line by ID."""
        return self.db.query(Line).filter(Line.id == line_id).first()
    
    def delete_line(self, line_id: int) -> bool:
        """Delete a line by ID."""
        line = self.get_line(line_id)
        if line is None:
            return False
        self.db.delete(line)
        self.db.commit()
        return True

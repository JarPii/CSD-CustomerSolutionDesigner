"""Plant service layer."""
from typing import List, Optional
from sqlalchemy.orm import Session
from ..models.plant import Plant
from ..schemas.plant import PlantCreate


class PlantService:
    """Service layer for plant operations."""
    
    def __init__(self, db: Session):
        self.db = db
    
    def get_plants_for_customer(self, customer_id: int) -> List[Plant]:
        """Get all plants for a specific customer."""
        return self.db.query(Plant).filter(Plant.customer_id == customer_id).all()
    
    def get_all_plants(self) -> List[Plant]:
        """Get all plants."""
        return self.db.query(Plant).all()
    
    def create_plant(self, plant_data: PlantCreate) -> Plant:
        """Create a new plant."""
        new_plant = Plant(name=plant_data.name, customer_id=plant_data.customer_id)
        self.db.add(new_plant)
        self.db.commit()
        self.db.refresh(new_plant)
        return new_plant
    
    def get_plant(self, plant_id: int) -> Optional[Plant]:
        """Get a plant by ID."""
        return self.db.query(Plant).filter(Plant.id == plant_id).first()
    
    def delete_plant(self, plant_id: int) -> bool:
        """Delete a plant by ID."""
        plant = self.get_plant(plant_id)
        if plant is None:
            return False
        self.db.delete(plant)
        self.db.commit()
        return True

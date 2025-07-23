"""
Laitos API Router

FastAPI-reititin laitosten hallintaan.
Sisältää CRUD-operaatiot asiakkaiden laitoksille.
Sisältää revisionhallinnan laitoskonfiguraatioille.
"""
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from sqlalchemy import and_, desc

from app.database import get_db
from app.models.plant import Plant
from app.models.customer import Customer
from app.schemas.plant import (
    PlantCreate, PlantUpdate, PlantOut, PlantWithCustomer,
    RevisionCreate, RevisionActivate, PlantRevisionSummary
)

router = APIRouter()


@router.get("/plants", response_model=List[PlantWithCustomer])
def get_plants(
    customer_id: Optional[int] = Query(None, description="Suodata asiakas-ID:n mukaan"),
    search: Optional[str] = Query(None, description="Hae laitoksia nimen perusteella"),
    active_only: bool = Query(True, description="Näytä vain aktiiviset revisiot"),
    db: Session = Depends(get_db)
):
    """Hae kaikki laitokset tai suodata asiakas-ID:n tai hakutermin perusteella"""
    query = db.query(Plant, Customer.name.label("customer_name")).join(Customer)
    
    if customer_id:
        query = query.filter(Plant.customer_id == customer_id)
    
    if search:
        query = query.filter(Plant.name.ilike(f"%{search}%"))
    
    # Suodata vain aktiiviset revisiot, jos pyydetty
    if active_only:
        query = query.filter(Plant.is_active_revision == True)
    
    results = query.all()
    
    laitokset = []
    for plant, customer_name in results:
        laitos_dict = {
            "id": plant.id,
            "customer_id": plant.customer_id,
            "name": plant.name,
            "town": plant.town,
            "country": plant.country,
            "created_at": plant.created_at,
            "updated_at": plant.updated_at,
            "customer_name": customer_name
        }
        laitokset.append(PlantWithCustomer(**laitos_dict))
    
    return laitokset


@router.get("/plants/{plant_id}", response_model=PlantOut)
def get_plant(plant_id: int, db: Session = Depends(get_db)):
    """Hae tietty laitos ID:llä"""
    plant = db.query(Plant).filter(Plant.id == plant_id).first()
    if not plant:
        raise HTTPException(status_code=404, detail="Plant not found")
    return plant


@router.post("/plants", response_model=PlantOut)
def create_plant(plant: PlantCreate, db: Session = Depends(get_db)):
    """
    Luo uusi laitos (luo automaattisesti ensimmäisen revision).

    HUOM! Vain yksi laitosrevisio voi olla kerrallaan tilassa 'ACTIVE' per asiakas.
    Kaikki saman asiakkaan (customer_id) kaikkien laitosten (name) kaikkien revisioiden (revision) rivit,
    jotka ovat tilassa 'ACTIVE', muutetaan 'DRAFT'-tilaan ennen uuden luontia. Vain uusi jää 'ACTIVE'-tilaan.
    """
    try:
        # Varmista, että asiakas on olemassa
        customer = db.query(Customer).filter(Customer.id == plant.customer_id).first()
        if not customer:
            raise HTTPException(status_code=404, detail="Customer not found")

        # Päivitä kaikki asiakkaan kaikkien laitosten kaikki revisiot, jotka ovat tilassa 'ACTIVE', DRAFT-tilaan
        muut_laitokset = db.query(Plant).filter(
            Plant.customer_id == plant.customer_id,
            Plant.revision_status == "ACTIVE"
        ).all()
        for op in muut_laitokset:
            op.is_active_revision = False
            op.revision_status = "DRAFT"
        db.commit()

        # Selvitä seuraava revision-numero
        max_revision = db.query(Plant.revision).filter(
            Plant.customer_id == plant.customer_id,
            Plant.name == plant.name
        ).order_by(Plant.revision.desc()).first()
        seuraava_revision = (max_revision[0] + 1) if max_revision else 1

        # Luo uusi ACTIVE-revisio
        plant_data = plant.dict()
        plant_data.update({
            "revision": seuraava_revision,
            "revision_name": "Initial revision",
            "is_active_revision": True,
            "revision_status": "ACTIVE",
            "created_by": "system"  # TODO: Get from auth context
        })

        db_laitos = Plant(**plant_data)
        db.add(db_laitos)
        db.commit()
        db.refresh(db_laitos)

        # Päivitä asiakkaan updated_at aikaleima
        customer.updated_at = db_laitos.created_at
        db.commit()

        return db_laitos
    except Exception as e:
        db.rollback()
        from sqlalchemy.exc import IntegrityError
        import logging
        logger = logging.getLogger("uvicorn.error")
        if isinstance(e, IntegrityError):
            logger.warning(f"Tietokantavirhe: mahdollinen duplikaatti tai eheyssääntö. {str(e)}")
            raise HTTPException(status_code=409, detail="Tietokantavirhe: mahdollinen duplikaatti tai eheyssääntö.")
        logger.error(f"Virhe laitoksen luonnissa: {str(e)}")
        raise HTTPException(status_code=400, detail=f"Virhe laitoksen luonnissa: {str(e)}")


@router.put("/plants/{plant_id}", response_model=PlantOut)
def update_plant(plant_id: int, plant: PlantUpdate, db: Session = Depends(get_db)):
    """Päivitä olemassa oleva laitos"""
    db_plant = db.query(Plant).filter(Plant.id == plant_id).first()
    if not db_plant:
        raise HTTPException(status_code=404, detail="Plant not found")
    
    # If customer_id is being changed, verify new customer exists
    if plant.customer_id and plant.customer_id != db_plant.customer_id:
        customer = db.query(Customer).filter(Customer.id == plant.customer_id).first()
        if not customer:
            raise HTTPException(status_code=404, detail="Customer not found")
    
    # Check for duplicate plant name within customer
    if plant.name and plant.name != db_plant.name:
        customer_id = plant.customer_id or db_plant.customer_id
        existing_plant = db.query(Plant).filter(
            and_(
                Plant.customer_id == customer_id,
                Plant.name == plant.name,
                Plant.id != plant_id
            )
        ).first()
        if existing_plant:
            raise HTTPException(
                status_code=400,
                detail=f"Plant '{plant.name}' already exists for this customer"
            )
    
    # Update plant fields
    update_data = plant.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(db_plant, field, value)
    
    db.commit()
    db.refresh(db_plant)
    
    # Update customer's updated_at timestamp
    customer = db.query(Customer).filter(Customer.id == db_plant.customer_id).first()
    if customer:
        customer.updated_at = db_plant.updated_at
        db.commit()
    
    return db_plant


@router.delete("/plants/{plant_id}")
def delete_plant(plant_id: int, db: Session = Depends(get_db)):
    """Poista laitos"""
    db_plant = db.query(Plant).filter(Plant.id == plant_id).first()
    if not db_plant:
        raise HTTPException(status_code=404, detail="Plant not found")
    
    customer_id = db_plant.customer_id
    db.delete(db_plant)
    db.commit()
    
    # Update customer's updated_at timestamp
    from sqlalchemy import func
    customer = db.query(Customer).filter(Customer.id == customer_id).first()
    if customer:
        customer.updated_at = func.now()
        db.commit()
    
    return {"message": f"Plant '{db_plant.name}' deleted successfully"}


@router.get("/customers/{customer_id}/plants", response_model=List[PlantOut])
def get_customer_plants(customer_id: int, db: Session = Depends(get_db)):
    """Hae kaikki laitokset tietylle asiakkaalle"""
    # Verify customer exists
    customer = db.query(Customer).filter(Customer.id == customer_id).first()
    if not customer:
        raise HTTPException(status_code=404, detail="Customer not found")
    
    plants = db.query(Plant).filter(Plant.customer_id == customer_id).all()
    return plants


@router.get("/customers/{customer_id}/can-delete")
def check_customer_can_delete(customer_id: int, db: Session = Depends(get_db)):
    """Tarkista voiko asiakkaan poistaa (ei laitoksia)"""
    customer = db.query(Customer).filter(Customer.id == customer_id).first()
    if not customer:
        raise HTTPException(status_code=404, detail="Customer not found")
    
    plant_count = db.query(Plant).filter(Plant.customer_id == customer_id).count()
    
    return {
        "can_delete": plant_count == 0,
        "plant_count": plant_count,
        "message": "Customer has plants" if plant_count > 0 else "Customer can be deleted"
    }


# === REVISION CONTROL ENDPOINTS ===

@router.get("/plants/{plant_id}/revisions", response_model=List[PlantRevisionSummary])
def get_plant_revisions(plant_id: int, db: Session = Depends(get_db)):
    """Hae kaikki laitoksen revisiot"""
    # Find the base plant or any revision to get the plant identity
    base_plant = db.query(Plant).filter(Plant.id == plant_id).first()
    if not base_plant:
        raise HTTPException(status_code=404, detail="Plant not found")
    
    # Get all revisions for this plant (same customer + name combination)
    revisions = db.query(Plant).filter(
        and_(
            Plant.customer_id == base_plant.customer_id,
            Plant.name == base_plant.name
        )
    ).order_by(desc(Plant.revision)).all()
    
    return [PlantRevisionSummary.from_orm(rev) for rev in revisions]


@router.post("/plants/{plant_id}/revisions", response_model=PlantOut)
def create_plant_revision(
    plant_id: int, 
    revision_data: RevisionCreate, 
    db: Session = Depends(get_db)
):
    """Luo uusi laitoksen revisio"""
    # Get the source plant
    source_plant = db.query(Plant).filter(Plant.id == plant_id).first()
    if not source_plant:
        raise HTTPException(status_code=404, detail="Plant not found")
    
    # Get the next revision number
    max_revision = db.query(Plant).filter(
        and_(
            Plant.customer_id == source_plant.customer_id,
            Plant.name == source_plant.name
        )
    ).order_by(desc(Plant.revision)).first()
    
    next_revision = (max_revision.revision + 1) if max_revision else 1
    
    # Create new revision by copying source plant
    new_revision_data = {
        "customer_id": source_plant.customer_id,
        "name": source_plant.name,
        "town": source_plant.town,
        "country": source_plant.country,
        "revision": next_revision,
        "revision_name": revision_data.revision_name,
        "base_revision_id": source_plant.id,
        "created_from_revision": source_plant.revision,
        "is_active_revision": False,  # New revisions start as DRAFT
        "revision_status": "DRAFT",
        "created_by": revision_data.created_by or "system"
    }
    
    new_revision = Plant(**new_revision_data)
    db.add(new_revision)
    db.commit()
    db.refresh(new_revision)
    
    return new_revision


@router.put("/plants/{plant_id}/revisions/activate", response_model=PlantOut)
def activate_plant_revision(
    plant_id: int, 
    activation_data: RevisionActivate, 
    db: Session = Depends(get_db)
):
    """Aktivoi laitoksen revisio (aseta aktiiviseksi versioksi)"""
    # Get the revision to activate
    revision_to_activate = db.query(Plant).filter(Plant.id == plant_id).first()
    if not revision_to_activate:
        raise HTTPException(status_code=404, detail="Plant revision not found")
    
    if revision_to_activate.revision_status == "ACTIVE":
        raise HTTPException(status_code=400, detail="Revision is already active")
    
    if revision_to_activate.revision_status == "ARCHIVED":
        raise HTTPException(status_code=400, detail="Cannot activate archived revision")
    
    # Deactivate current active revision
    current_active = db.query(Plant).filter(
        and_(
            Plant.customer_id == revision_to_activate.customer_id,
            Plant.name == revision_to_activate.name,
            Plant.is_active_revision == True
        )
    ).first()
    
    if current_active:
        current_active.is_active_revision = False
        current_active.revision_status = "ARCHIVED"
    
    # Activate the new revision
    revision_to_activate.is_active_revision = True
    revision_to_activate.revision_status = "ACTIVE"
    
    if activation_data.activation_notes:
        # Could store activation notes in a separate table or field
        pass
    
    db.commit()
    db.refresh(revision_to_activate)
    
    return revision_to_activate


@router.get("/plants/{plant_id}/active", response_model=PlantOut)
def get_active_plant_revision(plant_id: int, db: Session = Depends(get_db)):
    """Hae laitoksen nykyinen aktiivinen revisio"""
    # Get any revision of the plant to find the plant identity
    any_revision = db.query(Plant).filter(Plant.id == plant_id).first()
    if not any_revision:
        raise HTTPException(status_code=404, detail="Plant not found")
    
    # Find the active revision
    active_revision = db.query(Plant).filter(
        and_(
            Plant.customer_id == any_revision.customer_id,
            Plant.name == any_revision.name,
            Plant.is_active_revision == True
        )
    ).first()
    
    if not active_revision:
        raise HTTPException(status_code=404, detail="No active revision found")
    
    return active_revision


@router.delete("/plants/{plant_id}/revisions")
def delete_plant_revision(plant_id: int, db: Session = Depends(get_db)):
    """Poista laitoksen revisio (vain DRAFT-revisiot voidaan poistaa)"""
    revision = db.query(Plant).filter(Plant.id == plant_id).first()
    if not revision:
        raise HTTPException(status_code=404, detail="Plant revision not found")
    
    if revision.revision_status != "DRAFT":
        raise HTTPException(
            status_code=400, 
            detail="Only DRAFT revisions can be deleted"
        )
    
    revision_name = f"{revision.name} (Rev {revision.revision})"
    db.delete(revision)
    db.commit()
    
    return {"message": f"Plant revision '{revision_name}' deleted successfully"}

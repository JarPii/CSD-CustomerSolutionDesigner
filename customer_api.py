@app.get("/customers/{customer_id}/can_delete")
def can_delete_customer(customer_id: int, db: Session = Depends(get_db)):
    customer = db.query(Customer).filter(Customer.id == customer_id).first()
    if customer is None:
        return {"can_delete": False}
    plants = db.query(Plant).filter(Plant.customer_id == customer_id).count()
    return {"can_delete": plants == 0}

# --- ENDPOINTIT ---

# --- LINJAN POISTO, vain jos ei tank_group, tank eikä station viittauksia ---
# (Huom! Tämä endpoint pitää olla FastAPI-appin alustuksen JÄLKEEN)


# --- ENDPOINTIT ---



from fastapi import FastAPI, HTTPException, Depends, Body
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import create_engine, Column, Integer, String, text, Boolean, ForeignKey
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session
from pydantic import BaseModel
import os
import pandas as pd
from typing import List as _List, Optional

# Load environment variables from .env file
from dotenv import load_dotenv
load_dotenv()

# --- DB INIT x---
def get_db_url():
    return os.getenv("DATABASE_URL") or "postgresql+psycopg2://user:password@localhost:5432/yourdb"

SQLALCHEMY_DATABASE_URL = get_db_url()
engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Luodaan tietokantataulut
Base.metadata.create_all(bind=engine)


from fastapi.staticfiles import StaticFiles

app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Serve static files (frontend)
import os as _os

# Staattisten tiedostojen polku
static_dir = _os.path.join(_os.path.dirname(_os.path.abspath(__file__)), "static")
app.mount("/static", StaticFiles(directory=static_dir), name="static")

# Juuri palauttaa index.html
from fastapi.responses import FileResponse
@app.get("/")
def read_root():
    return FileResponse(_os.path.join(static_dir, "index.html"))

@app.get("/ping")
def ping():
    return {"ping": "pong"}

def get_db():
    print("get_db: luodaan tietokantayhteys...")
    db = SessionLocal()
    print("get_db: tietokantayhteys luotu!")
    try:
        yield db
    finally:
        db.close()

# --- SQLAlchemy mallit ---

# --- TankGroup, Tank ja Station mallit (valmiina käyttöön, kun tietokantataulut ovat olemassa) ---


# --- TankGroup ja Tank mallit käyttöön ---
from sqlalchemy import DateTime
import datetime

class TankGroup(Base):
    __tablename__ = "tank_group"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False, default="Not named")
    number = Column(Integer, nullable=False)
    line_id = Column(Integer, nullable=False)
    plant_id = Column(Integer, nullable=False)

class Tank(Base):
    __tablename__ = "tank"
    id = Column(Integer, primary_key=True, index=True)
    tank_group_id = Column(Integer, nullable=False)
    name = Column(String, nullable=False, default="Not named")
    number = Column(Integer, nullable=False)
    width = Column(Integer, nullable=False)
    length = Column(Integer, nullable=False)
    depth = Column(Integer, nullable=False)
    space = Column(Integer, nullable=True, default=200)
    plant_id = Column(Integer, nullable=False)



# class Station(Base):
#     __tablename__ = "station"
#     id = Column(Integer, primary_key=True, index=True)
#     # line_id = Column(Integer, ForeignKey("line.id"))
#     # lisää muita sarakkeita tarpeen mukaan
class Customer(Base):
    __tablename__ = "customer"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    town = Column(String, nullable=True)
    country = Column(String, nullable=True)

class Plant(Base):
    __tablename__ = "plant"
    id = Column(Integer, primary_key=True, index=True)
    customer_id = Column(Integer, nullable=False)
    name = Column(String, nullable=False)
    town = Column(String, nullable=True)
    country = Column(String, nullable=True)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.datetime.utcnow, onupdate=datetime.datetime.utcnow)
    # Revision control fields
    revision = Column(Integer, nullable=False, default=1)
    revision_name = Column(String, nullable=True)
    base_revision_id = Column(Integer, nullable=True)
    created_from_revision = Column(Integer, nullable=True)
    is_active_revision = Column(Boolean, nullable=False, default=True)
    revision_status = Column(String, nullable=False, default="ACTIVE")
    created_by = Column(String, nullable=False, default="system")
    archived_at = Column(DateTime, nullable=True)

class Line(Base):
    __tablename__ = "line"
    id = Column(Integer, primary_key=True, index=True)
    plant_id = Column(Integer, nullable=False)
    number = Column(Integer, nullable=False)
    min_x = Column(Integer, nullable=False)
    max_x = Column(Integer, nullable=False)
    min_y = Column(Integer, nullable=False, default=0)
    max_y = Column(Integer, nullable=False, default=1000)

class Device(Base):
    __tablename__ = "device"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    manufacturer = Column(String)
    model = Column(String)
    type = Column(String)
    generic = Column(Boolean, nullable=False, default=False)

class Function(Base):
    __tablename__ = "function"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    functional_description = Column(String)

class FunctionDevice(Base):
    __tablename__ = "function_device"
    function_id = Column(Integer, ForeignKey("function.id", ondelete="CASCADE"), primary_key=True)
    device_id = Column(Integer, ForeignKey("device.id", ondelete="CASCADE"), primary_key=True)

# --- Pydantic mallit ---
class CustomerCreate(BaseModel):
    name: str
    town: Optional[str] = None
    country: Optional[str] = None

class CustomerOut(BaseModel):
    id: int
    name: str
    town: Optional[str] = None
    country: Optional[str] = None
    class Config:
        from_attributes = True
class PlantCreate(BaseModel):
    name: str
    customer_id: int
    town: Optional[str] = None
    country: Optional[str] = None
    revision_name: Optional[str] = None
    created_by: Optional[str] = None

class PlantRevisionCreate(BaseModel):
    revision_name: Optional[str] = None
    created_by: Optional[str] = None

class PlantRevisionUpdate(BaseModel):
    name: Optional[str] = None
    town: Optional[str] = None
    country: Optional[str] = None
    revision_name: Optional[str] = None
class PlantOut(BaseModel):
    id: int
    name: str
    customer_id: int
    town: Optional[str] = None
    country: Optional[str] = None
    revision: int
    revision_name: Optional[str] = None
    base_revision_id: Optional[int] = None
    created_from_revision: Optional[int] = None
    is_active_revision: bool
    revision_status: str
    created_by: Optional[str] = None
    archived_at: Optional[str] = None
    created_at: Optional[str] = None
    updated_at: Optional[str] = None
    class Config:
        from_attributes = True
# --- ENDPOINTIT ---

# --- PLANT REVISION ENDPOINTS ---

# Hae kaikki revisiot tietylle plantille (customer_id + name)
@app.get("/plants/{customer_id}/{plant_name}/revisions", response_model=_List[PlantOut])
def get_plant_revisions(customer_id: int, plant_name: str, db: Session = Depends(get_db)):
    return db.query(Plant).filter(Plant.customer_id == customer_id, Plant.name == plant_name).order_by(Plant.revision.desc()).all()

# Hae aktiivinen revisio
@app.get("/plants/{customer_id}/{plant_name}/active_revision", response_model=PlantOut)
def get_active_plant_revision(customer_id: int, plant_name: str, db: Session = Depends(get_db)):
    plant = db.query(Plant).filter(Plant.customer_id == customer_id, Plant.name == plant_name, Plant.is_active_revision == True).first()
    if not plant:
        raise HTTPException(status_code=404, detail="Active revision not found")
    return plant

# Hae DRAFT-revisiot
@app.get("/plants/{customer_id}/{plant_name}/draft_revisions", response_model=_List[PlantOut])
def get_draft_plant_revisions(customer_id: int, plant_name: str, db: Session = Depends(get_db)):
    return db.query(Plant).filter(Plant.customer_id == customer_id, Plant.name == plant_name, Plant.revision_status == "DRAFT").all()

# Hae ARCHIVED-revisiot
@app.get("/plants/{customer_id}/{plant_name}/archived_revisions", response_model=_List[PlantOut])
def get_archived_plant_revisions(customer_id: int, plant_name: str, db: Session = Depends(get_db)):
    return db.query(Plant).filter(Plant.customer_id == customer_id, Plant.name == plant_name, Plant.revision_status == "ARCHIVED").all()

# Luo uusi revisio (kopioi aktiivisen pohjalta, status=DRAFT)
@app.post("/plants/{plant_id}/revisions", response_model=PlantOut)
def create_plant_revision(plant_id: int, data: PlantRevisionCreate, db: Session = Depends(get_db)):
    orig = db.query(Plant).filter(Plant.id == plant_id).first()
    if not orig:
        raise HTTPException(status_code=404, detail="Original plant not found")
    # Etsi seuraava revision numero
    max_rev = db.query(Plant).filter(Plant.customer_id == orig.customer_id, Plant.name == orig.name).order_by(Plant.revision.desc()).first()
    next_rev = (max_rev.revision + 1) if max_rev else 2
    new_plant = Plant(
        customer_id=orig.customer_id,
        name=orig.name,
        town=orig.town,
        country=orig.country,
        revision=next_rev,
        revision_name=data.revision_name or f"Revision {next_rev}",
        base_revision_id=orig.base_revision_id or orig.id,
        created_from_revision=orig.revision,
        is_active_revision=False,
        revision_status="DRAFT",
        created_by=data.created_by or "system"
    )
    db.add(new_plant)
    db.commit()
    db.refresh(new_plant)
    return new_plant

# Aktivoi revisio (asettaa tämän aktiiviseksi, muut arkistoidaan)
@app.put("/plants/{plant_id}/activate", response_model=PlantOut)
def activate_plant_revision(plant_id: int, db: Session = Depends(get_db)):
    plant = db.query(Plant).filter(Plant.id == plant_id).first()
    if not plant:
        raise HTTPException(status_code=404, detail="Revision not found")
    # Arkistoi vanha aktiivinen
    db.query(Plant).filter(
        Plant.customer_id == plant.customer_id,
        Plant.name == plant.name,
        Plant.is_active_revision == True
    ).update({"is_active_revision": False, "revision_status": "ARCHIVED", "archived_at": datetime.datetime.utcnow()})
    # Aktivoi tämä
    plant.is_active_revision = True
    plant.revision_status = "ACTIVE"
    plant.archived_at = None
    db.commit()
    db.refresh(plant)
    return plant

# Poista revisio (vain DRAFT)
@app.delete("/plants/{plant_id}/revisions")
def delete_plant_revision(plant_id: int, db: Session = Depends(get_db)):
    plant = db.query(Plant).filter(Plant.id == plant_id).first()
    if not plant:
        raise HTTPException(status_code=404, detail="Revision not found")
    if plant.revision_status != "DRAFT":
        raise HTTPException(status_code=400, detail="Only DRAFT revisions can be deleted")
    db.delete(plant)
    db.commit()
    return {"ok": True}

# Päivitä revisio (vain DRAFT)
@app.put("/plants/{plant_id}/revisions", response_model=PlantOut)
def update_plant_revision(plant_id: int, data: PlantRevisionUpdate, db: Session = Depends(get_db)):
    plant = db.query(Plant).filter(Plant.id == plant_id).first()
    if not plant:
        raise HTTPException(status_code=404, detail="Revision not found")
    if plant.revision_status != "DRAFT":
        raise HTTPException(status_code=400, detail="Only DRAFT revisions can be updated")
    for field, value in data.dict(exclude_unset=True).items():
        setattr(plant, field, value)
    db.commit()
    db.refresh(plant)
    return plant
class LineCreate(BaseModel):
    plant_id: int
    number: int
    min_x: int
    max_x: int
    length: Optional[int] = 1000  # altaan pituus, käytetään max_y:nä
    tank_group_count: int
    tanks_per_group: int
    tank_width: int
    tank_length: int
    tank_depth: int
    tank_space: Optional[int] = 200  # väli tankien välillä
class LineOut(BaseModel):
    id: int
    plant_id: int
    number: int
    min_x: int
    max_x: int
    min_y: int
    max_y: int
    class Config:
        from_attributes = True
class DeviceCreate(BaseModel):
    name: str
class DeviceOut(BaseModel):
    id: int
    name: str
    class Config:
        from_attributes = True
class FunctionCreate(BaseModel):
    name: str
    functional_description: Optional[str] = None
    device_ids: _List[int] = []
class FunctionOut(BaseModel):
    id: int
    name: str
    functional_description: Optional[str]
    device_ids: _List[int] = []
    class Config:
        from_attributes = True

# --- ENDPOINTIT ---

# HAE LINJAT LAITOKSELLE
@app.get("/plants/{plant_id}/lines", response_model=_List[LineOut])
def get_lines_for_plant(plant_id: int, db: Session = Depends(get_db)):
    lines = db.query(Line).filter(Line.plant_id == plant_id).all()
    # Korjaa mahdolliset None-arvot min_y ja max_y
    for l in lines:
        if l.min_y is None:
            l.min_y = 0
        if l.max_y is None:
            l.max_y = 1000
    return lines
@app.get("/customers", response_model=_List[CustomerOut])
def read_customers(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    print("Haetaan asiakkaita tietokannasta...")
    customers = db.query(Customer).offset(skip).limit(limit).all()
    print("Asiakkaat haettu!")
    return [CustomerOut(id=c.id, name=c.name, town=c.town, country=c.country) for c in customers]

@app.post("/customers", response_model=CustomerOut)
def create_customer(customer: CustomerCreate, db: Session = Depends(get_db)):
    new_customer = Customer(
        name=customer.name,
        town=customer.town,
        country=customer.country
    )
    db.add(new_customer)
    db.commit()
    db.refresh(new_customer)
    return new_customer

@app.delete("/customers/{customer_id}")
def delete_customer(customer_id: int, db: Session = Depends(get_db)):
    customer = db.query(Customer).filter(Customer.id == customer_id).first()
    if customer is None:
        raise HTTPException(status_code=404, detail="Customer not found")
    # Tarkista onko asiakkaalla plantteja
    plants = db.query(Plant).filter(Plant.customer_id == customer_id).count()
    if plants > 0:
        raise HTTPException(status_code=400, detail="Customer cannot be deleted: customer has plants.")
    db.delete(customer)
    db.commit()
    return {"ok": True}

@app.get("/customers/{customer_id}/plants", response_model=_List[PlantOut])
def get_plants_for_customer(customer_id: int, db: Session = Depends(get_db)):
    plants = db.query(Plant).filter(Plant.customer_id == customer_id).all()
    return plants

@app.get("/plants", response_model=_List[PlantOut])
def get_all_plants(db: Session = Depends(get_db)):
    return db.query(Plant).all()

@app.post("/plants", response_model=PlantOut)
def create_plant(plant: PlantCreate, db: Session = Depends(get_db)):
    new_plant = Plant(name=plant.name, customer_id=plant.customer_id)
    db.add(new_plant)
    db.commit()
    db.refresh(new_plant)
    return new_plant

@app.delete("/plants/{plant_id}")
def delete_plant(plant_id: int, db: Session = Depends(get_db)):
    plant = db.query(Plant).filter(Plant.id == plant_id).first()
    if plant is None:
        raise HTTPException(status_code=404, detail="Plant not found")
    db.delete(plant)
    db.commit()
    return {"ok": True}

@app.post("/lines", response_model=LineOut)
def create_line(line: LineCreate, db: Session = Depends(get_db)):
    # Tarkista onko linja jo olemassa
    existing = db.query(Line).filter(Line.plant_id == line.plant_id, Line.number == line.number).first()
    if existing:
        raise HTTPException(status_code=400, detail="Line already exists for this plant.")
    min_y = 0
    max_y = line.length if line.length is not None else 1000
    new_line = Line(
        plant_id=line.plant_id,
        number=line.number,
        min_x=line.min_x,
        max_x=line.max_x,
        min_y=min_y,
        max_y=max_y
    )
    db.add(new_line)
    db.commit()
    db.refresh(new_line)

    # Luo tank_groupit ja tankit
    tank_group_number = 101
    tank_number = 101
    for group_idx in range(line.tank_group_count):
        tank_group = TankGroup(
            name="Not named",  # Korjattu group_name -> name
            line_id=new_line.id,
            number=tank_group_number,  # Korjattu tank_group_number -> number
            plant_id=new_line.plant_id
        )
        db.add(tank_group)
        db.commit()
        db.refresh(tank_group)

        for tank_idx in range(line.tanks_per_group):
            tank = Tank(
                tank_group_id=tank_group.id,
                name="Not named",  # Korjattu tank_name -> name
                number=tank_number,  # Korjattu tank_number -> number
                width=line.tank_width,
                length=line.tank_length,
                depth=line.tank_depth,
                space=line.tank_space,  # Lisätään space kenttä
                plant_id=new_line.plant_id
            )
            db.add(tank)
            tank_number += 1
        tank_group_number += 1
    db.commit()
    return new_line

@app.get("/devices", response_model=_List[DeviceOut])
def get_devices(db: Session = Depends(get_db)):
    return db.query(Device).filter(Device.generic == True).all()

@app.post("/devices", response_model=DeviceOut)
def create_device(device: DeviceCreate, db: Session = Depends(get_db)):
    new_device = Device(name=device.name, generic=True)
    db.add(new_device)
    db.commit()
    db.refresh(new_device)
    return new_device

@app.put("/devices/{device_id}", response_model=DeviceOut)
def update_device(device_id: int, device: DeviceCreate, db: Session = Depends(get_db)):
    db_device = db.query(Device).filter(Device.id == device_id, Device.generic == True).first()
    if db_device is None:
        raise HTTPException(status_code=404, detail="Device not found")
    db_device.name = device.name
    db.commit()
    db.refresh(db_device)
    return db_device

@app.delete("/devices/{device_id}")
def delete_device(device_id: int, db: Session = Depends(get_db)):
    db_device = db.query(Device).filter(Device.id == device_id, Device.generic == True).first()
    if db_device is None:
        raise HTTPException(status_code=404, detail="Device not found")
    in_function = db.query(FunctionDevice).filter(FunctionDevice.device_id == device_id).first()
    if in_function:
        raise HTTPException(status_code=400, detail="Device is linked to a function and cannot be deleted.")
    db.delete(db_device)
    db.commit()
    return {"ok": True}

@app.get("/devices/search", response_model=_List[DeviceOut])
def search_devices(q: str = "", db: Session = Depends(get_db)):
    q = q.strip()
    query = db.query(Device).filter(Device.generic == True)
    if q:
        query = query.filter(Device.name.ilike(f"%{q}%"))
    return query.limit(10).all()

@app.get("/functions", response_model=_List[FunctionOut])
def get_functions(db: Session = Depends(get_db)):
    functions = db.query(Function).all()
    result = []
    for f in functions:
        device_ids = [fd.device_id for fd in db.query(FunctionDevice).filter(FunctionDevice.function_id == f.id)]
        result.append(FunctionOut(
            id=f.id,
            name=f.name,
            functional_description=f.functional_description,
            device_ids=device_ids
        ))
    return result

@app.get("/functions/{function_id}", response_model=FunctionOut)
def get_function(function_id: int, db: Session = Depends(get_db)):
    f = db.query(Function).filter(Function.id == function_id).first()
    if not f:
        raise HTTPException(status_code=404, detail="Function not found")
    device_ids = [fd.device_id for fd in db.query(FunctionDevice).filter(FunctionDevice.function_id == f.id)]
    return FunctionOut(
        id=f.id,
        name=f.name,
        functional_description=f.functional_description,
        device_ids=device_ids
    )

@app.put("/functions/{function_id}", response_model=FunctionOut)
def update_function(function_id: int, function: FunctionCreate, db: Session = Depends(get_db)):
    f = db.query(Function).filter(Function.id == function_id).first()
    if not f:
        raise HTTPException(status_code=404, detail="Function not found")
    f.name = function.name
    f.functional_description = function.functional_description
    db.query(FunctionDevice).filter(FunctionDevice.function_id == function_id).delete()
    for dev_id in function.device_ids:
        db.add(FunctionDevice(function_id=function_id, device_id=dev_id))
    db.commit()
    return FunctionOut(
        id=f.id,
        name=f.name,
        functional_description=f.functional_description,
        device_ids=function.device_ids
    )

@app.post("/functions", response_model=FunctionOut)
def create_function(function: FunctionCreate, db: Session = Depends(get_db)):
    new_func = Function(name=function.name, functional_description=function.functional_description)
    db.add(new_func)
    db.commit()
    db.refresh(new_func)
    for dev_id in function.device_ids:
        db.add(FunctionDevice(function_id=new_func.id, device_id=dev_id))
    db.commit()
    return FunctionOut(
        id=new_func.id,
        name=new_func.name,
        functional_description=new_func.functional_description,
        device_ids=function.device_ids
    )

@app.delete("/functions/{function_id}")
def delete_function(function_id: int, db: Session = Depends(get_db)):
    func = db.query(Function).filter(Function.id == function_id).first()
    if func is None:
        raise HTTPException(status_code=404, detail="Function not found")
    db.query(FunctionDevice).filter(FunctionDevice.function_id == function_id).delete()
    db.delete(func)
    db.commit()
    return {"ok": True}

@app.delete("/lines/{line_id}")
def delete_line(line_id: int, db: Session = Depends(get_db)):
    line = db.query(Line).filter(Line.id == line_id).first()
    if line is None:
        raise HTTPException(status_code=404, detail="Line not found")
    db.delete(line)
    db.commit()
    return {"ok": True}

@app.get("/lines/{line_id}/tanks")
def get_tanks_for_line(line_id: int, db: Session = Depends(get_db)):
    tanks = db.query(Tank).join(TankGroup, Tank.tank_group_id == TankGroup.id).filter(TankGroup.line_id == line_id).all()
    if not tanks:
        return []
    return [
        {
            "id": t.id,
            "tank_number": t.number,
            "tank_name": t.name,
            "width": t.width,
            "length": t.length,
            "depth": t.depth,
            "space": t.space,
            "tank_group_id": t.tank_group_id
        }
        for t in tanks
    ]

@app.put("/tanks/{tank_id}")
def update_tank_name(tank_id: int, tank_name: str = Body(...), db: Session = Depends(get_db)):
    tank = db.query(Tank).filter(Tank.id == tank_id).first()
    if not tank:
        raise HTTPException(status_code=404, detail="Tank not found")
    tank.name = tank_name
    db.commit()
    return {"ok": True}

@app.get("/tanks/{tank_id}/can_delete")
def can_delete_tank(tank_id: int, db: Session = Depends(get_db)):
    tank = db.query(Tank).filter(Tank.id == tank_id).first()
    if not tank:
        return {"can_delete": False}
    # Laske montako tankkia tässä ryhmässä
    count = db.query(Tank).filter(Tank.tank_group_id == tank.tank_group_id).count()
    return {"can_delete": count == 1}

@app.delete("/tanks/{tank_id}")
def delete_tank(tank_id: int, db: Session = Depends(get_db)):
    tank = db.query(Tank).filter(Tank.id == tank_id).first()
    if not tank:
        raise HTTPException(status_code=404, detail="Tank not found")
    group_id = tank.tank_group_id
    # Poista tankki
    db.delete(tank)
    db.commit()
    # Jos ryhmässä ei enää tankkeja, poista myös tank_group
    remaining = db.query(Tank).filter(Tank.tank_group_id == group_id).count()
    if remaining == 0:
        group = db.query(TankGroup).filter(TankGroup.id == group_id).first()
        if group:
            db.delete(group)
            db.commit()
    return {"ok": True}

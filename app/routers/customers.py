"""Customer API endpoints."""
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from sqlalchemy import or_
from typing import List, Optional

from ..database import get_db
from ..models.customer import Customer
from ..schemas.customer import CustomerCreate, CustomerUpdate, CustomerOut

router = APIRouter()


@router.get("/customers", response_model=List[CustomerOut])
def get_customers(
    skip: int = 0,
    limit: int = 100,
    search: Optional[str] = Query(None, description="Search customers by name, town, or country"),
    db: Session = Depends(get_db)
):
    """Get all customers with pagination and optional search."""
    query = db.query(Customer)
    
    if search:
        search_term = f"%{search}%"
        # Search only in customer name for more intuitive results
        query = query.filter(Customer.name.ilike(search_term))
    
    customers = query.offset(skip).limit(limit).all()
    return customers


@router.post("/customers", response_model=CustomerOut)
def create_customer(
    customer: CustomerCreate,
    db: Session = Depends(get_db)
):
    """Create a new customer."""
    new_customer = Customer(
        name=customer.name,
        town=customer.town,
        country=customer.country
    )
    db.add(new_customer)
    db.commit()
    db.refresh(new_customer)
    return new_customer


@router.get("/customers/{customer_id}", response_model=CustomerOut)
def get_customer(customer_id: int, db: Session = Depends(get_db)):
    """Get a customer by ID."""
    customer = db.query(Customer).filter(Customer.id == customer_id).first()
    if customer is None:
        raise HTTPException(status_code=404, detail="Customer not found")
    return customer


@router.put("/customers/{customer_id}", response_model=CustomerOut)
def update_customer(
    customer_id: int,
    customer_update: CustomerUpdate,
    db: Session = Depends(get_db)
):
    """Update an existing customer."""
    customer = db.query(Customer).filter(Customer.id == customer_id).first()
    if customer is None:
        raise HTTPException(status_code=404, detail="Customer not found")
    
    # Update only provided fields
    if customer_update.name is not None:
        customer.name = customer_update.name
    if customer_update.town is not None:
        customer.town = customer_update.town
    if customer_update.country is not None:
        customer.country = customer_update.country
    
    db.commit()
    db.refresh(customer)
    return customer


@router.delete("/customers/{customer_id}")
def delete_customer(
    customer_id: int,
    db: Session = Depends(get_db)
):
    """Delete a customer."""
    customer = db.query(Customer).filter(Customer.id == customer_id).first()
    if customer is None:
        raise HTTPException(status_code=404, detail="Customer not found")
    
    db.delete(customer)
    db.commit()
    return {"message": "Customer deleted successfully"}

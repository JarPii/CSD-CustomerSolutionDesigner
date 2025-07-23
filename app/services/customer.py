"""Customer service layer."""
from typing import List, Optional
from sqlalchemy.orm import Session
from ..models.customer import Customer
from ..schemas.customer import CustomerCreate


class CustomerService:
    """Service layer for customer operations."""
    
    def __init__(self, db: Session):
        self.db = db
    
    def get_customers(self, skip: int = 0, limit: int = 100) -> List[Customer]:
        """Get all customers with pagination."""
        print("Haetaan asiakkaita tietokannasta...")
        customers = self.db.query(Customer).offset(skip).limit(limit).all()
        print("Asiakkaat haettu!")
        return customers
    
    def create_customer(self, customer_data: CustomerCreate) -> Customer:
        """Create a new customer."""
        new_customer = Customer(name=customer_data.name)
        self.db.add(new_customer)
        self.db.commit()
        self.db.refresh(new_customer)
        return new_customer
    
    def get_customer(self, customer_id: int) -> Optional[Customer]:
        """Get a customer by ID."""
        return self.db.query(Customer).filter(Customer.id == customer_id).first()
    
    def delete_customer(self, customer_id: int) -> bool:
        """Delete a customer by ID."""
        customer = self.get_customer(customer_id)
        if customer is None:
            return False
        self.db.delete(customer)
        self.db.commit()
        return True

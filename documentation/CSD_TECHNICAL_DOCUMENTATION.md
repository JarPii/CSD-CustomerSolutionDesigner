# Customer Management System - Technical Documentation

## Development Setup

### Prerequisites
- Python 3.8+
- PostgreSQL (Azure hosted)
- Modern web browser (Edge, Chrome, Firefox)

### Backend Development

#### Project Structure
```
stl-backend/
├── app/
│   ├── main.py                    # FastAPI application entry point
│   ├── config.py                  # Configuration management
│   ├── database.py                # Database connection and session management
│   ├── models/
│   │   └── customer.py            # SQLAlchemy ORM models (includes name, town, country)
│   ├── schemas/
│   │   └── customer.py            # Pydantic validation schemas (includes name, town, country)
│   ├── routers/
│   │   └── customers.py           # API route handlers (supports name, town, country)
│   ├── services/
│   │   └── customer.py            # Business logic layer
│   └── core/
│       └── exceptions.py          # Custom exception handling
├── static/                        # Frontend static files
├── documentation/                 # Project documentation
├── requirements.txt               # Python dependencies
├── .env.local                     # Local environment variables
└── README.md                      # Project README
```

#### Key Components

**Customer Model**

The `Customer` model includes the following fields:

- `id`: integer, primary key
- `name`: string, required
- `town`: string, optional
- `country`: string, optional

These fields are available in both the API and the database.

**1. FastAPI Application (`app/main.py`)**
```python
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from app.routers import customers

app = FastAPI(title="STL Backend API")
app.mount("/static", StaticFiles(directory="static"), name="static")
app.include_router(customers.router, prefix="/api/v1")
```

**2. Database Configuration (`app/database.py`)**
```python
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# Uses DATABASE_URL from environment
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()
```

**3. Customer Model (`app/models/customer.py`)**
```python
from sqlalchemy import Column, Integer, String
from app.database import Base

class Customer(Base):
    __tablename__ = "customers"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False, index=True)
    town = Column(String, nullable=True)
    country = Column(String, nullable=True)
```

**4. Pydantic Schemas (`app/schemas/customer.py`)**
```python
from pydantic import BaseModel
from typing import Optional

class CustomerBase(BaseModel):
    name: str
    town: Optional[str] = None
    country: Optional[str] = None

class CustomerCreate(CustomerBase):
    pass

class CustomerUpdate(CustomerBase):
    pass

class CustomerOut(CustomerBase):
    id: int
    
    class Config:
        from_attributes = True
```

#### API Endpoints Implementation

**Customer Router (`app/routers/customers.py`)**
```python
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.services.customer import CustomerService
from app.database import get_db

router = APIRouter(prefix="/customers", tags=["customers"])

@router.get("/", response_model=List[CustomerOut])
async def get_customers(
    search: Optional[str] = None,
    db: Session = Depends(get_db)
):
    service = CustomerService(db)
    if search:
        return service.search_customers(search)
    return service.get_all_customers()

@router.post("/", response_model=CustomerOut)
async def create_customer(
    customer: CustomerCreate,
    db: Session = Depends(get_db)
):
    service = CustomerService(db)
    return service.create_customer(customer)
```

#### Service Layer (`app/services/customer.py`)
```python
from sqlalchemy.orm import Session
from app.models.customer import Customer
from app.schemas.customer import CustomerCreate, CustomerUpdate

class CustomerService:
    def __init__(self, db: Session):
        self.db = db
    
    def get_all_customers(self) -> List[Customer]:
        return self.db.query(Customer).all()
    
    def search_customers(self, search_term: str) -> List[Customer]:
        return self.db.query(Customer).filter(
            Customer.name.ilike(f"%{search_term}%")
        ).all()
    
    def create_customer(self, customer_data: CustomerCreate) -> Customer:
        db_customer = Customer(**customer_data.dict())
        self.db.add(db_customer)
        self.db.commit()
        self.db.refresh(db_customer)
        return db_customer
```

### Frontend Development

#### Architecture
- **Vanilla JavaScript** - No external frameworks
- **Bootstrap 5** - CSS framework for responsive design
- **Fetch API** - For HTTP requests to backend
- **Event-driven** - User interactions trigger API calls

#### Key JavaScript Functions

**1. Customer Search with Debouncing**
```javascript
function searchCustomers() {
    const searchTerm = document.getElementById('customerSearch').value.trim();
    
    // Clear previous timeout
    if (searchTimeout) {
        clearTimeout(searchTimeout);
    }
    
    // Debounce search for 300ms
    searchTimeout = setTimeout(async () => {
        const response = await fetch(`${API_BASE}/customers?search=${encodeURIComponent(searchTerm)}`);
        const customers = await response.json();
        displaySearchResults(customers, searchTerm);
    }, 300);
}
```

**2. Dynamic Customer Selection**
```javascript
async function selectCustomer(customerId) {
    const response = await fetch(`${API_BASE}/customers/${customerId}`);
    selectedCustomer = await response.json();
    displaySelectedCustomer();
    hideSearchResults();
    document.querySelector('.all-customers-section').style.display = 'none';
}
```

**3. CRUD Operations**
```javascript
// Create
async function createCustomer(event) {
    event.preventDefault();
    const customerData = {
        name: document.getElementById('newCustomerName').value.trim(),
        town: document.getElementById('newCustomerTown').value.trim() || null,
        country: document.getElementById('newCustomerCountry').value.trim() || null
    };
    
    const response = await fetch(`${API_BASE}/customers`, {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify(customerData)
    });
    
    if (response.ok) {
        const newCustomer = await response.json();
        selectedCustomer = newCustomer;
        displaySelectedCustomer();
    }
}
```

### Database Schema

#### Customer Table
```sql
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    name VARCHAR NOT NULL,
    town VARCHAR,
    country VARCHAR
);

-- Indexes for performance
CREATE INDEX idx_customers_name ON customers(name);
```

#### Migration Strategy
- **SQLAlchemy Alembic** for database migrations (future)
- **Manual table creation** for current setup
- **Backup strategy** for production data

### Development Workflow

#### 1. Local Development Setup
```bash
# Clone/navigate to project
cd stl-backend

# Install dependencies
pip install -r requirements.txt

# Set up environment variables
cp .env.example .env.local
# Edit .env.local with your database credentials

# Start development server
py -m uvicorn app.main:app --reload
```

#### 2. Testing
```bash
# Manual API testing with PowerShell
Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/v1/customers" -Method GET

# Frontend testing
# Open http://127.0.0.1:8000/sales.html in browser
```

#### 3. Code Quality Guidelines
- **Type hints** for all Python functions
- **Docstrings** for complex functions
- **Error handling** for all external calls
- **Input validation** on both frontend and backend
- **Consistent naming** conventions

### Performance Considerations

#### Backend Optimizations
- **Database connection pooling** via SQLAlchemy
- **Query optimization** with indexes
- **Lazy loading** for related data
- **Response compression** for large datasets

#### Frontend Optimizations
- **Debounced search** (300ms delay)
- **Lazy loading** of customer lists
- **Event delegation** for dynamic content
- **Minimal DOM manipulation**

### Security Implementation

#### Backend Security
```python
# Input validation with Pydantic
class CustomerCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    town: Optional[str] = Field(None, max_length=50)
    country: Optional[str] = Field(None, max_length=50)

# SQL injection prevention with SQLAlchemy ORM
def search_customers(self, search_term: str):
    return self.db.query(Customer).filter(
        Customer.name.ilike(f"%{search_term}%")  # Safe parameterized query
    ).all()
```

#### Frontend Security
```javascript
// XSS prevention with proper escaping
function displayCustomer(customer) {
    nameElement.textContent = customer.name;  // textContent escapes HTML
    // Instead of innerHTML for user data
}

// Input sanitization
function sanitizeInput(input) {
    return input.trim().replace(/[<>]/g, '');
}
```

### Error Handling

#### Backend Error Responses
```python
from fastapi import HTTPException

# Standardized error responses
if not customer:
    raise HTTPException(
        status_code=404,
        detail="Customer not found"
    )

# Global exception handler
@app.exception_handler(ValueError)
async def value_error_handler(request, exc):
    return JSONResponse(
        status_code=400,
        content={"detail": str(exc)}
    )
```

#### Frontend Error Handling
```javascript
async function handleApiCall() {
    try {
        const response = await fetch('/api/v1/customers');
        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }
        return await response.json();
    } catch (error) {
        console.error('API call failed:', error);
        alert('Operation failed. Please try again.');
    }
}
```

### Deployment Considerations

#### Production Environment Variables
```bash
# .env.production
DATABASE_URL=postgresql://user:pass@prod-server:5432/stl_db
DEBUG=False
ALLOWED_HOSTS=yourdomain.com
```

#### Azure App Service Configuration
```python
# startup.txt
py -m uvicorn app.main:app --host 0.0.0.0 --port 8000

# Requirements for production
fastapi==0.104.1
uvicorn[standard]==0.24.0
sqlalchemy==2.0.23
psycopg2-binary==2.9.8
python-dotenv==1.0.0
```

### Future Enhancements

#### Planned Features
1. **Plant Management System**
   - Plants per customer relationship
   - Plant CRUD operations
   - Lines and stations hierarchy

2. **Authentication System**
   - JWT token-based auth
   - Role-based access control
   - Session management

3. **Advanced Features**
   - Full-text search with PostgreSQL
   - Audit logging for all operations
   - Bulk import/export functionality
   - Real-time updates with WebSockets

#### Technical Debt Items
1. **Test Coverage**
   - Unit tests for service layer
   - Integration tests for API endpoints
   - Frontend E2E testing

2. **Documentation**
   - OpenAPI/Swagger enhancement
   - API versioning strategy
   - Deployment automation

3. **Monitoring**
   - Application performance monitoring
   - Error tracking and alerting
   - Health check endpoints

This technical documentation provides a comprehensive guide for developers working on the Customer Management System.

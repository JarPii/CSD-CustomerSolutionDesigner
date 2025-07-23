"""
Dependency injection functions for FastAPI
"""
from sqlalchemy.orm import Session
from typing import Generator

from app.database import SessionLocal


def get_db() -> Generator[Session, None, None]:
    """
    Database session dependency for FastAPI routes.
    
    Usage:
        @app.get("/example")
        def example_route(db: Session = Depends(get_db)):
            # Use db session here
            pass
    
    Yields:
        Session: SQLAlchemy database session
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

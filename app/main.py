"""
STL Backend FastAPI Application

Main application entry point with FastAPI setup, middleware, and routing.
"""
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
import os

from app.config import settings
from app.core.exceptions import add_exception_handlers
from app.routers import customers

# Create FastAPI application
app = FastAPI(
    title=settings.app_name,
    version=settings.version,
    debug=settings.debug,
    docs_url="/api/docs" if settings.debug else None,  # Disable docs in production
    redoc_url="/api/redoc" if settings.debug else None,
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=settings.cors_credentials,
    allow_methods=settings.cors_methods,
    allow_headers=settings.cors_headers,
)

# Add exception handlers
add_exception_handlers(app)

# Add routers
app.include_router(customers.router, tags=["customers"])

# Import and add plant router
from app.routers import plants
app.include_router(plants.router, tags=["plants"])

# Import and add line router
from app.routers import lines
app.include_router(lines.router, tags=["lines"])

# Import and add tank group router
from app.routers import tank_groups
app.include_router(tank_groups.router)

# Import and add tank router
from app.routers import tanks
app.include_router(tanks.router)

# app.include_router(devices.router, prefix=settings.api_v1_str, tags=["devices"])
# app.include_router(functions.router, prefix=settings.api_v1_str, tags=["functions"])

# Serve static files (frontend)
static_dir = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "static")
if os.path.exists(static_dir):
    app.mount("/static", StaticFiles(directory=static_dir), name="static")


@app.get("/")
def read_root():
    """Serve the main frontend page"""
    static_index = os.path.join(static_dir, "index.html")
    if os.path.exists(static_index):
        return FileResponse(static_index)
    return {"message": "STL Backend API", "docs": "/api/docs"}


@app.get("/health")
def health_check():
    """Health check endpoint for monitoring"""
    return {
        "status": "healthy",
        "app_name": settings.app_name,
        "version": settings.version
    }


@app.get("/ping")
def ping():
    """Simple ping endpoint for connectivity testing"""
    return {"ping": "pong"}


# Specific HTML file routes (must be after API routes)
@app.get("/sales.html")
def sales_page():
    """Serve the sales page"""
    sales_file = os.path.join(static_dir, "sales.html")
    if os.path.exists(sales_file):
        return FileResponse(sales_file)
    raise HTTPException(status_code=404, detail="Sales page not found")


@app.get("/index.html")
def index_page():
    """Serve the index page"""
    index_file = os.path.join(static_dir, "index.html")
    if os.path.exists(index_file):
        return FileResponse(index_file)
    raise HTTPException(status_code=404, detail="Index page not found")


@app.get("/engineering.html")
def engineering_page():
    """Serve the engineering page"""
    engineering_file = os.path.join(static_dir, "engineering.html")
    if os.path.exists(engineering_file):
        return FileResponse(engineering_file)
    raise HTTPException(status_code=404, detail="Engineering page not found")


@app.get("/plant_layout.html")
def plant_layout_page():
    """Serve the plant layout page"""
    plant_layout_file = os.path.join(static_dir, "plant_layout.html")
    if os.path.exists(plant_layout_file):
        return FileResponse(plant_layout_file)
    raise HTTPException(status_code=404, detail="Plant layout page not found")


@app.get("/plant_line_create.html")
def plant_line_create_page():
    """Serve the plant line create page"""
    plant_line_create_file = os.path.join(static_dir, "plant_line_create.html")
    if os.path.exists(plant_line_create_file):
        return FileResponse(plant_line_create_file)
    raise HTTPException(status_code=404, detail="Plant line create page not found")


@app.get("/generic_devices_and_functions.html")
def generic_devices_page():
    """Serve the generic devices and functions page"""
    generic_devices_file = os.path.join(static_dir, "generic_devices_and_functions.html")
    if os.path.exists(generic_devices_file):
        return FileResponse(generic_devices_file)
    raise HTTPException(status_code=404, detail="Generic devices page not found")


@app.get("/simulation.html")
def serve_simulation():
    """Serve the simulation page"""
    simulation_path = os.path.join(static_dir, "simulation.html")
    if os.path.exists(simulation_path):
        return FileResponse(simulation_path)
    raise HTTPException(status_code=404, detail="Simulation page not found")

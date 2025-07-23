# STL Backend FastAPI

This is the backend for the STL plant management system. It provides a FastAPI server with CRUD endpoints for customers, plants, devices, functions, lines, tank groups, and tanks, using a PostgreSQL database.

## Structure
- `app/main.py` – Main FastAPI application
- `app/models/` – SQLAlchemy database models
- `app/schemas/` – Pydantic schemas for API validation
- `app/routers/` – FastAPI route handlers
- `app/services/` – Business logic services
- `requirements.txt` – Python dependencies
- `startup.txt` – Azure App Service startup command
- `.env.local` – Local environment configuration

## Local Development
1. Configure your database connection in `.env.local`:
   ```
   DATABASE_URL=postgresql://username:password@hostname:port/database
   ```
2. Install dependencies:
   ```
   pip install -r requirements.txt
   ```
3. **Important**: Run the server using one of these commands:
   ```
   # Preferred method (works reliably):
   python -m uvicorn customer_api:app --reload --host 127.0.0.1 --port 8000
   
   # Alternative (may not work on all systems):
   py -m uvicorn customer_api:app --reload
   ```

## Customer Data Structure
Customers have the following fields:
- `id`: integer, unique identifier
- `name`: string, customer name
- `town`: string, town/city (optional)
- `country`: string, country (optional)

## Frontend Usage
- Access the main page at: `http://127.0.0.1:8000/`
- Sales page (customer management): `http://127.0.0.1:8000/static/sales.html`
- **Note**: JavaScript functionality requires a full browser (Edge, Chrome, Firefox). 
  VS Code's Simple Browser does not support all JavaScript features.

## Azure Deployment
- Set the `DATABASE_URL` environment variable in Azure App Service.
- The app will use this variable for database connection.
- Use `startup.txt` for the startup command.

## Notes
- All database credentials must be provided via environment variable (`DATABASE_URL`).
- Do not use `database.csv` or any file-based credentials in production.
- All code and dependencies should be inside this directory for deployment.

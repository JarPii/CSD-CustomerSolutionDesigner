# Environment Setup Documentation

## Backend Setup

1. **Python Virtual Environment**
   - Create a virtual environment:
     ```bash
     python -m venv venv
     ```
   - Activate the virtual environment:
     - On Windows:
       ```bash
       .\venv\Scripts\activate
       ```
     - On macOS/Linux:
       ```bash
       source venv/bin/activate
       ```

2. **Install Dependencies**
   - Install required Python packages:
     ```bash
     pip install -r requirements.txt
     ```

3. **Run the Backend**
   - Start the backend server using Uvicorn:
     ```bash
     uvicorn customer_api:app --host 127.0.0.1 --port 8000
     ```

## Frontend Setup

1. **Static Files**
   - Ensure all static files are located in the `static/` directory.

2. **Access Frontend**
   - Open the `plant_line_create.html` file in a browser.

## Notes

- Ensure the backend is running before interacting with the frontend.
- The backend runs on `http://127.0.0.1:8000`.
- If you encounter issues, verify that all dependencies are installed and the backend is running.

## Troubleshooting

- **Missing Dependencies**:
  - Install missing packages using pip, e.g.,
    ```bash
    pip install <package-name>
    ```

- **Backend Not Starting**:
  - Check for errors in the terminal and ensure all required environment variables are set.

- **Frontend Not Connecting**:
  - Verify the backend URL in the JavaScript code matches the running backend server.

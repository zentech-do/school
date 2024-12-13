# Use the latest Python image
FROM python:3.9-slim

# Set the working directory
WORKDIR /app

# Copy application files
COPY ./src /app/src

# Install FastAPI and Uvicorn
RUN pip install --no-cache-dir fastapi uvicorn

# Expose port 8000
EXPOSE 8000

# Run the application
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]

from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "Welcome to the Placeholder App! This is a FastAPI app."}

@app.get("/health")
def health_check():
    return {"status": "healthy"}

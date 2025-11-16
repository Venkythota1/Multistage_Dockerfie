from fastapi import FastAPI
from pydantic import BaseModel
from typing import Optional

app = FastAPI(title="Secure FastAPI App", version="1.0.0")

class Item(BaseModel):
    name: str
    price: float
    description: Optional[str] = None

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

@app.get("/")
async def read_root():
    return {"message": "Welcome to Secure FastAPI with Chainguard"}

@app.get("/items/{item_id}")
async def read_item(item_id: int, q: Optional[str] = None):
    return {"item_id": item_id, "query": q}

@app.post("/items/")
async def create_item(item: Item):
    return {"item": item, "created": True}

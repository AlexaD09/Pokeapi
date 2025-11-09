from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from sqlalchemy.orm import Session
from database import get_db, Base, engine  
from models import User, SearchHistory
import bcrypt

# Create the tables before initializing the app
Base.metadata.create_all(bind=engine)

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class LoginRequest(BaseModel):
    username: str
    password: str

class SearchRequest(BaseModel):
    username: str
    query: str

# Endpoint de login
@app.post("/login")
async def login(request: LoginRequest, db: Session = Depends(get_db)):
    try:
        user = db.query(User).filter(User.username == request.username).first()
        if user and bcrypt.checkpw(request.password.encode('utf-8'), user.password.encode('utf-8')):
            return {"success": True, "message": "Successful login", "username": request.username}
        else:
            return {"success": False, "message": "Invalid credentials"}
    except Exception as e:
        print(f"Error en login: {e}")
        raise HTTPException(status_code=500, detail="Internal error")

# Endpoint for user registration
@app.post("/register")
async def register(request: LoginRequest, db: Session = Depends(get_db)):
    try:
        existing_user = db.query(User).filter(User.username == request.username).first()
        if existing_user:
            return {"success": False, "message": "User already exists"}
        
        hashed_password = bcrypt.hashpw(request.password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
        new_user = User(username=request.username, password=hashed_password)
        db.add(new_user)
        db.commit()
        db.refresh(new_user)
        return {"success": True, "message": "User created"}
    except Exception as e:
        print(f"Error en register: {e}")
        db.rollback()
        return {"success": False, "message": "Error creating user"}

# Endpoint to save search
@app.post("/save-search")
async def save_search(request: SearchRequest, db: Session = Depends(get_db)):
    try:
        search = SearchHistory(username=request.username, query=request.query)
        db.add(search)
        db.commit()
        return {"success": True}
    except Exception as e:
        print(f"Error en save-search: {e}")
        db.rollback()
        return {"success": False, "message": "Error saving search"}

# Endpoint for obtaining search history
@app.get("/user-searches/{username}")
async def get_user_searches(username: str, db: Session = Depends(get_db)):
    try:
        searches = db.query(SearchHistory).filter(SearchHistory.username == username).order_by(SearchHistory.timestamp.desc()).all()
        return [{"query": s.query, "timestamp": s.timestamp} for s in searches]
    except Exception as e:
        print(f"Error en get-user-searches: {e}")
        return []

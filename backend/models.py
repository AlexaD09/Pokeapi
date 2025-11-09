from sqlalchemy import Column, Integer, String, DateTime
from database import Base  
from datetime import datetime

class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True)
    password = Column(String)

class SearchHistory(Base):
    __tablename__ = "search_history"
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String)
    query = Column(String)
    timestamp = Column(DateTime, default=datetime.now)
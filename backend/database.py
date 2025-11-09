from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv
import psycopg2
import os

load_dotenv()
PSSW_DB = os.getenv("PSSW_DB")

# Initial connection to 'postgres' to create the database if it does not exist
GENERIC_DATABASE_URL = f"postgresql://postgres:{PSSW_DB}@localhost:5432/postgres"

def create_database():
    conn = psycopg2.connect(
        host="db",
        port="5432",
        user="postgres",
        password=PSSW_DB,
        database="postgres"
    )
    conn.autocommit = True
    cursor = conn.cursor()
    
    cursor.execute("SELECT 1 FROM pg_catalog.pg_database WHERE datname = 'pokemon_db'")
    exists = cursor.fetchone()
    
    if not exists:
        cursor.execute("CREATE DATABASE pokemon_db")
        print("✅ 'pokemon_db' database created")
    else:
        print("ℹ️ The database 'pokemon_db' already exists.)
    
    cursor.close()
    conn.close()

# Create database if it does not exist
create_database()

# Now connect to the correct base
DATABASE_URL = f"postgresql://postgres:{PSSW_DB}@db:5432/pokemon_db"

#  Use this engine throughout the app
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Here you define Base
Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

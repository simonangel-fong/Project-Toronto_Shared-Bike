from pydantic import BaseModel
from sqlalchemy import Column, Integer, String, Float
from sqlalchemy.ext.declarative import declarative_base

# SQLAlchemy Base
Base = declarative_base()

class MVBikeTripDuration(Base):
    __tablename__ = "mv_bike_trip_duration"
    __table_args__ = {"schema": "dw_schema"}

    bike_id = Column(Integer, primary_key=True)
    trip_count = Column(Integer)
    avg_trip_duration = Column(Float)

class BikeTripDurationResponse(BaseModel):
    bike_id: int
    trip_count: int
    avg_trip_duration: float

    class Config:
        orm_mode = True

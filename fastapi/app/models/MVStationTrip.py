from pydantic import BaseModel
from sqlalchemy import Column, Integer, String, Float
from sqlalchemy.ext.declarative import declarative_base

# SQLAlchemy Base
Base = declarative_base()


class MVStationTrip(Base):
    __tablename__ = "mv_station_trip"
    __table_args__ = {"schema": "dw_schema"}

    station_id = Column(Integer, primary_key=True)
    station_name = Column(String(100))
    trip_count_by_start = Column(Integer)
    trip_count_by_end = Column(Integer)


class StationTripResponse(BaseModel):
    station_id: int
    station_name: str
    trip_count_by_start: int
    trip_count_by_end: int

    class Config:
        orm_mode = True

from pydantic import BaseModel
from sqlalchemy import Column, Integer, String, Float
from sqlalchemy.ext.declarative import declarative_base

# SQLAlchemy Base
Base = declarative_base()


class MVStationRoute(Base):
    __tablename__ = "mv_station_route"
    __table_args__ = {"schema": "dw_schema"}

    start_station_id = Column(Integer, primary_key=True)
    start_station_name = Column(String(100))
    end_station_id = Column(Integer, primary_key=True)
    end_station_name = Column(String(100))
    trip_count = Column(Integer)


class StationRouteResponse(BaseModel):
    start_station_id: int
    start_station_name: str
    end_station_id: int
    end_station_name: str
    trip_count: int

    class Config:
        orm_mode = True

from pydantic import BaseModel
from sqlalchemy import Column, Integer, String, Float
from sqlalchemy.ext.declarative import declarative_base

# SQLAlchemy Base
Base = declarative_base()


class MVTimeTrip(Base):
    __tablename__ = "mv_time_trip"
    __table_args__ = {"schema": "dw_schema"}

    trip_count = Column(Integer)
    dim_year = Column(Integer, primary_key=True)
    dim_quarter = Column(Integer, primary_key=True)
    dim_month = Column(Integer, primary_key=True)
    dim_day = Column(Integer, primary_key=True)
    dim_week = Column(Integer)
    dim_weekday = Column(Integer)
    dim_hour = Column(Integer, primary_key=True)


class TimeTripResponse(BaseModel):
    trip_count: int
    dim_year: int
    dim_quarter: int
    dim_month: int
    dim_day: int
    dim_week: int
    dim_weekday: int
    dim_hour: int

    class Config:
        orm_mode = True

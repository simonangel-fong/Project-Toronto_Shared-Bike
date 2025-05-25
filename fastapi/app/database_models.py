from sqlalchemy.orm import DeclarativeBase
from sqlalchemy import Column, Integer, String, Float


class Base(DeclarativeBase):
    pass


class User(Base):
    __tablename__ = "mv_user_type"
    __table_args__ = {"schema": "dw_schema"}

    dim_user_type_id = Column(Integer, primary_key=True)
    dim_user_type_name = Column(String)
    dim_year = Column(Integer, primary_key=True)
    trip_count = Column(Integer)
    duration_avg = Column(Float)


class TripTime(Base):
    __tablename__ = "mv_trip_time"
    __table_args__ = {"schema": "dw_schema"}

    trip_count = Column(Integer)
    dim_year = Column(Integer, primary_key=True)
    dim_month = Column(Integer, primary_key=True)
    dim_hour = Column(Integer, primary_key=True)


class DurationTime(Base):
    __tablename__ = "mv_duration_time"
    __table_args__ = {"schema": "dw_schema"}

    dim_year = Column(Integer, primary_key=True)
    dim_month = Column(Integer)
    dim_hour = Column(Integer)
    avg_trip_duration = Column(Float)


class TripStation(Base):
    __tablename__ = "mv_trip_station"
    __table_args__ = {"schema": "dw_schema"}

    dim_year = Column(Integer, primary_key=True)
    dim_station_id = Column(Integer, primary_key=True)
    dim_station_name = Column(String(100))
    trip_count_by_start = Column(Float)

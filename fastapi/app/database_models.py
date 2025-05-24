from sqlalchemy.orm import DeclarativeBase
from sqlalchemy import Column, Integer, String, Float


class Base(DeclarativeBase):
    pass


class User(Base):
    __tablename__ = "mv_user_segmentation"
    __table_args__ = {"schema": "dw_schema"}

    # Using as primary key with year
    user_type_id = Column(Integer, primary_key=True)
    user_type_name = Column(String)
    # Using as composite primary key with user_type_id
    dim_year = Column(Integer, primary_key=True)
    trip_count = Column(Integer)
    avg_trip_duration = Column(Float)


class TripTime(Base):
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


class TripStation(Base):
    __tablename__ = "mv_station_trip"
    __table_args__ = {"schema": "dw_schema"}

    station_id = Column(Integer, primary_key=True)
    station_name = Column(String(100))
    trip_count_by_start = Column(Integer)
    # trip_count_by_end = Column(Integer)


class TripRoute(Base):
    __tablename__ = "mv_station_route"
    __table_args__ = {"schema": "dw_schema"}

    start_station_id = Column(Integer, primary_key=True)
    start_station_name = Column(String(100))
    end_station_id = Column(Integer, primary_key=True)
    end_station_name = Column(String(100))
    trip_count = Column(Integer)


# class MVBikeTripDuration(Base):
#     __tablename__ = "mv_bike_trip_duration"
#     __table_args__ = {"schema": "dw_schema"}

#     bike_id = Column(Integer, primary_key=True)
#     trip_count = Column(Integer)
#     avg_trip_duration = Column(Float)

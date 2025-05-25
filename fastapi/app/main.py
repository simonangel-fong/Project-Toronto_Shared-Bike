from datetime import datetime
from typing import Annotated, Optional
from fastapi import FastAPI, HTTPException, Depends, Query,  Request, status
from fastapi.responses import JSONResponse
from sqlalchemy import asc, desc
from sqlalchemy.orm import Session
from sqlalchemy.exc import SQLAlchemyError
import database, database_models

CREATOR = "Wenhao Fang"

app = FastAPI(
    title="Toronto Shared Bike Data Analysis Project",
    description="",
    version="0.1.0"
)


@app.get("/")
async def get_root_with_db():
    return {
        "title": "Toronto Shared Bike Data Analysis Project",
        "creator": CREATOR,
        "datetime": datetime.now().strftime("%Y-%m-%d %H:%M")

    }


@app.get("/user")
async def get_user(
    db: Annotated[Session, Depends(database.get_db)],
    user_type: Optional[int] = Query(None, description="Filter by user type ID"),
    year: Optional[int] = Query(None, description="Filter by year")
):
    try:
        query = db.query(database_models.User)

        # filter by user type id
        if user_type is not None:
            query = query.filter(database_models.User.dim_user_type_id == user_type)

        # when query for year
        if year is not None:
            query = query.filter(database_models.User.dim_year == year)

        result = query.all()
        count = len(result)

        return {
            "title": "User Type Query",
            "creator": CREATOR,
            "datetime": datetime.now().strftime("%Y-%m-%d %H:%M"),
            "status": "success",
            "item_count": count,
            "data": result
        }

    except SQLAlchemyError as e:
        print(datetime.now().strftime(
            "%Y-%m-%d %H:%M") + f":  [Error]: {str(e)}")
        raise HTTPException(status_code=500, detail="Database error occurred.")
    except Exception as e:
        print(datetime.now().strftime(
            "%Y-%m-%d %H:%M") + f":  [Error]: {str(e)}")
        raise HTTPException(status_code=500, detail="Unexpected server error.")


@app.get("/trip-time")
async def get_trip_time(
    db: Annotated[Session, Depends(database.get_db)],
    year: Optional[int] = Query(None, description="Filter by year"),
    month: Optional[int] = Query(None, description="Filter by month"),
    hour: Optional[int] = Query(None, description="Filter by hour")
):
    try:
        query = db.query(database_models.TripTime)

        # filter by year
        if year is not None:
            query = query.filter(database_models.TripTime.dim_year == year)

        # filter month
        if month is not None:
            query = query.filter(database_models.TripTime.dim_month == month)

        # when filtering by hour
        if hour is not None:
            query = query.filter(database_models.TripTime.dim_hour == hour)

        result = query.all()
        count = len(result)

        return {
            "title": "Time-based Trip Query",
            "creator": CREATOR,
            "datetime": datetime.now().strftime("%Y-%m-%d %H:%M"),
            "status": "success",
            "item_count": count,
            "data": result
        }
    except SQLAlchemyError as e:
        print(datetime.now().strftime(
            "%Y-%m-%d %H:%M") + f":  [Error]: {str(e)}")
        raise HTTPException(status_code=500, detail="Database error occurred.")
    except Exception as e:
        print(datetime.now().strftime(
            "%Y-%m-%d %H:%M") + f":  [Error]: {str(e)}")
        raise HTTPException(status_code=500, detail="Unexpected server error.")


@app.get("/duration-time")
async def get_trip_time(
    db: Annotated[Session, Depends(database.get_db)],
    year: Optional[int] = Query(None, description="Filter by year"),
    month: Optional[int] = Query(None, description="Filter by month"),
    hour: Optional[int] = Query(None, description="Filter by hour")
):
    try:
        query = db.query(database_models.TripTime)

        # filter by year
        if year is not None:
            query = query.filter(database_models.TripTime.dim_year == year)

        # filter by month
        if month is not None:
            query = query.filter(database_models.TripTime.dim_month == month)

        # filter by hour
        if hour is not None:
            query = query.filter(database_models.TripTime.dim_hour == hour)

        result = query.all()
        count = len(result)

        return {
            "title": "Time-based Duration Query",
            "creator": CREATOR,
            "datetime": datetime.now().strftime("%Y-%m-%d %H:%M"),
            "status": "success",
            "item_count": count,
            "data": result
        }
    except SQLAlchemyError as e:
        print(datetime.now().strftime(
            "%Y-%m-%d %H:%M") + f":  [Error]: {str(e)}")
        raise HTTPException(status_code=500, detail="Database error occurred.")
    except Exception as e:
        print(datetime.now().strftime(
            "%Y-%m-%d %H:%M") + f":  [Error]: {str(e)}")
        raise HTTPException(status_code=500, detail="Unexpected server error.")


@app.get("/trip-station")
async def get_trip_station(
    db: Annotated[Session, Depends(database.get_db)],
    year: Optional[int] = Query(None, description="Filter by year"),
    station_id: Optional[int] = Query(None, description="Filter by station ID"),
    limit: int = Query(100, ge=1, le=1000, description="Number of records to return (max 1000)"),
    offset: int = Query(0, ge=0, description="Number of records to skip"),
    sort: Optional[str] = Query(
        "desc", description="Sort by trip_count_by_start ('asc' or 'desc')")
):
    try:
        query = db.query(database_models.TripStation)

        # filter by year
        if year is not None:
            query = query.filter(database_models.TripStation.dim_year == year)

        # filter by month
        if station_id is not None:
            query = query.filter(database_models.TripStation.dim_station_id == station_id)
        
        # sort
        if sort == "asc":
            query = query.order_by(
                asc(database_models.TripStation.trip_count_by_start))
        # descend sort
        else:
            query = query.order_by(
                desc(database_models.TripStation.trip_count_by_start))

        result = query.offset(offset).limit(limit).all()
        count = len(result)

        return {
            "title": "Station-based Trip Query",
            "creator": CREATOR,
            "datetime": datetime.now().strftime("%Y-%m-%d %H:%M"),
            "status": "success",
            "item_count": count,
            "data": result
        }
    except SQLAlchemyError as e:
        print(datetime.now().strftime(
            "%Y-%m-%d %H:%M") + f":  [Error]: {str(e)}")
        raise HTTPException(status_code=500, detail="Database error occurred.")
    except Exception as e:
        print(datetime.now().strftime(
            "%Y-%m-%d %H:%M") + f":  [Error]: {str(e)}")
        raise HTTPException(status_code=500, detail="Unexpected server error.")


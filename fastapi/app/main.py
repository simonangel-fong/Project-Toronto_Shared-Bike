from datetime import datetime
from typing import Annotated, Optional
from fastapi import FastAPI, HTTPException, Depends, Query,  Request, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from sqlalchemy import asc, desc
from sqlalchemy.orm import Session
from sqlalchemy.exc import SQLAlchemyError
import database
import database_models
from app_settings import get_settings

settings = get_settings()

CREATOR = settings.CREATOR
DEPLOY_HOST = settings.DEPLOY_HOST

app = FastAPI(
    title="Toronto Shared Bike Data Analysis Project",
    description="",
    version="1.0.0"
)

# enable cors
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
async def get_root_with_db():
    return {
        "title": "Toronto Shared Bike Data Analysis Project",
        "creator": CREATOR,
        "deployed on": DEPLOY_HOST,
        "datetime": datetime.now().strftime("%Y-%m-%d %H:%M"),
        "urls": [
            {
                "name": "Web: Project homepage!!!",
                "url": "https://trip.arguswatcher.net"
            },
            {
                "name": "Web: Tableau Dashboard",
                "url": "https://trip.arguswatcher.net/tableau-dashboard.html"
            },
            {
                "name": "Web: Source Data Files",
                "url": "https://trip.arguswatcher.net/source.html"
            },
            {
                "name": "API homepage",
                "url": "https://trip-api.arguswatcher.net/"
            },
            {
                "name": "API: Time-based trip data for analysis over time",
                "url": "https://trip-api.arguswatcher.net/time-trip"
            },
            {
                "name": "API: Time-based duration data for analysis over time",
                "url": "https://trip-api.arguswatcher.net/time-duration"
            },
            {
                "name": "API: Station-based trip data for analysis over stations",
                "url": "https://trip-api.arguswatcher.net/station-trip"
            },
            {
                "name": "API: User-based trip and duration data for analysis over user types",
                "url": "https://trip-api.arguswatcher.net/user-trip-duration"
            }
        ]

    }


@app.get("/time-trip")
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
            "title": "Time-based Trip Data",
            "creator": CREATOR,
            "deployed on": DEPLOY_HOST,
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


@app.get("/time-duration")
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
            "title": "Time-based Duration Data",
            "creator": CREATOR,
            "deployed on": DEPLOY_HOST,
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


@app.get("/station-trip")
async def get_trip_station(
    db: Annotated[Session, Depends(database.get_db)],
    year: Optional[int] = Query(None, description="Filter by year"),
    station_id: Optional[int] = Query(
        None, description="Filter by station ID"),
    limit: int = Query(100, ge=1, le=1000,
                       description="Number of records to return (max 1000)"),
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
            query = query.filter(
                database_models.TripStation.dim_station_id == station_id)

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
            "title": "Station-based Trip Data",
            "creator": CREATOR,
            "deployed on": DEPLOY_HOST,
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


@app.get("/user-trip-duration")
async def get_user(
    db: Annotated[Session, Depends(database.get_db)],
    user_type: Optional[int] = Query(
        None, description="Filter by user type ID"),
    year: Optional[int] = Query(None, description="Filter by year")
):
    try:
        query = db.query(database_models.User)

        # filter by user type id
        if user_type is not None:
            query = query.filter(
                database_models.User.dim_user_type_id == user_type)

        # when query for year
        if year is not None:
            query = query.filter(database_models.User.dim_year == year)

        result = query.all()
        count = len(result)

        return {
            "title": "User-based Trip & Duration Data",
            "creator": CREATOR,
            "deployed on": DEPLOY_HOST,
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

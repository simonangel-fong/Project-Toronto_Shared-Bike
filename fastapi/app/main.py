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
        "creater": CREATOR,
        "datetime": datetime.now().strftime("%Y-%m-%d %H:%M")

    }


@app.get("/user")
async def get_user(
    db: Annotated[Session, Depends(database.get_db)],
    user: Optional[int] = Query(None, description="Filter by user type ID"),
    year: Optional[int] = Query(None, description="Filter by year")
):
    try:
        query = db.query(database_models.User)

        # when query for user
        if user is not None:
            query = query.filter(database_models.User.user_type_id == user)

        # when query for year
        if year is not None:
            query = query.filter(database_models.User.dim_year == year)

        result = query.all()
        count = len(result)

        return {
            "title": "User Type Query",
            "creater": CREATOR,
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
    quarter: Optional[int] = Query(None, description="Filter by quarter"),
    month: Optional[int] = Query(None, description="Filter by month"),
    day: Optional[int] = Query(None, description="Filter by day"),
    weekday: Optional[int] = Query(None, description="Filter by weekday"),
    hour: Optional[int] = Query(None, description="Filter by hour")
):
    try:
        query = db.query(database_models.TripTime)

        # when filtering by year
        if year is not None:
            query = query.filter(database_models.TripTime.dim_year == year)

        # when filtering by quarter
        if quarter is not None:
            query = query.filter(
                database_models.TripTime.dim_quarter == quarter)

        # when filtering by month
        if month is not None:
            query = query.filter(database_models.TripTime.dim_month == month)

        # when filtering by day
        if day is not None:
            query = query.filter(database_models.TripTime.dim_day == day)

        # when filtering by weekday
        if weekday is not None:
            query = query.filter(
                database_models.TripTime.dim_weekday == weekday)

        # when filtering by hour
        if hour is not None:
            query = query.filter(database_models.TripTime.dim_hour == hour)

        result = query.all()
        count = len(result)

        return {
            "title": "Time-based Query on Trip",
            "creater": CREATOR,
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
    sort: Optional[str] = Query(
        "desc", description="Sort by trip_count_by_start ('asc' or 'desc')")
):
    try:
        query = db.query(database_models.TripStation)

        # when ascend sort
        if sort == "asc":
            query = query.order_by(
                asc(database_models.TripStation.trip_count_by_start))
        # when descend sort
        else:
            query = query.order_by(
                desc(database_models.TripStation.trip_count_by_start))

        result = query.all()
        count = len(result)

        return {
            "title": "Station-based Query on Trip",
            "creater": CREATOR,
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


@app.get("/trip-top-route")
async def get_trip_top_route(
    db: Annotated[Session, Depends(database.get_db)],
):
    try:
        query = db.query(database_models.TripRoute)

        # top 10 route
        result = query.limit(10).all()
        count = len(result)

        return {
            "title": "Top 10 Route by Trip",
            "creater": CREATOR,
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

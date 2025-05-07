import logging
from typing import List
from fastapi import FastAPI, Depends, Query, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy.exc import SQLAlchemyError

# from .config.logging_file import configure_logging_from_env
from config.database import get_db
from config.exceptions import DatabaseError
from models.MVUserSegmentation import MVUserSegmentation, UserSegmentationResponse
from models.MVBikeTripDuration import MVBikeTripDuration, BikeTripDurationResponse
from models.MVStationRoute import MVStationRoute, StationRouteResponse
from models.MVStationTrip import MVStationTrip, StationTripResponse

# Configure logging at startup
# configure_logging_from_env()

app = FastAPI(title="Toronto_Shared_Bike")

logger = logging.getLogger(__name__)

logger.info("Application starting up...")


@app.get(
    "/user-segmentation/",
    response_model=List[UserSegmentationResponse],
    tags=["User Segmentation"],
    summary="Retrieve user segmentation data",
)
# get the user segmentation
def get_user_segmentation(
    db: Session = Depends(get_db),
    skip: int = Query(0, ge=0, description="Number of records to skip"),
    limit: int = Query(100, ge=1, le=1000,
                       description="Maximum number of records to return"),
) -> List[UserSegmentationResponse]:
    """
    Fetch user segmentation data from the materialized view.

    Args:
        db: SQLAlchemy session provided by dependency injection.
        skip: Number of records to skip for pagination (default: 0).
        limit: Maximum number of records to return (default: 100, max: 1000).

    Returns:
        List of user segmentation records.

    Raises:
        HTTPException: If a database error occurs (status code 503).
    """
    logger.info(
        f"Fetching user segmentation data with skip={skip}, limit={limit}")
    try:
        query = db.query(MVUserSegmentation)
        result = query.offset(skip).limit(limit).all()

        # if success then log
        logger.debug(
            f"Retrieved {len(result)} records from MV_USER_SEGMENTATION")
        return result
    # if db error
    except (SQLAlchemyError, DatabaseError) as e:
        logger.error(f"Database error in get_user_segmentation: {str(e)}")
        raise HTTPException(
            status_code=503,
            detail="Service unavailable due to a database error. Please try again later."
        )
    # if other error
    except Exception as e:
        logger.error(f"Unexpected error in get_user_segmentation: {str(e)}")
        raise HTTPException(
            status_code=500,
            # detail={str(e)}   # for dev
            detail="An unexpected error occurred."  # for prod
        )


@app.get(
    "/bike-trip-duration/",
    response_model=List[BikeTripDurationResponse],
    tags=["Bike Trip Duration"],
    summary="Retrieve bike trip duration data",
)
def get_bike_trip_duration(
    db: Session = Depends(get_db),
    skip: int = Query(0, ge=0, description="Number of records to skip"),
    limit: int = Query(100, ge=1, le=1000,
                       description="Maximum number of records to return"),
) -> List[BikeTripDurationResponse]:
    """
    Fetch bike trip duration data from the materialized view.

    Args:
        db: SQLAlchemy session provided by dependency injection.
        skip: Number of records to skip for pagination (default: 0).
        limit: Maximum number of records to return (default: 100, max: 1000).

    Returns:
        List of bike trip duration records.

    Raises:
        HTTPException: If a database error occurs (status code 503).
    """
    logger.info(
        f"Fetching bike trip duration data with skip={skip}, limit={limit}")
    try:
        query = db.query(MVBikeTripDuration).order_by(
            MVBikeTripDuration.trip_count.desc())
        result = query.offset(skip).limit(limit).all()

        # if success then log
        logger.debug(
            f"Retrieved {len(result)} records from MV_BIKE_TRIP_DURATION")
        return result
    # if db error
    except (SQLAlchemyError, DatabaseError) as e:
        logger.error(f"Database error in get_bike_trip_duration: {str(e)}")
        raise HTTPException(
            status_code=503,
            detail="Service unavailable due to a database error. Please try again later."
        )
    # if other error
    except Exception as e:
        logger.error(f"Unexpected error in get_bike_trip_duration: {str(e)}")
        raise HTTPException(
            status_code=500,
            # detail={str(e)}  # for development
            detail="An unexpected error occurred."  # for prod
        )


@app.get(
    "/station-route/",
    response_model=List[StationRouteResponse],
    tags=["Station Route"],
    summary="Retrieve most popular station-to-station routes",
)
def get_station_routes(
    db: Session = Depends(get_db),
    skip: int = Query(0, ge=0, description="Number of records to skip"),
    limit: int = Query(100, ge=1, le=1000,
                       description="Maximum number of records to return"),
) -> List[StationRouteResponse]:
    """
    Fetch station-to-station route data from the materialized view.

    Args:
        db: SQLAlchemy session provided by dependency injection.
        skip: Records to skip for pagination.
        limit: Maximum records to return.

    Returns:
        List of most frequent station routes.

    Raises:
        HTTPException: On database or unexpected errors.
    """
    logger.info(f"Fetching station route data with skip={skip}, limit={limit}")
    try:
        query = db.query(MVStationRoute).order_by(
            MVStationRoute.trip_count.desc())
        result = query.offset(skip).limit(limit).all()
        logger.debug(f"Retrieved {len(result)} records from MV_STATION_ROUTE")
        return result
    except (SQLAlchemyError, DatabaseError) as e:
        logger.error(f"Database error in get_station_routes: {str(e)}")
        raise HTTPException(
            status_code=503,
            detail="Service unavailable due to a database error. Please try again later."
        )
    except Exception as e:
        logger.error(f"Unexpected error in get_station_routes: {str(e)}")
        raise HTTPException(
            status_code=500,
            # detail={str(e)}   # for dev
            detail="An unexpected error occurred."  # for prod
        )


@app.get(
    "/station-trip/",
    response_model=List[StationTripResponse],
    tags=["Station Trip"],
    summary="Retrieve station trip counts (start/end)",
)
def get_station_trip_counts(
    db: Session = Depends(get_db),
    skip: int = Query(0, ge=0, description="Number of records to skip"),
    limit: int = Query(100, ge=1, le=1000,
                       description="Maximum number of records to return"),
) -> List[StationTripResponse]:
    """
    Fetch station trip data from the materialized view.

    Args:
        db: SQLAlchemy session.
        skip: Records to skip for pagination.
        limit: Max number of records to return.

    Returns:
        List of stations with trip counts by start and end.

    Raises:
        HTTPException: On DB errors or unexpected issues.
    """
    logger.info(f"Fetching station trip data with skip={skip}, limit={limit}")
    try:
        query = db.query(MVStationTrip).order_by(
            MVStationTrip.trip_count_by_start.desc())
        result = query.offset(skip).limit(limit).all()
        logger.debug(f"Retrieved {len(result)} records from MV_STATION_TRIP")
        return result
    except (SQLAlchemyError, DatabaseError) as e:
        logger.error(f"Database error in get_station_trip_counts: {str(e)}")
        raise HTTPException(
            status_code=503,
            detail="Service unavailable due to a database error. Please try again later."
        )
    except Exception as e:
        logger.error(f"Unexpected error in get_station_trip_counts: {str(e)}")
        raise HTTPException(
            status_code=500,
            # detail={str(e)}   # for dev
            detail="An unexpected error occurred."  # for prod
        )

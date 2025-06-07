import requests

# Define the API URLs
API_URLS = {
    "home": "https://trip-api-dev.arguswatcher.net/",
    "time_trip": "https://trip-api-dev.arguswatcher.net/time-trip",
    "time_duration": "https://trip-api-dev.arguswatcher.net/time-duration",
    "station_trip": "https://trip-api-dev.arguswatcher.net/station-trip",
    "user_trip_duration": "https://trip-api-dev.arguswatcher.net/user-trip-duration"
}

TITLES = {
    "home": "Toronto Shared Bike Data Analysis Project",
    "time_trip": "Time-based Trip Data",
    "time_duration": "Time-based Duration Data",
    "station_trip": "Station-based Trip Data",
    "user_trip_duration": "User-based Trip & Duration Data"
}

# Test functions for each API URL


def test_home():
    response = requests.get(API_URLS["home"])
    assert response.status_code == 200, f"Expected status code 200, but got {response.status_code}"

    # confirm data in json
    data = response.json()
    assert isinstance(data, dict), f"Data is experted, but got no data"
    assert "title" in data, f"A title is experted, but got no title"
    assert data["title"] == TITLES["home"], f'Title experted: {TITLES["home"]}, but got {data["title"]}'



def test_time_trip():
    response = requests.get(API_URLS["time_trip"])
    assert response.status_code == 200, f"Expected status code 200, but got {response.status_code}"

    # confirm data in json
    data = response.json()
    assert isinstance(data, dict), f"Data is experted, but got no data"
    assert "title" in data, f"A title is experted, but got no title"
    assert data["title"] == TITLES["time_trip"], f'Title experted: {TITLES["time_trip"]}, but got {data["title"]}'



def test_time_duration():
    response = requests.get(API_URLS["time_duration"])
    assert response.status_code == 200, f"Expected status code 200, but got {response.status_code}"

    # confirm data in json
    data = response.json()
    assert isinstance(data, dict), f"Data is experted, but got no data"
    assert "title" in data, f"A title is experted, but got no title"
    assert data["title"] == TITLES["time_duration"], f'Title experted: {TITLES["time_duration"]}, but got {data["title"]}'



def test_station_trip():
    response = requests.get(API_URLS["station_trip"])
    assert response.status_code == 200, f"Expected status code 200, but got {response.status_code}"

    # confirm data in json
    data = response.json()
    assert isinstance(data, dict), f"Data is experted, but got no data"
    assert "title" in data, f"A title is experted, but got no title"
    assert data["title"] == TITLES["station_trip"], f'Title experted: {TITLES["station_trip"]}, but got {data["title"]}'



def test_user_trip_duration():
    response = requests.get(API_URLS["user_trip_duration"])
    assert response.status_code == 200, f"Expected status code 200, but got {response.status_code}"

    # confirm data in json
    data = response.json()
    assert isinstance(data, dict), f"Data is experted, but got no data"
    assert "title" in data, f"A title is experted, but got no title"
    assert data["title"] == TITLES["user_trip_duration"], f'Title experted: {TITLES["user_trip_duration"]}, but got {data["title"]}'

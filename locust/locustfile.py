from locust import HttpUser, task, between

API_URLS = {
    "home": "https://trip-api.arguswatcher.net/",
    "time_trip": "https://trip-api.arguswatcher.net/time-trip",
    "time_duration": "https://trip-api.arguswatcher.net/time-duration",
    "station_trip": "https://trip-api.arguswatcher.net/station-trip",
    "user_trip_duration": "https://trip-api.arguswatcher.net/user-trip-duration"
}
# API_URLS = {
#     "home": "https://trip-api-dev.arguswatcher.net/",
#     "time_trip": "https://trip-api-dev.arguswatcher.net/time-trip",
#     "time_duration": "https://trip-api-dev.arguswatcher.net/time-duration",
#     "station_trip": "https://trip-api-dev.arguswatcher.net/station-trip",
#     "user_trip_duration": "https://trip-api-dev.arguswatcher.net/user-trip-duration"
# }

class WebsiteUser(HttpUser):
    wait_time = between(5, 9)

    @task
    def home(self):
        self.client.get(API_URLS["home"])

    @task
    def time_trip(self):
        self.client.get(API_URLS["time_trip"])

    @task
    def time_duration(self):
        self.client.get(API_URLS["time_duration"])

    @task
    def station_trip(self):
        self.client.get(API_URLS["station_trip"])

    @task
    def user_trip_duration(self):
        self.client.get(API_URLS["user_trip_duration"])

# FastAPI

[Back](../../../README.md)

- [FastAPI](#fastapi)
  - [Local Test](#local-test)
  - [Docker](#docker)
  - [Test](#test)

---

## Local Test

```sh
.\fastapi\.env\Scripts\activate

fastapi run ./fastapi/app/main.py

curl http://localhost:8000/user-segmentation/

uvicorn main:app --reload --host localhost --port 8000
```

---

## Docker

- Docker

```sh
docker build -t fastapiapp_image:v1 ./app
docker run -d --name fastapiApp --env-file ./env/fastapi.env -p 8080:8000 fastapiapp_image:v1

docker stop fastapiApp && docker rm -f fastapiApp
```

- Docker Compose
  - Using `include` feature to include the Oracle DB compose file

```sh
# fastapi/
docker compose -f compose.fastapi.dev.yaml up --build -d
# Test: http://localhost:8081/user-segmentation/

docker compose -f compose.fastapi.dev.yaml down
```

---

## Test

```sh
# https://trip-api.arguswatcher.net/
# https://trip-api.arguswatcher.net/time-tri
# https://trip-api.arguswatcher.net/time-duration
# https://trip-api.arguswatcher.net/station-trip
# https://trip-api.arguswatcher.net/user-trip-duration

docker exec -it fastapi-app-dev pytest /app/test_url_dev.py
```
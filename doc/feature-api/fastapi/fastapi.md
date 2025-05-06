# FastAPI

[Back](../../../README.md)

- [FastAPI](#fastapi)
  - [Local Test](#local-test)

---

## Local Test

```sh
.\fastapi\.env\Scripts\activate

fastapi run ./fastapi/app/main.py

curl http://localhost:8000/user-segmentation/

uvicorn main:app --reload --host localhost --port 8000
```

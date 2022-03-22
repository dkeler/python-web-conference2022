import os
import time

import redis as redis
import uvicorn as uvicorn
from fastapi import FastAPI

API_VERSION = "v1"


def get_app_version():
    try:
        with open('.version', 'r') as v:
            return v.read().removesuffix('\n')
    except FileNotFoundError:
        return "N/A"


def get_app_revision():
    try:
        with open('.revision', 'r') as r:
            return r.read().removesuffix('\n')
    except FileNotFoundError:
        return "N/A"


app = FastAPI(
    title="Python Web Conference 2022",
    version=get_app_version(),
    description=f"""
    Demo Application for Python Web Conference 2022
    
    Revision: {get_app_revision()}
    """
)

cache = redis.Redis(host=os.getenv('REDIS_HOST', 'localhost'), port=os.getenv('REDIS_PORT', 6379))


@app.get("/", tags=["Home"], summary="Home Sweet Home")
async def home():
    body = {
        'message': 'Hello from Python Web Conference 2022',
    }
    if bool(os.getenv("CACHE_ENABLED", False)):
        count = get_hit_count()
        body.update({'hits': count})
    return body


@app.get(f'/api/{API_VERSION}/freetier', tags=["JFrog"], summary="Free Tier instance")
async def home():
    body = {
        'message': 'Time to make your software liquid',
    }
    return body


@app.get(f'/api/{API_VERSION}/liquid', tags=["JFrog"], summary="Imagine there is no version")
async def liquid_software():
    body = {
        'message': 'Get the book at https://liquidsoftware.com/',
    }
    return body


@app.get(f'/api/{API_VERSION}/health', tags=["System"], summary="App Health")
def health_check():
    body = {
        'status': 200,
    }
    return body


@app.get(f'/api/{API_VERSION}/version', tags=["System"], summary="App Version")
def get_version():
    version = get_app_version()
    body = {
        'version': version,
    }
    return body


@app.get(f'/api/{API_VERSION}/revision', tags=["System"], summary="App Revision")
def get_version():
    revision = get_app_revision()
    body = {
        'revision': revision,
    }
    return body


def get_hit_count():
    retries = 5
    while True:
        try:
            return cache.incr('hits')
        except redis.exceptions.ConnectionError as exc:
            if retries == 0:
                raise exc
            retries -= 1
            time.sleep(0.5)


if __name__ == "__main__":
    uvicorn.run("app.app.main:app", host="0.0.0.0", port=8080, reload=True)

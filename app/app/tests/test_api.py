import pytest
from fastapi.testclient import TestClient

from ..main import app

client = TestClient(app)

API_VERSION = "v1"


@pytest.mark.test1
def test_health():
    response = client.get(f"/api/{API_VERSION}/health")
    assert response.status_code == 200
    assert response.json() == {'status': 200}


@pytest.mark.test2
def test_version():
    response = client.get(f"/api/{API_VERSION}/version")
    assert response.status_code == 200
    assert response.json() == {'version': 'N/A'}


@pytest.mark.test3
def test_revision():
    response = client.get(f"/api/{API_VERSION}/revision")
    assert response.status_code == 200
    assert response.json() == {'revision': 'N/A'}

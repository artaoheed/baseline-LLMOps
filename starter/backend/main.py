import os
import time

import psycopg
from fastapi import FastAPI, Response
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel


DB_URL = os.environ.get(
    "DATABASE_URL",
    "postgresql://app:app@db:5432/app",
)

app = FastAPI(title="3-Tier Starter API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


def get_conn(retries: int = 10):
    """Connect to Postgres, retrying while the db container warms up."""
    last_err = None
    for _ in range(retries):
        try:
            return psycopg.connect(DB_URL)
        except Exception as e:  # noqa: BLE001
            last_err = e
            time.sleep(2)
    raise last_err


@app.on_event("startup")
def init_db():
    with get_conn() as conn, conn.cursor() as cur:
        cur.execute(
            "CREATE TABLE IF NOT EXISTS notes ("
            "id SERIAL PRIMARY KEY, body TEXT NOT NULL)"
        )
        conn.commit()


class Note(BaseModel):
    body: str


@app.get("/healthz")
def healthz():
    return {"status": "ok"}

@app.get("/readyz")
def readyz(response: Response):
    try:
        with get_conn(retries=1) as conn, conn.cursor() as cur:
            cur.execute("SELECT 1")
        return {"status": "ready"}
    except Exception:
        response.status_code = 503
        return {"status": "not ready"}


@app.get("/api/notes")
def list_notes():
    with get_conn() as conn, conn.cursor() as cur:
        cur.execute("SELECT id, body FROM notes ORDER BY id DESC")
        rows = cur.fetchall()
    return [{"id": r[0], "body": r[1]} for r in rows]


@app.post("/api/notes")
def add_note(note: Note):
    with get_conn() as conn, conn.cursor() as cur:
        cur.execute(
            "INSERT INTO notes (body) VALUES (%s) RETURNING id",
            (note.body,),
        )
        new_id = cur.fetchone()[0]
        conn.commit()
    return {"id": new_id, "body": note.body}

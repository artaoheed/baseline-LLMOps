# 3-Tier Starter Platform

> Phase 0 of my DevOps/MLOps portfolio. The platform grows one level per phase.

A containerized 3-tier app: **React** frontend → **FastAPI** API → **Postgres** database.

## Run it (one command)

```bash
docker compose up --build
```

- Frontend: http://localhost:5173
- API: http://localhost:8000 (health: `/healthz`, data: `/api/notes`)

`docker compose down` to stop. `docker compose down -v` to also wipe the DB volume.

## Architecture

```mermaid
flowchart LR
    User([User])
    Web[Frontend<br/>static / templates]
    API[Flask API<br/>:5000]
    DB[(Postgres<br/>:5432)]

    User -->|HTTP :8080| Web
    Web -->|REST /api| API
    API -->|psycopg2| DB

    classDef tier fill:#1f2937,stroke:#60a5fa,color:#fff
    class Web,API,DB tier
```
## What's next

# platform — Helm chart

Packages the 3-tier app (FastAPI API + Postgres) for local Kubernetes (kind).
Phase 1 of the DevOps/MLOps portfolio. React frontend tier is pending.

## Install

```bash
# 1. Create your secrets override (never commit it)
cp secrets.values.yaml.example secrets.values.yaml
echo "secrets.values.yaml" >> .gitignore   # edit values first

# 2. Validate
helm lint ./platform -f secrets.values.yaml
helm install platform ./platform -f secrets.values.yaml --dry-run --debug

# 3. Install for real
helm install platform ./platform -f secrets.values.yaml

# 4. Watch it come up
kubectl get pods -l app.kubernetes.io/instance=platform -w
```

## What you must set before installing
- `api.image.repository` / `tag` — the FastAPI image you `kind load`ed
- secrets in `secrets.values.yaml`
- (optional) flip `api.probes.type` to `http` + set `httpPath` once your health route is confirmed

## Upgrade / uninstall
```bash
helm upgrade platform ./platform -f secrets.values.yaml
helm uninstall platform
```

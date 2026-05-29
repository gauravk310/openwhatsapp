# OpenWA Deployment Guide

## Overview
This guide explains how to deploy the OpenWA project with all required configurations, using both development and production Docker workflows.

## Prerequisites
- Docker 24+ and Docker Compose
- Git
- Optional: Node.js 20+ and npm for local development or dashboard build
- Optional: PostgreSQL, Redis, MinIO if you want production-grade services instead of built-in containers

## Deployment Modes
- `production` — use `docker-compose.yml` with optional service profiles

---

## 1. Clone the Repository

```bash
git clone https://github.com/rmyndharis/OpenWA.git
cd OpenWA
```

## 2. Configure Environment Variables

Use the production Compose file and set the required environment variables for your deployment.

The production Compose file supports the following configuration variables:

- `NODE_ENV` — `production`
- `API_PORT` — API listening port, default `2785`
- `DATABASE_TYPE` — `sqlite` or `postgres`
- `DATABASE_NAME` — SQLite file path or PostgreSQL database name
- `DATABASE_HOST` — PostgreSQL host
- `DATABASE_PORT` — PostgreSQL port
- `DATABASE_USERNAME` — DB user
- `DATABASE_PASSWORD` — DB password
- `DATABASE_SYNCHRONIZE` — `true` or `false`
- `ENGINE_TYPE` — WhatsApp engine, default `whatsapp-web.js`
- `SESSION_DATA_PATH` — session storage path
- `PUPPETEER_HEADLESS` — `true` or `false`
- `PUPPETEER_ARGS` — Chromium flags
- `STORAGE_TYPE` — `local` or `s3`
- `STORAGE_LOCAL_PATH` — local media storage path
- `S3_ENDPOINT` / `S3_ACCESS_KEY` / `S3_SECRET_KEY` / `S3_BUCKET` — S3-compatible storage config
- `REDIS_ENABLED` — `true` or `false`
- `REDIS_HOST` / `REDIS_PORT`
- `WEBHOOK_TIMEOUT` / `WEBHOOK_MAX_RETRIES` / `WEBHOOK_RETRY_DELAY`
- `RATE_LIMIT_TTL` / `RATE_LIMIT_MAX`
- `PLUGINS_ENABLED`
- `PLUGINS_DIR`
- `API_MASTER_KEY` — optional API security master key

---

## 3. Production Deployment (Docker)

### 4.1 Basic production stack

```bash
docker compose up -d
```

This starts:
- `openwa-api`
- optionally `postgres`, `redis`, `minio`, `dashboard`, `traefik` based on chosen profiles

### 4.2 Production profiles

Available profiles in `docker-compose.yml`:
- `postgres` — built-in PostgreSQL
- `redis` — built-in Redis cache
- `minio` — built-in MinIO S3 storage
- `with-dashboard` — OpenWA dashboard service
- `with-proxy` — Traefik reverse proxy
- `full` — all optional services

Example full stack:

```bash
docker compose --profile full up -d
```

Example with PostgreSQL only:

```bash
docker compose --profile postgres up -d
```

### 4.3 Exposed ports
- API: `2785`
- Dashboard: `2886`
- Traefik dashboard: `8080`
- MinIO: `9000`
- MinIO console: `9001`

> Note: `docker-compose.yml` binds the API and dashboard ports to `127.0.0.1` by default.

---

## 4. Dashboard Deployment

The dashboard is built from `dashboard/Dockerfile.traefik` in production and `dashboard/Dockerfile` in development.

If you need to build locally:

```bash
cd dashboard
npm install
npm run build
npm run preview
```

Important environment variable for the dashboard:
- `VITE_API_URL` — backend API URL, for example `http://localhost:2785`

---

## 5. Building the API Image Locally

The main backend Dockerfile is multi-stage and builds a production-ready Node image.

```bash
docker build -t openwa-api:latest .
```

Or rebuild and restart with Compose:

```bash
docker compose up -d --build
```

---

## 6. Database Options

### SQLite (default development)
- Uses `./data/openwa.sqlite`
- Easy local setup
- Not recommended for high-scale production

### PostgreSQL
- Enable with `--profile postgres` or external Postgres service
- Set:
  - `DATABASE_TYPE=postgres`
  - `DATABASE_HOST`
  - `DATABASE_PORT`
  - `DATABASE_USERNAME`
  - `DATABASE_PASSWORD`
  - `DATABASE_NAME`
- Set `DATABASE_SYNCHRONIZE=false` in production

---

## 7. Storage Options

### Local storage
- `STORAGE_TYPE=local`
- `STORAGE_LOCAL_PATH=/app/data/media`

### S3-compatible storage
- `STORAGE_TYPE=s3`
- `S3_ENDPOINT`
- `S3_ACCESS_KEY`
- `S3_SECRET_KEY`
- `S3_BUCKET`

Use the `minio` profile for a built-in S3-compatible service.

---

## 8. Redis / Queue Options

You can enable Redis as an optional cache and queue backend.

Set:
- `REDIS_ENABLED=true`
- `REDIS_HOST`
- `REDIS_PORT`

Enable the built-in Redis service with:

```bash
docker compose --profile redis up -d
```

For production queue usage, set `QUEUE_ENABLED=true` and use a Redis-backed queue.

---

## 9. Security and API Access

- Add `API_MASTER_KEY` to protect API access in production.
- Use HTTPS or proxy TLS termination when exposing the API publicly.
- If using Traefik, configure a secure router and certificates in `traefik/`.

### 9.1 Create an API key using Postman

1. Open Postman and create a new `POST` request.
2. Set the URL to your API endpoint:
   - `http://<host>:2785/api/api-keys`
3. Add headers:
   - `Content-Type: application/json`
   - `X-API-Key: <your-master-key>`
4. In the request body, choose `raw` and `JSON`, then paste a payload such as:
   ```json
   {
     "name": "Integration Key",
     "permissions": ["sessions:read", "messages:write"],
     "sessionAccess": ["default"],
     "rateLimit": 100,
     "expiresAt": "2027-01-01T00:00:00Z"
   }
   ```
5. Send the request.
6. Copy the returned `key` from the response; it is only shown once at creation.

> Use the returned API key for subsequent requests with `X-API-Key: <your-api-key>` or `Authorization: Bearer <your-api-key>`.

---

## 10. Common Commands

Start development stack:
```bash
docker compose -f docker-compose.dev.yml up -d
```

Start production stack with full optional services:
```bash
docker compose --profile full up -d
```

Rebuild service images:
```bash
docker compose up -d --build
```

Stop services:
```bash
docker compose down
```

View logs:
```bash
docker compose logs -f
```

Inspect running containers:
```bash
docker compose ps
```

---

## 11. Troubleshooting

- If the API fails health checks, inspect logs with `docker compose logs openwa-api`.
- If the dashboard cannot reach the API, verify `VITE_API_URL` and network connectivity.
- If session data is missing, ensure `SESSION_DATA_PATH` is mounted correctly and writeable.
- For Puppeteer failures, verify `PUPPETEER_HEADLESS` and `PUPPETEER_ARGS` values.

---

## 12. Recommended Production Checklist

- Use `DATABASE_TYPE=postgres` for reliability
- Use `STORAGE_TYPE=s3` or external storage for media
- Enable Redis for caching and queueing
- Set `API_MASTER_KEY`
- Run behind a reverse proxy such as Traefik
- Back up `./data` volume and database regularly
- Monitor container health and restart policies

---

## 13. Useful Paths

- Backend app: `/app/dist`
- Session storage: `/app/data/sessions`
- Media storage: `/app/data/media`
- SQLite file: `/app/data/openwa.sqlite`
- Dashboard source: `dashboard/`

---

## 14. Notes

- The dashboard is optional but recommended for session management.
- The project supports multiple session directories via `SESSION_DATA_PATH`.
- `docker-compose.dev.yml` is best for local development and testing.
- `docker-compose.yml` is best for production with service profiles.

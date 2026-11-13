# Exercise 2.11: containerized development environment

I containerized the development environment of the course example app (the React frontend and the Go backend in `example-app/`). The setup lives in `2_11/docker-compose.yaml`.

## What the setup contains

- `frontend-dev`: Node 16 container. The frontend source is bind mounted into the container, so edits made on the host are picked up immediately by the React development server (hot reload) on http://localhost:3000. `node_modules` is kept in an anonymous volume, so the bind mount does not hide the installed packages.
- `backend-dev`: built from `example-app/backend` with its Dockerfile, on http://localhost:8080 (for example `GET /ping` returns `pong`). The backend is configured with `REQUEST_ORIGIN=http://localhost:3000` for the development server.
- `redis-dev`: Redis for the backend cache, reached as `redis-dev` inside the compose network.
- `db-dev`: Postgres 16 for the backend, reached as `db-dev`; its data is bind mounted to `./database` so it survives container restarts.

## How to use it

```
cd 2_11
docker compose up -d --build
```

Open http://localhost:3000 in the browser, edit a file under `example-app/frontend/src` on the host, and refresh the page to see the change. The first start runs `npm install` inside the container; installed packages are cached in the anonymous `node_modules` volume, so later starts are fast. Stop everything with `docker compose down`.

## Verification

- `curl http://localhost:3000/` returns HTTP 200 (React development server).
- `curl http://localhost:8080/ping` returns `pong`.
- Editing a source file on the host is reflected in the container without rebuilding the image, because the source is bind mounted.

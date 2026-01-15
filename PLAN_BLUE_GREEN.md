# Blue/Green Deployment Plan

## 🎯 Goal

Implement a blue/green deployment strategy using Docker Compose and a reverse proxy (Nginx) to allow:

* Zero-downtime deployment
* Instant rollback
* Two application versions running side-by-side
* One shared PostgreSQL database

---

## 🧱 Architecture

* One PostgreSQL database (shared)
* One Nginx reverse proxy (public entrypoint)
* Two application stacks:

  * Blue: backend-blue, frontend-blue
  * Green: backend-green, frontend-green

Only one color receives traffic at a time.

---

## 📁 Docker Compose Structure

* docker-compose.base.yml

  * postgres
  * reverse-proxy

* docker-compose.blue.yml

  * backend-blue
  * frontend-blue

* docker-compose.green.yml

  * backend-green
  * frontend-green

---

## ▶️ How the stack is started

Initial deployment (blue):

```
docker compose -f docker-compose.base.yml -f docker-compose.blue.yml up -d
```

Deploy green without touching blue:

```
docker compose -f docker-compose.base.yml -f docker-compose.green.yml up -d
```

---

## 🔀 How traffic switching works

The active color is stored in a file:

```
active_color.env
ACTIVE_COLOR=blue
```

This file is mounted into the Nginx container.

Nginx uses this variable to route traffic to:

* backend-blue / frontend-blue
  OR
* backend-green / frontend-green

To switch version:

* The CI updates the value of ACTIVE_COLOR
* Then reloads Nginx:

```
docker exec reverse-proxy nginx -s reload
```

This causes an instant traffic switch with no downtime.

---

## 🚀 Deployment scenario

Initial state:

* Blue is in production
* Green is stopped or outdated

When a new version is deployed:

1. The CI checks which color is active
2. It deploys the new version on the inactive color
3. It updates ACTIVE_COLOR
4. It reloads Nginx
5. Traffic is now routed to the new version

---

## 🔁 Rollback strategy

If the new version is broken:

1. Set ACTIVE_COLOR back to the previous value
2. Reload Nginx

Traffic is instantly routed back to the previous version.

No container needs to be rebuilt.

---

## ✅ Mandatory property

At no point is the currently active version stopped before the new one is ready.

This guarantees:

* No downtime
* Instant rollback
* Safe deployments
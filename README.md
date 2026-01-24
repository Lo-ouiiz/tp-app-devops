# Gym Management System

[![CI](https://github.com/Lo-ouiiz/tp-app-devops/actions/workflows/ci.yml/badge.svg)](https://github.com/Lo-ouiiz/tp-app-devops/actions)
[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=Lo-ouiiz_tp-app-devops&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=Lo-ouiiz_tp-app-devops)

A fullstack gym management application built with modern web technologies, featuring **automated CI/CD**.

---

## Table of Contents

1. [Git Workflow & Conventions](#git-workflow--conventions)
2. [CI/CD Pipeline](#cicd-pipeline)
3. [Blue/Green Deployment](#bluegreen-deployment)
4. [Features](#features)
5. [Tech Stack](#tech-stack)
6. [Monitoring Stack](#monitoring-stack)
7. [Quick Start](#quick-start)
8. [Docker Setup](#docker-setup)
9. [Project Structure](#project-structure)
10. [API Endpoints](#api-endpoints)
11. [Contributing](#contributing)
12. [License](#license)
13. [Support](#support)

---

## Git Workflow & Conventions

### Git Rules
- Main branches: `main`, `develop`  
- Feature branches: `feature/<name>`  
- Pull Requests required to merge into `develop`  
- **No direct commits to `main` or `develop`**

### Commit Convention
- Format: **Conventional Commits** → `type: description`  
- Allowed types: `build`, `chore`, `ci`, `docs`, `feat`, `fix`, `perf`, `refactor`, `revert`, `style`, `test`  
- Examples:
  - `feat: add authentication`
  - `fix: correct Postgres connection`
  - `chore: update NestJS dependencies`

### Active Git Hooks
- **pre-commit**: runs frontend + backend lint  
- **commit-msg**: enforces commit message convention  
- **pre-push**: builds frontend

> Just because it commits doesn’t mean it deserves to be shared.

---

## CI/CD Pipeline

This project uses **GitHub Actions** on a self-hosted runner.

### Pipeline steps

```
┌──────────┐
│   Lint   │ → frontend + backend
└────┬─────┘
     ↓
┌──────────┐
│  Build   │ → frontend + backend
└────┬─────┘
     ↓
┌──────────┐
│  Tests   │ → backend (Jest)
└────┬─────┘
     ↓
┌────────────┐
│ SonarCloud │ → Quality Gate
└────┬───────┘
     ↓
┌──────────┐
│  Docker  │ → build & push
└────┬─────┘
     ↓
┌──────────┐
│  Deploy  │ → with Docker Compose
└──────────┘
```

### Rules
- PR cannot be merged if:
  - Lint fails
  - Build fails
  - Tests fail
  - SonarCloud Quality Gate fails

- Automatic deployment occurs only on the **develop branch**.

---

## Blue/Green Deployment

This project implements a **Blue/Green deployment strategy** using **Docker Compose** and an **Nginx reverse proxy**.

### Principle
- **Blue** = currently active in production  
- **Green** = new version (or vice versa)  
- Only **one color receives user traffic**, both can run side-by-side.

### Reverse Proxy
- Listens on: `http://localhost`  
- Routes traffic to active stack (**blue** or **green**) based on `ACTIVE_COLOR`:

```
[Client] --> [Reverse Proxy] --> [Blue]   (active version)
                             \-> [Green]  (inactive / candidate version)
```

### Deployment Workflow
1. CI builds and pushes new Docker images  
2. CI checks currently active color  
3. Deploys new version on **inactive color**  
4. Updates `ACTIVE_COLOR`  
5. Restarts reverse proxy → traffic instantly switches  
6. Old version still running → can rollback if needed

### Rollback
1. Set `ACTIVE_COLOR` back to previous color  
2. Restart reverse proxy  
Traffic switches immediately **without downtime**.

---

## Features

### User Features
- **Dashboard**: Stats, billing, and recent bookings  
- **Class Booking**: Book/cancel fitness classes  
- **Subscription Management**: View and manage subscriptions  
- **Profile Management**: Update personal info

### Admin Features
- **Admin Dashboard**: Overview of stats and revenue  
- **User Management**: CRUD users  
- **Class Management**: Create/update/delete classes  
- **Booking Management**: Manage all bookings  
- **Subscription Management**: Manage user subscriptions

### Business Rules
- Max capacity per class  
- Prevent double-booking  
- 2-hour cancellation policy  
- Dynamic billing with no-show penalties  

---

## Tech Stack

### Backend
- Node.js, Express.js  
- PostgreSQL via Prisma ORM  
- REST API  
- MVC architecture with repositories

### Frontend
- Vue 3 + Composition API  
- Pinia for state management  
- Vue Router with guards  
- Responsive CSS

### DevOps
- Docker + Docker Compose  
- Nginx reverse proxy  
- PostgreSQL database  
- GitHub Actions for CI/CD

---

## Monitoring Stack

This project includes a full **monitoring stack** with **Prometheus**, **Grafana**, and **Loki/Promtail** to collect metrics and logs from the backend.

### Launching the Monitoring Stack

1. Make sure your Docker Compose environment is up:
"""
docker-compose up -d
"""

2. Start the monitoring stack:
"""
docker-compose -f docker-compose.monitoring.yml up -d
"""
> This will start:
> - **Prometheus** → http://localhost:9090  
> - **Grafana** → http://localhost:3001  
> - **Loki** → internal, used by Promtail  
> - **Promtail** → collects logs from `gym-backend` and forwards them to Loki

3. Verify logs and metrics:
"""
docker-compose logs -f promtail
docker-compose logs -f prometheus
docker-compose logs -f grafana
"""

4. Access Grafana to explore metrics and logs:
- Explore Loki logs: http://localhost:3001/explore  
- View Prometheus metrics: http://localhost:3001/explore → select Prometheus data source

### Notes
- Logs are collected from the backend container via **Promtail**  
- Metrics are scraped from `/metrics` endpoint of `gym-backend`  
- Make sure you generate some traffic (API requests) so metrics and logs appear in dashboards

---

## Quick Start

### Prerequisites
- Docker & Docker Compose  
- Git  

### Installation
1. Clone repo
```
git clone <repository-url>
cd gym-management-system
```

2. Setup env
```
cp .env.example .env
```

3. Start app
```
docker-compose up --build
```

4. Access
- Frontend: http://localhost:8080  
- Backend API: http://localhost:3000  
- DB: localhost:5432

---

## Docker Setup

- GHCR images:
  - Backend: `ghcr.io/lo-ouiiz/cloudnative-backend:<commit_sha>`  
  - Frontend: `ghcr.io/lo-ouiiz/cloudnative-frontend:<commit_sha>`

- Useful commands:
```
docker-compose down
docker-compose logs -f [service]
docker-compose up --build [service]
docker exec -it gym-postgres psql -U postgres -d gymdb
```

### Default Login Credentials

The application comes with seeded test data:

**Admin User:**
- Email: admin@gym.com
- Password: admin123
- Role: ADMIN

**Regular Users:**
- Email: john.doe@email.com
- Email: jane.smith@email.com  
- Email: mike.wilson@email.com
- Password: password123 (for all users)

## Project Structure

```
gym-management-system/
├── backend/
│   ├── src/
│   │   ├── controllers/     # Request handlers
│   │   ├── services/        # Business logic
│   │   ├── repositories/    # Data access layer
│   │   ├── routes/          # API routes
│   │   └── prisma/          # Database schema and client
│   ├── seed/                # Database seeding
│   └── Dockerfile
├── frontend/
│   ├── src/
│   │   ├── views/           # Vue components/pages
│   │   ├── services/        # API communication
│   │   ├── store/           # Pinia stores
│   │   └── router/          # Vue router
│   ├── Dockerfile
│   └── nginx.conf
└── docker-compose.*.yml
```

---

## API Endpoints

### Authentication
- `POST /api/auth/login` - User login

### Users
- `GET /api/users` - Get all users
- `GET /api/users/:id` - Get user by ID
- `POST /api/users` - Create user
- `PUT /api/users/:id` - Update user
- `DELETE /api/users/:id` - Delete user

### Classes
- `GET /api/classes` - Get all classes
- `GET /api/classes/:id` - Get class by ID
- `POST /api/classes` - Create class
- `PUT /api/classes/:id` - Update class
- `DELETE /api/classes/:id` - Delete class

### Bookings
- `GET /api/bookings` - Get all bookings
- `GET /api/bookings/user/:userId` - Get user bookings
- `POST /api/bookings` - Create booking
- `PUT /api/bookings/:id/cancel` - Cancel booking
- `DELETE /api/bookings/:id` - Delete booking

### Subscriptions
- `GET /api/subscriptions` - Get all subscriptions
- `GET /api/subscriptions/user/:userId` - Get user subscription
- `POST /api/subscriptions` - Create subscription
- `PUT /api/subscriptions/:id` - Update subscription

### Dashboard
- `GET /api/dashboard/user/:userId` - Get user dashboard
- `GET /api/dashboard/admin` - Get admin dashboard

---
## Features in Detail

### Subscription System
- **STANDARD**: €30/month, €5 per no-show
- **PREMIUM**: €50/month, €3 per no-show  
- **ETUDIANT**: €20/month, €7 per no-show

### Booking Rules
- Users can only book future classes
- Maximum capacity per class is enforced
- No double-booking at the same time slot
- 2-hour cancellation policy

### Admin Dashboard
- Total users and active subscriptions
- Booking statistics (confirmed, no-show, cancelled)
- Monthly revenue calculations
- User management tools

### User Dashboard
- Personal statistics and activity
- Current subscription details
- Monthly billing with no-show penalties
- Recent booking history

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License.

## Support

For support or questions, please open an issue in the repository.

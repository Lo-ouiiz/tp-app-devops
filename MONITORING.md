# Observabilité et Monitoring de l'application Gym

## 1. Introduction

Ce document décrit la stack de monitoring et d’observabilité déployée pour l’application conteneurisée Vue + NestJS + Postgres.  
L’objectif est de fournir une **vision complète des métriques et des logs**, permettant de surveiller et diagnostiquer l’application en production locale.

---

## 2. Stack de monitoring

| Composant | Rôle | Port par défaut |
|-----------|------|----------------|
| **Prometheus** | Collecte et stocke les métriques exposées par le backend et les services Docker | 9090 |
| **Grafana** | Visualisation des métriques et logs, création de dashboards | 3001 |
| **Loki** | Stockage et requêtage des logs centralisés | 3100 (interne) |
| **Promtail** | Collecte les logs des conteneurs Docker et les envoie à Loki | N/A |

---

## 3. Architecture globale

```text
                    ┌─────────────┐
                    │ Grafana     │
                    │ 3000        │
                    └─────┬───────┘
                          │
             ┌────────────┴─────────────┐
             │                          │
       ┌──────────────┐           ┌───────────┐
       │ Prometheus   │           │ Loki      │
       │ 9090         │           │ 3100      │
       └─────┬────────┘           └─────┬─────┘
             │                          │
     Scrape metrics                 Push logs
             │                          │
       ┌──────────────┐           ┌───────────┐
       │ NestJS App   │           │ Promtail  │
       │ Backend      │           │ Agent     │
       └──────────────┘           └───────────┘
             │
             │
       ┌──────────────┐
       │ Postgres /   │
       │ autres cont. │
       └──────────────┘
```
- **Flèches** :  
  - `Scrape metrics` : Prometheus récupère `/metrics` du backend  
  - `Push logs` : Promtail envoie les logs Docker vers Loki  
  - Grafana lit à la fois Prometheus et Loki pour créer les dashboards

---

## 4. Intégration de l’application

- Backend NestJS expose un endpoint `/metrics`
- Docker Compose assure que tous les services sont sur le même réseau `gym-network`
- Prometheus scrape le backend
- Promtail lit les logs des conteneurs (`/var/lib/docker/containers`) et les envoie à Loki
- Grafana visualise les **métriques backend** et les **logs corrélés**

---

## 5. Ports d’accès

| Service | URL locale |
|---------|------------|
| Prometheus | http://localhost:9090 |
| Grafana | http://localhost:3000 |
| Loki | interne : 3100 |
| NestJS Backend | http://localhost:3000 |
| Frontend Vue | http://localhost:8080 |
# 📊 Monitoring Stack - Prometheus & Grafana

**Documentation complète du monitoring DevOps Infrastructure**

**🎯 Surveille : Jenkins, SonarQube, Portfolio + Infrastructure système**

---

## 📑 Table des Matières

1. [Introduction](#-introduction)
2. [Architecture](#-architecture)
3. [Prérequis](#-prérequis)
4. [Installation](#-installation)
5. [Configuration Grafana](#-configuration-grafana)
6. [Dashboards](#-dashboards)
7. [Démonstration](#-démonstration)
8. [Système d'Alertes](#-système-dalertes)
9. [Vérification](#-vérification)
10. [Déploiement Git](#-déploiement-git)
11. [Troubleshooting](#-troubleshooting)
12. [Commandes Utiles](#-commandes-utiles)

---

## 🎯 Introduction

Stack de monitoring complète pour superviser une infrastructure DevOps. Elle permet de surveiller en temps réel l'état des serveurs, la disponibilité des services (Jenkins, SonarQube, Portfolio), et de recevoir des alertes automatiques en cas de problème.

**Objectif :** répondre à "Est-ce que tout fonctionne ?" et surtout "Comment être prévenu AVANT que ça casse ?"

**Composants (7 services) :**
- **Prometheus** (9090) - Collecte et stockage des métriques (modèle pull, scrape toutes les 15s)
- **Grafana** (3005) - Visualisation et dashboards
- **Alertmanager** (9093) - Gestion intelligente des alertes
- **Blackbox Exporter** (9115) - Probes HTTP pour Jenkins/SonarQube/Portfolio
- **Node Exporter** (9100) - Métriques système (CPU, RAM, disque, réseau)
- **MongoDB Exporter** (9216) - Métriques base de données
- **cAdvisor** (8081) - Métriques conteneurs Docker

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                  DEVOPS MONITORING STACK                     │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐     ┌──────────────┐     ┌──────────────┐│
│  │   Jenkins    │────▶│   Blackbox   │────▶│  Prometheus  ││
│  │   :8080      │     │   Exporter   │     │   :9090      ││
│  │              │     │   :9115      │     │              ││
│  └──────────────┘     └──────────────┘     └──────────────┘│
│                              │                      │        │
│  ┌──────────────┐             │                      ▼        │
│  │  SonarQube   │─────────────┘              ┌──────────────┐│
│  │   :9000      │                            │   Grafana    ││
│  │              │                            │   :3005      ││
│  └──────────────┘                            │              ││
│                                               └──────────────┘│
│  ┌──────────────┐     ┌──────────────┐              │        │
│  │  Portfolio   │─────│ Node Exporter│              ▼        │
│  │   :3000      │     │   :9100      │     ┌──────────────┐│
│  │              │     │              │     │ Alertmanager ││
│  └──────────────┘     └──────────────┘     │   :9093      ││
│                                               └──────────────┘│
│  ┌──────────────┐     ┌──────────────┐                       │
│  │   MongoDB    │     │   cAdvisor   │                       │
│  │ Exporter :9216     │   :8081      │                       │
│  └──────────────┘     └──────────────┘                       │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

### Flux de données

1. **Collection (Pull)** : Prometheus scrape les targets toutes les 15s
2. **Stockage** : TSDB Prometheus (rétention 30 jours)
3. **Alerting** : Prometheus évalue les règles → Alertmanager → notifications
4. **Visualisation** : Grafana requête Prometheus → dashboards temps réel

### Sources de données

**Blackbox Exporter** teste les services comme un utilisateur (boîte noire) :
- Jenkins : `http://host.docker.internal:8080`
- SonarQube : `http://host.docker.internal:9000`
- Portfolio : `http://host.docker.internal:3000`
- Métriques : `probe_success` (0/1), `probe_duration_seconds`, `probe_http_duration_seconds`

**Node Exporter** : `node_cpu_seconds_total`, `node_memory_*`, `node_filesystem_*`, `node_network_*`, `node_load1/5/15`

**MongoDB Exporter** : opérations, connexions, performance des requêtes

**cAdvisor** : `container_cpu_usage_seconds_total`, `container_memory_usage_bytes`, etc.

### Réseaux Docker
- **portfolio-monitoring** : réseau interne monitoring
- **projet_fil_rouge_portfolio-network** : réseau externe (backend/mongodb)

---

## ✅ Prérequis

- ✓ **Docker Desktop** installé et démarré
- ✓ **Jenkins** accessible sur http://localhost:8080
- ✓ **SonarQube** accessible sur http://localhost:9000
- ✓ **Portfolio (Frontend)** accessible sur http://localhost:3000
- ✓ **PowerShell** ou terminal Windows
- ✓ 2GB RAM disponible, 5GB espace disque

### Vérifier les prérequis

```powershell
docker --version
docker ps

curl http://localhost:8080   # Jenkins
curl http://localhost:9000   # SonarQube
curl http://localhost:3000   # Portfolio
```

---

## 🚀 Installation

### Étape 1 : Démarrer le Stack

```powershell
cd C:\laragon\www\projet_fil_rouge\monitoring
docker-compose -f docker-compose.monitoring.yml up -d
```

**Temps d'attente :** ~30-60 secondes (première fois pour télécharger les images)

### Étape 2 : Vérifier les Conteneurs

```powershell
docker ps --filter "name=portfolio-" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

**Résultat attendu : 7 conteneurs UP**
```
portfolio-prometheus         Up    0.0.0.0:9090->9090/tcp
portfolio-grafana            Up    0.0.0.0:3005->3000/tcp
portfolio-alertmanager       Up    0.0.0.0:9093->9093/tcp
portfolio-blackbox-exporter  Up    0.0.0.0:9115->9115/tcp
portfolio-node-exporter      Up    0.0.0.0:9100->9100/tcp
portfolio-mongodb-exporter   Up    0.0.0.0:9216->9216/tcp
portfolio-cadvisor           Up (healthy)  0.0.0.0:8081->8080/tcp
```

### Étape 3 : Vérifier Prometheus

1. Ouvrir http://localhost:9090
2. **Status → Targets** : toutes les targets doivent être **UP** (vertes)

| Job | État | Endpoint |
|-----|------|----------|
| prometheus | UP | localhost:9090 |
| blackbox-exporter | UP | blackbox-exporter:9115 |
| jenkins-http | UP | via Blackbox |
| sonarqube-http | UP | via Blackbox |
| portfolio-http | UP | via Blackbox |
| node-exporter | UP | node-exporter:9100 |
| mongodb | UP | mongodb-exporter:9216 |
| cadvisor | UP | cadvisor:8080 |
| alertmanager | UP | alertmanager:9093 |
| grafana | UP | grafana:3000 |

---

## 📈 Configuration Grafana

### Connexion

Ouvrir http://localhost:3005

- Username : `admin`
- Password : `admin123`

### Datasource & Dashboards (auto-provisionnés)

La datasource Prometheus et les dashboards sont chargés automatiquement au démarrage via les fichiers de provisioning. Aucune configuration manuelle nécessaire.

Si besoin de vérifier : **☰ → Connections → Data sources → prometheus → Save & test**

---

## 📊 Dashboards

### 1. Node Exporter - Infrastructure

Vue complète de la santé de la machine.

- **4 jauges** : CPU, Mémoire, Disque, Node Status (vert/jaune/rouge)
- **CPU Details by Mode** : user/system/iowait
- **Load Average** : charge 1m/5m/15m
- **Memory Usage** : utilisée/cache/libre
- **Disk I/O** : lecture/écriture bytes/s
- **Network Traffic** : RX/TX par interface

### 2. DevOps Services

Le dashboard le plus important pour le pipeline CI/CD : "Est-ce que mes outils sont disponibles ?"

- **3 indicateurs UP/DOWN** : Jenkins, SonarQube, Portfolio
- **Temps de réponse** par service (seuils : warning si > 3-5s)
- **Response Time History** : évolution dans le temps
- **HTTP Phases** : DNS/Connect/Processing/Transfer
- **Uptime %** : disponibilité sur la dernière heure

### 3. Prometheus & Alerting Health

Surveillance du système de monitoring lui-même.

- Status de chaque target
- Durée des scrapes (idéalement < 1s)
- Séries temporelles actives
- Mémoire Prometheus
- Alertes actives/pending
- Notifications Alertmanager

### Seuils colorés des jauges

| Métrique | 🟢 Vert | 🟡 Jaune | 🔴 Rouge |
|----------|---------|----------|----------|
| CPU | < 70% | 70-90% | > 90% |
| Mémoire | < 80% | 80-95% | > 95% |
| Disque | < 80% | 80-90% | > 90% |

---

## 🎬 Démonstration

### Ordre de présentation recommandé

1. **Architecture** (5 min) - présentation des composants
2. **Prometheus** (5 min) - Targets, PromQL, Alerts
3. **Grafana** (8 min) - les 3 dashboards
4. **Test d'alerte** (3 min) - simulation incident
5. **Questions** (4 min)

### URLs à ouvrir (dans l'ordre)

| Ordre | URL | Quoi montrer |
|-------|-----|--------------|
| 1 | http://localhost:9090/targets | Tous les targets UP |
| 2 | http://localhost:9090/graph | Requête PromQL live |
| 3 | http://localhost:9090/alerts | Règles d'alertes |
| 4 | http://localhost:3005 | Login Grafana |
| 5 | Dashboard Node Exporter | Jauges + graphiques infra |
| 6 | Dashboard DevOps Services | Status Jenkins/Sonar/Portfolio |
| 7 | Dashboard Prometheus Health | Santé du monitoring |
| 8 | http://localhost:9093 | Alertmanager |

### Requêtes PromQL pour la démo

```promql
# Status des services (1 = UP, 0 = DOWN)
probe_success

# Utilisation CPU en %
100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Mémoire utilisée en %
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100

# Temps de réponse des services
probe_duration_seconds

# Toutes les alertes actives
ALERTS{alertstate="firing"}
```

### Lien avec le Pipeline CI/CD

```
Code → Jenkins (CI) → SonarQube (Quality) → Docker → K8s (Deploy) → Portfolio
                                                                          |
                                                        Prometheus scrape ici
                                                        Grafana visualise ici
                                                        Alertes si problème
```

Le monitoring ferme la boucle : si un déploiement casse le portfolio, le probe échoue en moins de 2 minutes et l'équipe est notifiée.

---

## 🚨 Système d'Alertes

### Groupes d'alertes

1. **node_alerts** : infrastructure (CPU, RAM, disque, réseau)
2. **services_alerts** : Jenkins, SonarQube, Portfolio (UP/DOWN, latence)
3. **prometheus_alerts** : auto-surveillance du monitoring

### États des alertes

- 🟢 **inactive** : tout va bien
- 🟡 **pending** : condition vraie mais durée pas encore atteinte
- 🔴 **firing** : problème confirmé, notification envoyée

### Simulation d'incident

```powershell
# Arrêter un service
docker stop sonarqube
```

**Chaîne d'événements :**
1. **T+0s** : Blackbox essaie de joindre SonarQube → échec
2. **T+15s** : Prometheus scrape → `probe_success = 0`
3. **T+15s** : règle SonarQubeDown passe en "pending"
4. **T+2min** : l'alerte passe en "firing"
5. **T+2min** : Prometheus envoie à Alertmanager
6. **T+2min+10s** : Alertmanager envoie la notification

```powershell
# Résoudre l'incident
docker start sonarqube
```

Après quelques secondes, le probe réussit, l'alerte se résout, Alertmanager envoie une notification "resolved".

### Routing par sévérité

- **critical** : re-notifié toutes les 5 minutes (urgence)
- **warning** : re-notifié toutes les heures (surveillance)

### Inhibition

Si une alerte `critical` et une `warning` existent pour la même instance, le warning est supprimé automatiquement (évite le spam).

### Silences (maintenance)

Dans Alertmanager (http://localhost:9093), créer un silence :
- Sélectionner le matcher `service = jenkins`
- Définir une durée (ex: 1 heure)
- Aucune alerte Jenkins ne sera notifiée pendant cette période

---

## ✅ Vérification

### Checklist complète avant démonstration

**Infrastructure DevOps**
- [ ] Docker Desktop démarré
- [ ] Jenkins accessible (8080)
- [ ] SonarQube accessible (9000)
- [ ] Portfolio accessible (3000)

**Conteneurs Monitoring**
- [ ] 7 conteneurs UP (`docker ps`)
- [ ] cadvisor en (healthy)

**Prometheus**
- [ ] Interface accessible (9090)
- [ ] Toutes les targets UP
- [ ] `probe_success` = 1 pour les 3 services
- [ ] Règles d'alertes chargées

**Grafana**
- [ ] Login réussi (admin/admin123)
- [ ] Datasource Prometheus OK
- [ ] 3 dashboards visibles
- [ ] Pas de "No data" (attendre 2-3 min)

**Test d'alerte**
- [ ] `docker stop sonarqube` → alerte en 2 min
- [ ] Dashboard passe au rouge
- [ ] `docker start sonarqube` → résolution

### Test manuel Blackbox

```powershell
curl "http://localhost:9115/probe?target=http://localhost:8080&module=http_2xx"
curl "http://localhost:9115/probe?target=http://localhost:9000&module=http_2xx"
curl "http://localhost:9115/probe?target=http://localhost:3000&module=http_2xx"
```

Les réponses doivent contenir `probe_success 1`.

---

## 🔄 Déploiement Git

Le script `deploy-monitoring.bat` automatise les commits et push par étapes (8 minutes entre chaque), en excluant les fichiers `.md`.

### Utilisation

Depuis le dossier racine du projet :

```cmd
cd C:\laragon\www\projet_fil_rouge
monitoring\deploy-monitoring.bat
```

### Étapes du déploiement (7 étapes, 8 min d'intervalle)

1. Configuration Docker Compose
2. Configuration Prometheus + Blackbox
3. Configuration Alertmanager
4. Provisioning Grafana
5. Dashboard Infrastructure
6. Dashboard DevOps Services
7. Dashboard Prometheus Health

**Durée totale :** ~48 minutes

### Configuration as Code

Tout est configuré en fichiers (aucune config manuelle dans les interfaces) :
- Versionnable dans Git
- Reproductible à l'identique
- Code review possible
- Reconstruction automatique si perte d'un conteneur

Hot-reload Prometheus : `curl -X POST http://localhost:9090/-/reload`

---

## 🐛 Troubleshooting

### Target DOWN dans Prometheus

```powershell
# Vérifier que le service tourne
curl http://localhost:8080   # Jenkins
curl http://localhost:9000   # SonarQube
curl http://localhost:3000   # Portfolio

# Recharger Prometheus
curl -X POST http://localhost:9090/-/reload
```

### Dashboard Grafana vide

```powershell
# Vérifier la datasource : ☰ → Connections → Data sources → prometheus → Test
# Changer la période en haut à droite : "Last 15 minutes"
# Attendre 2-3 minutes pour les premières données
```

### Port déjà utilisé

```powershell
# Trouver le process
netstat -ano | findstr :9090

# Tuer le process (remplacer PID)
taskkill /PID <PID> /F
```

### Conteneur crash au démarrage

```powershell
docker logs portfolio-prometheus
docker logs portfolio-grafana
docker logs portfolio-blackbox-exporter

docker restart portfolio-prometheus
```

### Réinitialisation complète

```powershell
docker-compose -f docker-compose.monitoring.yml down -v
docker-compose -f docker-compose.monitoring.yml up -d
```

---

## 🛠️ Commandes Utiles

### Gestion des services

```powershell
# Démarrer
docker-compose -f docker-compose.monitoring.yml up -d

# Arrêter (conserve les données)
docker-compose -f docker-compose.monitoring.yml down

# Arrêter et supprimer les volumes (données perdues)
docker-compose -f docker-compose.monitoring.yml down -v

# Redémarrer un service
docker-compose -f docker-compose.monitoring.yml restart grafana

# Logs en temps réel
docker logs portfolio-prometheus --tail 50 --follow

# État des services
docker-compose -f docker-compose.monitoring.yml ps
```

### Vérifications

```powershell
# Conteneurs monitoring
docker ps --filter "name=portfolio-"

# Targets Prometheus
curl http://localhost:9090/api/v1/targets

# Alertes actives
curl http://localhost:9090/api/v1/alerts

# Ressources utilisées
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"
```

### Maintenance

```powershell
# Nettoyer images inutilisées
docker image prune -a

# Backup Prometheus
docker run --rm -v portfolio-prometheus-data:/data -v ${PWD}:/backup alpine tar czf /backup/prometheus-backup.tar.gz /data

# Backup Grafana
docker run --rm -v portfolio-grafana-data:/data -v ${PWD}:/backup alpine tar czf /backup/grafana-backup.tar.gz /data
```

---

## 📁 Structure du Projet

```
monitoring/
├── docker-compose.monitoring.yml    # Configuration Docker Compose
├── deploy-monitoring.bat            # Script de déploiement Git (8 min)
├── README.md                        # Cette documentation
│
├── prometheus/
│   ├── prometheus.yml               # Configuration scraping
│   └── alerts.yml                   # Règles d'alertes
│
├── blackbox/
│   └── blackbox.yml                 # Configuration probes HTTP
│
├── grafana/
│   ├── grafana.ini                  # Config Grafana
│   ├── provisioning/
│   │   ├── datasources/             # Datasource Prometheus auto
│   │   └── dashboards/              # Auto-load dashboards
│   └── dashboards/
│       ├── node-exporter-dashboard.json
│       ├── devops-services-dashboard.json
│       └── prometheus-health-dashboard.json
│
└── alertmanager/
    └── alertmanager.yml             # Configuration notifications
```

---

## 🔗 URLs & Credentials

| Service | URL | Login |
|---------|-----|-------|
| Prometheus | http://localhost:9090 | - |
| Grafana | http://localhost:3005 | admin / admin123 |
| Alertmanager | http://localhost:9093 | - |
| Blackbox Exporter | http://localhost:9115 | - |
| Node Exporter | http://localhost:9100/metrics | - |
| MongoDB Exporter | http://localhost:9216/metrics | - |
| cAdvisor | http://localhost:8081 | - |

---

## 🚀 Évolutions Futures

- **Loki** pour centraliser les logs
- **Tempo** pour le tracing distribué
- Notifications **Slack/Teams** pour les alertes

---

**🎉 Stack monitoring complète et prête pour la démonstration DevOps !**

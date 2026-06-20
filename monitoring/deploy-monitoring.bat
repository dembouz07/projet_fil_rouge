@echo off
:: ========================================
:: DEPLOIEMENT MONITORING - VERSION BATCH
:: Commits automatiques par etapes (8 min)
:: ========================================

echo.
echo === Deploiement Monitoring Stack ===

:: Recherche automatique de la racine du repo git
:: 1) dossier courant  2) dossier du script  3) parent du script
if exist ".git" goto :found
cd /d "%~dp0"
if exist ".git" goto :found
cd /d "%~dp0.."
if exist ".git" goto :found

echo [ERREUR] Repository git introuvable.
echo Lancez ce script depuis le dossier du projet (ou il contient .git).
pause
exit /b 1

:found
echo Repertoire: %CD%
echo.

:: Exclure les fichiers .md
echo Exclusion des fichiers .md...
git reset HEAD -- "monitoring/*.md" 2>NUL

echo.
echo === ETAPE 1/7 : Configuration Docker Compose ===
git add monitoring/docker-compose.monitoring.yml
git commit -m "feat(monitoring): add Docker Compose configuration for monitoring stack"
git push
echo Etape 1 terminee.

echo.
echo Attente 8 minutes avant prochaine etape...
timeout /t 480 /nobreak

echo.
echo === ETAPE 2/7 : Configuration Prometheus + Blackbox ===
git add monitoring/prometheus/ monitoring/blackbox/
git commit -m "feat(monitoring): configure Prometheus and Blackbox Exporter"
git push
echo Etape 2 terminee.

echo.
echo Attente 8 minutes avant prochaine etape...
timeout /t 480 /nobreak

echo.
echo === ETAPE 3/7 : Configuration Alertmanager ===
git add monitoring/alertmanager/
git commit -m "feat(monitoring): setup Alertmanager for notifications"
git push
echo Etape 3 terminee.

echo.
echo Attente 8 minutes avant prochaine etape...
timeout /t 480 /nobreak

echo.
echo === ETAPE 4/7 : Configuration Grafana (provisioning) ===
git add monitoring/grafana/grafana.ini monitoring/grafana/provisioning/
git commit -m "feat(monitoring): configure Grafana auto-provisioning"
git push
echo Etape 4 terminee.

echo.
echo Attente 8 minutes avant prochaine etape...
timeout /t 480 /nobreak

echo.
echo === ETAPE 5/7 : Dashboard Infrastructure ===
git add monitoring/grafana/dashboards/node-exporter-dashboard.json
git commit -m "feat(monitoring): add Node Exporter infrastructure dashboard"
git push
echo Etape 5 terminee.

echo.
echo Attente 8 minutes avant prochaine etape...
timeout /t 480 /nobreak

echo.
echo === ETAPE 6/7 : Dashboard DevOps Services ===
git add monitoring/grafana/dashboards/devops-services-dashboard.json
git commit -m "feat(monitoring): add DevOps services monitoring dashboard"
git push
echo Etape 6 terminee.

echo.
echo Attente 8 minutes avant derniere etape...
timeout /t 480 /nobreak

echo.
echo === ETAPE 7/7 : Dashboard Prometheus Health ===
git add monitoring/grafana/dashboards/prometheus-health-dashboard.json
git commit -m "feat(monitoring): add Prometheus health monitoring dashboard"
git push
echo Etape 7 terminee.

echo.
echo ======================================
echo   DEPLOIEMENT MONITORING TERMINE
echo ======================================
echo 7 etapes terminees - Duree totale: 48 minutes
echo.
echo URLs utiles:
echo    - Prometheus:   http://localhost:9090
echo    - Grafana:      http://localhost:3005 (admin/admin123)
echo    - Alertmanager: http://localhost:9093
echo.
pause
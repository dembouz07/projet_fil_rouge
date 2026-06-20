@echo off
:: ============================================
:: DEMARRAGE CENTRALISE DE TOUS LES SERVICES
:: Application + SonarQube + Monitoring
:: ============================================

:: Se placer a la racine du projet (dossier du script)
cd /d "%~dp0"

echo.
echo ==========================================
echo   DEMARRAGE DE TOUS LES SERVICES
echo ==========================================
echo Repertoire: %CD%
echo.

:: Verifier que Docker est demarre
docker info >NUL 2>&1
if %errorlevel% neq 0 (
    echo [ERREUR] Docker Desktop n'est pas demarre.
    echo Demarrez Docker Desktop puis relancez ce script.
    pause
    exit /b 1
)

:: --------------------------------------------
echo === ETAPE 1/3 : Application (MongoDB + Backend + Frontend) ===
docker-compose -f docker-compose.yml up -d
if %errorlevel% neq 0 (
    echo [ERREUR] Echec du demarrage de l'application.
    pause
    exit /b 1
)
echo Application demarree.
echo.

:: --------------------------------------------
echo === ETAPE 2/3 : SonarQube ===
:: S'assurer que le reseau partage avec Jenkins existe
docker network create portfolio-network >NUL 2>&1
docker-compose -f docker-compose.sonarqube.yml up -d
if %errorlevel% neq 0 (
    echo [ATTENTION] SonarQube n'a pas pu demarrer (on continue).
) else (
    echo SonarQube demarre.
)
echo.

:: --------------------------------------------
echo === ETAPE 3/3 : Stack Monitoring ===
docker-compose -f monitoring/docker-compose.monitoring.yml up -d
if %errorlevel% neq 0 (
    echo [ERREUR] Echec du demarrage du monitoring.
    pause
    exit /b 1
)
echo Monitoring demarre.
echo.

:: --------------------------------------------
echo Attente de la mise en route des services (20s)...
timeout /t 20 /nobreak >NUL

echo.
echo ==========================================
echo   ETAT DES CONTENEURS
echo ==========================================
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo.
echo ==========================================
echo   TOUS LES SERVICES SONT DEMARRES
echo ==========================================
echo.
echo URLs utiles:
echo    - Frontend Portfolio : http://localhost:3000
echo    - Backend API        : http://localhost:5000
echo    - SonarQube          : http://localhost:9000
echo    - Prometheus         : http://localhost:9090
echo    - Grafana            : http://localhost:3005  (admin/admin123)
echo    - Alertmanager       : http://localhost:9093
echo    - Blackbox Exporter  : http://localhost:9115
echo.
pause

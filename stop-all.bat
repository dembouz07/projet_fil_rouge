@echo off
:: ============================================
:: ARRET CENTRALISE DE TOUS LES SERVICES
:: Monitoring + SonarQube + Application
:: ============================================

:: Se placer a la racine du projet (dossier du script)
cd /d "%~dp0"

echo.
echo ==========================================
echo   ARRET DE TOUS LES SERVICES
echo ==========================================
echo Repertoire: %CD%
echo.

:: Ordre inverse du demarrage
echo === ETAPE 1/3 : Stack Monitoring ===
docker-compose -f monitoring/docker-compose.monitoring.yml down
echo.

echo === ETAPE 2/3 : SonarQube ===
docker-compose -f docker-compose.sonarqube.yml down
echo.

echo === ETAPE 3/3 : Application ===
docker-compose -f docker-compose.yml down
echo.

echo ==========================================
echo   TOUS LES SERVICES SONT ARRETES
echo ==========================================
echo.
echo Note: les donnees (volumes) sont conservees.
echo Pour tout supprimer (volumes inclus), utilisez l'option -v
echo sur chaque commande docker-compose down.
echo.
pause

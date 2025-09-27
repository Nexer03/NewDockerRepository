@echo off
REM debug-database-advanced.bat
REM Script avanzado para inicializar proyecto con Docker en Windows

echo =====================================
echo INICIALIZACION DEL AMBIENTE DE DOCKER
echo =====================================
echo.

REM 1. Verificar estructura de carpetas
echo Verificando carpeta database_init...
if exist "database_init" (
    echo Carpeta database_init encontrada
    echo Archivos SQL encontrados:
    dir "database_init\*.sql" /B
) else (
    echo Carpeta database_init NO existe. Créala con: mkdir database_init
    pause
    exit /b 1
)
echo.

REM 2. Detener contenedores existentes
echo Deteniendo contenedores existentes...
docker-compose down
echo.

REM 3. Limpiar datos existentes
if exist "mysql_data" (
    echo Eliminando carpeta mysql_data...
    rmdir /s /q "mysql_data"
    echo mysql_data eliminada
) else (
    echo No existía carpeta mysql_data
)
echo.

REM 4. Levantar contenedores Docker
echo Levantando contenedores...
docker-compose up -d
echo Contenedores levantados
echo.

REM 5. Abrir navegadores
echo Abriendo navegador para PHP y phpMyAdmin...
start http://localhost:8080
start http://localhost:8081
echo Listo. Ambiente preparado.
pause

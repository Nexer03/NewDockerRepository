# NewDockerRepository

Repositorio colaborativo con configuración Docker para un stack simple: PHP (Apache) + MySQL + phpMyAdmin.  
Este proyecto está pensado para facilitar el desarrollo local y compartir la configuración entre el equipo.

## Contenido del repositorio
- `docker-compose.yml` — definición de los servicios: `mysql`, `app` y `phpmyadmin`.
- `debug-docker-compose.bat` — script de ayuda (Windows) para limpiar datos y levantar el entorno.
- `database_init/` — scripts SQL que se ejecutan automáticamente en la primera inicialización de MySQL.
- `mysql_data/` — carpeta con los datos del motor MySQL (actualmente incluida en el repo — ver nota sobre git).
- `Docker/` — Dockerfile para construir la imagen del servicio `app`.
- `Src/public/` — código fuente público que se sirve en `http://localhost:8080`.

## Visión general (proyecto colaborativo)
Este repo debe ser usado por varias personas para levantar rápidamente un entorno local idéntico. Cada desarrollador:
- Clona el repo.
- Levanta los contenedores con Docker Compose.
- Trabaja en `Src/public/` (montado en el contenedor `app`).

Reglas básicas:
- No commitees ficheros binarios de bases de datos en `mysql_data/`. Añade `mysql_data/` a `.gitignore` (sugerencia más abajo).
- Si necesitas compartir datos estructurales iniciales, coloca archivos `.sql` en `database_init/`.
- Usa ramas/PRs para cambios en la configuración de contenedores y Dockerfile.

## Explicación de `docker-compose.yml`

Servicios principales:

1. mysql
- Imagen: `mysql:8.0`
- Nombre del contenedor: `pruebaBD-mysql`
- Variables de entorno:
  - `MYSQL_ROOT_PASSWORD`: contraseña del root (hoy `rootpassword`).
  - `MYSQL_DATABASE`: base de datos por defecto (hoy `pruebaBD`).
  - `MYSQL_USER` / `MYSQL_PASSWORD`: usuario adicional y su contraseña.
- Puertos: `3306:3306` (mapea el puerto MySQL en el host).
- Volúmenes:
  - `./mysql_data:/var/lib/mysql` (persistencia de datos).
  - `./database_init:/docker-entrypoint-initdb.d` (scripts SQL que MySQL ejecuta al crear la BD por primera vez).

Nota importante: los scripts dentro de `database_init/` solo se ejecutan cuando el directorio de datos de MySQL está vacío (es decir, en la primera inicialización). Si `mysql_data` ya contiene datos, los scripts no se vuelven a ejecutar.

2. app
- Construye la imagen a partir de `./Docker` (`Dockerfile`).
- Nombre del contenedor: `pruebaBD-apache`.
- Puertos: `8080:80` (accede al sitio en `http://localhost:8080`).
- Volumen: `./Src/public:/var/www/html` (monta código fuente para desarrollo).
- `depends_on: - mysql` indica que Docker Compose arrancará `mysql` antes, pero no garantiza que MySQL esté listo para conexiones; podría ser necesario esperar o comprobar logs.

3. phpmyadmin
- Imagen: `phpmyadmin/phpmyadmin`
- Nombre del contenedor: `pruebaBD-phpmyadmin`
- Variables:
  - `PMA_HOST: mysql` (host del servidor MySQL dentro de la red de compose)
  - `MYSQL_ROOT_PASSWORD` (para permitir acceso con root).
- Puertos: `8081:80` (accede en `http://localhost:8081`).

## Explicación del archivo `debug-docker-compose.bat`

El `.bat` es un script de ayuda para Windows (CMD) que automatiza pasos comunes:

Pasos que realiza:
1. Verifica que exista la carpeta `database_init` y lista los `.sql` si están presentes.
2. Ejecuta `docker-compose down` para detener contenedores (pero no borra por defecto volúmenes).
3. Si existe la carpeta `mysql_data`, la elimina con `rmdir /s /q "mysql_data"` — esto borra los datos de MySQL en el equipo local, forzando que a la siguiente ejecución MySQL se inicialice desde cero y ejecute los scripts en `database_init/`.
4. Lanza `docker-compose up -d` para levantar los contenedores en segundo plano.
5. Abre automáticamente el navegador en `http://localhost:8080` y `http://localhost:8081`.

Uso típico (doble clic o desde CMD):
- Doble clic en `debug-docker-compose.bat` o desde PowerShell / CMD:
  - Windows CMD:
    ```
    debug-docker-compose.bat
    ```
  - PowerShell (ejecuta el batch):
    ```
    .\debug-docker-compose.bat
    ```

Advertencia: El script elimina la carpeta `mysql_data` si existe. Úsalo sólo cuando quieras reiniciar la BD desde cero.

## Comandos equivalentes (PowerShell / CMD)
Si prefieres controlar manualmente el flujo:

- Detener contenedores:
```powershell
docker-compose down
```

- Eliminar la carpeta de datos MySQL (PowerShell):
```powershell
Remove-Item -Recurse -Force .\mysql_data
```

- Levantar contenedores en background:
```powershell
docker-compose up -d
```

- Ver logs de MySQL:
```powershell
docker-compose logs -f mysql
```

- Para forzar la recreación y borrar volúmenes creados por Compose:
```powershell
docker-compose down -v
```
(Nótese: `-v` elimina volúmenes manejados por compose; dado que aquí usamos bind-mount `./mysql_data`, hay que borrar esa carpeta manualmente si hace falta.)

## Cómo añadir o ejecutar scripts SQL (database_init)
- Coloca tus archivos `.sql` en `database_init/`.
- Si `mysql_data/` está vacío (o fue eliminado), MySQL ejecutará esos scripts automáticamente durante la primera inicialización.
- Si ya tienes datos y quieres re-ejecutar esos scripts, elimina `mysql_data/` y reinicia (o importa manualmente con cliente `mysql`).

Ejemplo de import manual:
```powershell
docker exec -i pruebaBD-mysql mysql -u root -p rootpassword pruebaBD < database_init/01_init.sql
```

## Seguridad y buenas prácticas
- No commits de datos binarios ni contraseñas en claro. Mueve `mysql_data/` a `.gitignore`:
```gitignore
# filepath: .gitignore
mysql_data/
```
- Usa variables de entorno seguras o archivos `.env` para contraseñas en un entorno real.
- No confíes en `depends_on` para verificar disponibilidad del servicio; usa waits o cheques de healthcheck si tu app necesita que MySQL esté listo.

## Problemas comunes y soluciones
- Puerto 3306 ocupado en host: cambia/elimina el mapeo o detén el MySQL local.
- Los scripts SQL no se ejecutan: probablemente porque `mysql_data/` ya tiene datos. Elimínala si quieres forzar la inicialización.
- Permisos en Windows: si Docker Desktop usa WSL2, los bind mounts pueden comportarse diferente; revisa logs y permisos.

## Contribuir
- Crea una rama por feature/fix: `feature/<descripción>` o `bugfix/<descripción>`.
- Abre un Pull Request con descripción y pasos para probar.
- Mantén `database_init/` para scripts de estructura/seed reproducibles.
- Añade tests si el proyecto web crece (sugerencia: composer/phpunit u otro stack según tecnología).

## Recursos y comprobaciones rápidas
- App: http://localhost:8080
- phpMyAdmin: http://localhost:8081
- MySQL TCP: localhost:3306 (si no hay conflicto en host)

## Sugerencias siguientes
- Añadir `.gitignore` para `mysql_data/`.
- Crear un `.env.example` con variables (sin valores sensibles) y modificar `docker-compose.yml` para usarlo.
- Añadir healthchecks para `mysql` y scripts de espera en `app` para evitar errores de conexión temprana.

---

Si quieres, aplico directamente los cambios sugeridos (por ejemplo: reemplazar el actual `README.md` con este contenido y añadir `.gitignore` con `mysql_data/`). ¿Quieres que haga esos cambios ahora?
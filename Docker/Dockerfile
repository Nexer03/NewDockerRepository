FROM php:8.2-apache

# Instalar extensiones necesarias (ejemplo mysqli y pdo_mysql para MySQL)
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Copiar código al contenedor
COPY . /var/www/html/

# Dar permisos correctos
RUN chown -R www-data:www-data /var/www/html

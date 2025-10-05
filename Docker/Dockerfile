FROM php:8.2-apache

# Instalar extensiones necesarias para Laravel y MySQL
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Habilitar mod_rewrite (Laravel lo requiere)
RUN a2enmod rewrite

# Configurar el DocumentRoot a /var/www/html/laravel/public
RUN sed -ri -e 's!/var/www/html!/var/www/html/laravel/public!g' /etc/apache2/sites-available/*.conf

# Dar permisos al usuario www-data (el que usa Apache)
RUN chown -R www-data:www-data /var/www/html

WORKDIR /var/www/html

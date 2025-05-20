FROM php:8.4-fpm

# Establecer directorio de trabajo
WORKDIR /var/www/html

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libzip-dev \
    unixodbc-dev \
    libgssapi-krb5-2 \
    libssl-dev \
    gnupg \
    unixodbc \
    supervisor

# Instalar la extensión zip
RUN docker-php-ext-install zip

# Limpiar cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Instalar extensiones de PHP 
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Obtener el último Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copiar scripts
COPY scripts /var/www/cobrofacil-api/php

# Configurar Supervisor con directorios y permisos adecuados
RUN mkdir -p /var/www/html/storage/logs/supervisor \
    && touch /var/www/html/storage/logs/supervisor/supervisord.log \
    && chown -R www-data:www-data /var/www/html/storage/logs \
    && chmod -R 777 /var/www/html/storage/logs

# Copiar configuración de supervisor
COPY supervisor /etc/supervisor/conf.d

# Configurar supervisor para usar un directorio personalizado de logs
RUN echo "[supervisord]\nlogfile=/var/www/html/storage/logs/supervisor/supervisord.log\nlogfile_maxbytes=50MB\nlogfile_backups=10\nloglevel=info\npidfile=/var/www/html/supervisord.pid\nnodaemon=false\n" > /etc/supervisor/supervisord.conf

# Eliminar caracteres \r si vienes de Windows
RUN sed -i 's/\r$//' /var/www/cobrofacil-api/php/*.sh

# Otorgar permisos de ejecución a los scripts
RUN chmod +x /var/www/cobrofacil-api/php/*.sh

RUN echo "upload_max_filesize = 100M" >> /usr/local/etc/php/php.ini && \
    echo "post_max_size = 100M" >> /usr/local/etc/php/php.ini

CMD ["/var/www/cobrofacil-api/php/run.sh"]

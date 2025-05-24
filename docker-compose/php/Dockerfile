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
    unixodbc

# Instalar la extensión zip
RUN docker-php-ext-install zip

# Limpiar cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Instalar extensiones de PHP 
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Obtener el último Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copiar scripts
COPY scripts /var/www/academico-plus-api/php

# Eliminar caracteres \r si vienes de Windows
RUN sed -i 's/\r$//' /var/www/academico-plus-api/php/*.sh

# Otorgar permisos de ejecución a los scripts
RUN chmod +x /var/www/academico-plus-api/php/*.sh

RUN echo "upload_max_filesize = 100M" >> /usr/local/etc/php/php.ini && \
    echo "post_max_size = 100M" >> /usr/local/etc/php/php.ini

CMD ["/var/www/academico-plus-api/php/run.sh"]

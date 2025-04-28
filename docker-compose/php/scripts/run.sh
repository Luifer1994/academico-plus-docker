#!/usr/bin/env bash

echo ".:COBRO-FACIL:."
echo "-------------"
echo ">> Ambiente de Desarrollo Backend (Laravel)."

VENDOR_DIR="vendor"
WORKDIR="/var/www/html" 

cd "$WORKDIR"

if [ -d "$VENDOR_DIR" ]; then
  echo " > Limpiando caché de Laravel."
  php artisan optimize:clear
else
  FILE=".env"
  if [ -f "$FILE" ]; then
    echo " > Archivo .env encontrado."
  else
    echo " > Archivo .env no encontrado. Creando..."
    cp .env.example .env
  fi

  COMPOSER_LOCK="composer.lock"
  if [ -f "$COMPOSER_LOCK" ]; then
    echo " > composer.lock encontrado. Eliminando para evitar problemas de instalación."
    rm composer.lock
  fi

  echo " > Instalando dependencias de composer."
  composer install

  echo " > Configurando idiomas para i18n."
  php artisan lang:add es
  php artisan lang:add en
  php artisan lang:add fr
  php artisan lang:add pt

  echo " > Generando Key de Laravel."
  php artisan key:generate

  echo " > Creando link simbólico de almacenamiento."
  php artisan storage:link

  echo " > Limpiando caché de Laravel."
  php artisan optimize:clear
  

  # Importante: No hacer 'chown' ni 'chmod' aquí
fi

echo ">> Ambiente Iniciado Correctamente."
exec php-fpm
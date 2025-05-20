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

# Matar cualquier proceso queue:work existente
if [ -f /var/www/html/storage/logs/queue.pid ]; then
  if [ -n "$(cat /var/www/html/storage/logs/queue.pid)" ]; then
    echo " > Deteniendo worker anterior..."
    kill -9 $(cat /var/www/html/storage/logs/queue.pid) 2>/dev/null || true
  fi
  rm /var/www/html/storage/logs/queue.pid
fi

# Iniciar worker en segundo plano y guardar su PID
echo " > Iniciando worker de colas en segundo plano..."
nohup php artisan queue:work --queue=high,default,low --sleep=3 --tries=3 --timeout=90 > /var/www/html/storage/logs/queue-worker.log 2>&1 &
QUEUE_PID=$!
echo $QUEUE_PID > /var/www/html/storage/logs/queue.pid
echo " > Worker iniciado con PID: $QUEUE_PID"

# Monitorear el worker periódicamente
(
  while true; do
    sleep 60  # Verificar cada minuto
    if ! kill -0 $QUEUE_PID 2>/dev/null; then
      echo " > Worker detenido. Reiniciando..." >> /var/www/html/storage/logs/queue-monitor.log
      nohup php artisan queue:work --queue=high,default,low --sleep=3 --tries=3 --timeout=90 >> /var/www/html/storage/logs/queue-worker.log 2>&1 &
      QUEUE_PID=$!
      echo $QUEUE_PID > /var/www/html/storage/logs/queue.pid
      echo " > Worker reiniciado con PID: $QUEUE_PID" >> /var/www/html/storage/logs/queue-monitor.log
    fi
  done
) &

# Iniciar PHP-FPM en primer plano (el proceso principal)
echo " > Iniciando PHP-FPM..."
# Matar cualquier proceso queue:work existente
if [ -f /var/www/html/storage/logs/queue.pid ]; then
  if [ -n "$(cat /var/www/html/storage/logs/queue.pid)" ]; then
    echo " > Deteniendo worker anterior..."
    kill -9 $(cat /var/www/html/storage/logs/queue.pid) 2>/dev/null || true
  fi
  rm /var/www/html/storage/logs/queue.pid
fi

# Iniciar worker en segundo plano y guardar su PID
echo " > Iniciando worker de colas en segundo plano..."
nohup php artisan queue:work --queue=high,default,low --sleep=3 --tries=3 --timeout=90 > /var/www/html/storage/logs/queue-worker.log 2>&1 &
QUEUE_PID=$!
echo $QUEUE_PID > /var/www/html/storage/logs/queue.pid
echo " > Worker iniciado con PID: $QUEUE_PID"

# Monitorear el worker periódicamente
(
  while true; do
    sleep 60  # Verificar cada minuto
    if ! kill -0 $QUEUE_PID 2>/dev/null; then
      echo " > Worker detenido. Reiniciando..." >> /var/www/html/storage/logs/queue-monitor.log
      nohup php artisan queue:work --queue=high,default,low --sleep=3 --tries=3 --timeout=90 >> /var/www/html/storage/logs/queue-worker.log 2>&1 &
      QUEUE_PID=$!
      echo $QUEUE_PID > /var/www/html/storage/logs/queue.pid
      echo " > Worker reiniciado con PID: $QUEUE_PID" >> /var/www/html/storage/logs/queue-monitor.log
    fi
  done
) &

# Iniciar PHP-FPM en primer plano (el proceso principal)
echo " > Iniciando PHP-FPM..."
exec php-fpm
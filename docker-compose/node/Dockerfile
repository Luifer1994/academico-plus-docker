# Imagen de NodeJS
FROM node:22-alpine

# Establecer directorio de trabajo
WORKDIR /var/www/html/app

# Copiar shell scripts
COPY scripts /var/www/academico-plus/node

# Eliminar caracteres incompatibles
RUN sed -i 's/\r$//' /var/www/academico-plus/node/*.sh

# Otorgar permisos de ejecución a los archivos sh
RUN chmod +x /var/www/academico-plus/node/*.sh

# Ejecutar archivo principal sh de arranque
CMD [ "/var/www/academico-plus/node/run.sh" ]
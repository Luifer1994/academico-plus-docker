echo ".:COBRO-FACIL:."
echo "-------------"
echo ">> Ambiente de Desarrollo Frontend (VueJS)."

# Se definen las variables
NODE_MODULES_DIR="node_modules"
WORKDIR="/var/www/html/app"

# Ingresar al directorio del proyecto
cd $WORKDIR

#npm cache clean --force
npm cache clean --force

if [ -d "$NODE_MODULES_DIR" ]; then
	# Si el directorio node_modules existe se limpia únicamente caché
  echo " > Limpiando caché de proyecto."
else
	echo " > Instalando dependencias de node."
	npm install
fi

echo ">> Ambiente Iniciado Correctamente."
npm run dev -- --host --port 3001
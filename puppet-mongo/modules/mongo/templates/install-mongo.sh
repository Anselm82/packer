#!/bin/bash

# Creado por Juan José Hernández Alonso
# Notas:
# Se ha añadido la comprobación de permisos ya que añadir repositorios a apt requiere ejecutar el script como root.
# Esta versión de mongo, en ubuntu-bionic, necesita la librería libcurl3 que se ha añadido al comando de instalación de mongo.
# Para que el usuario se cree, no debe estar en base de datos y debería hacerse un drop de la colección de mongo si se ejecutan varios scripts.
# Se han mantenido las opciones existentes y se ha añadido una más para pasar el archivo de configuración.
# Se ha añadido la eliminación de espacios en blanco en el archivo de configuración.


# Comprobamos que el usuario tiene permisos.
if [[ $EUID -ne 0 ]]; then
   echo "El script debe ejecutarse como usuario root"
   exit 1
fi

set -e
logger "Arrancando instalación y configuración de MongoDB"
USO="Uso : install.sh [opciones]
Ejemplos:
install.sh -u administrador -p password [-n 27017]
install.sh -f config.ini
      Opciones:
       -u usuario
       -p password
       -n numero de puerto (opcional)
       -a muestra esta ayuda
       -f carga la información desde un archivo
"

function ayuda() {
  echo "${USO}"
  if [[ ${1} ]]
  then
    echo "${1}"
  fi
}

function leer_config() {
    while IFS='=' read var val
    do
      key="$(echo -e "${var}" | sed -r 's/^\s*(\S+(\s+\S+)*)\s*$/\1/')"
      value="$(echo -e "${val}" | sed -r 's/^\s*(\S+(\s+\S+)*)\s*$/\1/')"
      if [ $key == "user" ]; then
        USUARIO=$value
      elif [ $key == "password" ]; then
        PASSWORD=$value
      elif [ $key == "port" ]; then
        PUERTO_MONGOD=$value
      fi
    done < "${1}"
}

# Función para comprobar si mongo está activo
function esta_mongo_disponible {
  while true
  do
    mongo --quiet --eval "quit()"  1>/dev/zero 2>&1
    rc=$?
    if [ $rc -ne 0 ]
    then
      false
    else
      break
    fi
  done
  true
}

# Gestionar los argumentos
while getopts ":u:p:n:a:f:" OPCION
do
  case "${OPCION}" in
    u ) USUARIO=$OPTARG
        echo "Parámetro USUARIO establecido con '${USUARIO}'";;
    p ) PASSWORD=$OPTARG
        echo "Parámetro PASSWORD establecido";;
    n ) PUERTO_MONGOD=$OPTARG
        echo "Parámetro PUERTO_MONGOD establecido con '${PUERTO_MONGOD}'";;
    a ) ayuda; exit 0;;
    f ) leer_config $OPTARG
        echo "Configuración cargada";;
    : ) ayuda "Falta el parámetro para -$OPTARG"; exit 1;;
    ? ) ayuda "La opción no existe : $OPTARG"; exit 1;;
  esac
done

if [ -z ${USUARIO} ]
then
    ayuda "El usuario (-u) debe ser especificado";
    exit 1
fi
if [ -z ${PASSWORD} ]
then
    ayuda "La password (-p) debe ser especificada";
    exit 1
fi
if [ -z ${PUERTO_MONGOD} ]
then
    PUERTO_MONGOD=27017
fi

# Preparar el repositorio (apt-get) de mongodb añadir su clave apt
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 4B7C549A058F8B6B
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.2 multiverse" | tee /etc/apt/sources.list.d/mongodb.list
if [[ -z "$(mongo --version 2> /dev/null | grep '4.2.1')" ]]
then
# Instalar paquetes comunes, servidor, shell, balanceador de shards y herramientas
  apt-get -y update \
  && apt-get install -y \
    libcurl3 \
    mongodb-org=4.2.1 \
    mongodb-org-server=4.2.1 \
    mongodb-org-shell=4.2.1 \
    mongodb-org-mongos=4.2.1 \
    mongodb-org-tools=4.2.1 \
    && rm -rf /var/lib/apt/lists/* \
    && pkill -u mongodb || true \
    && pkill -f mongod || true \
    && rm -rf /var/lib/mongodb
fi
# Crear las carpetas de logs y datos con sus permisos
[[ -d "/datos/bd" ]] || mkdir -p -m 755 "/datos/bd"
[[ -d "/datos/log" ]] || mkdir -p -m 755 "/datos/log"

# Establecer el dueño y el grupo de las carpetas db y log
chown mongodb /datos/log /datos/bd
chgrp mongodb /datos/log /datos/bd

# Crear el archivo de configuración de mongodb con el puerto solicitado
mv /etc/mongod.conf /etc/mongod.conf.orig
(
cat <<MONGOD_CONF
 # /etc/mongod.conf
systemLog:
  destination: file
  path: /datos/log/mongod.log
  logAppend: true
storage:
  dbPath: /datos/bd
  engine: wiredTiger
  journal:
    enabled: true
net:
  port: ${PUERTO_MONGOD}
security:
  authorization: enabled
MONGOD_CONF
) > /etc/mongod.conf

# Reiniciar el servicio de mongod para aplicar la nueva configuracion
systemctl restart mongod

logger "Esperando a que mongod responda..."

# Esperamos mientras no está disponible el servicio
while ! esta_mongo_disponible ; do true; done

# Crear usuario con la password proporcionada como parametro
mongo admin <<CREACION_DE_USUARIO
db.createUser({
  user: "${USUARIO}",
  pwd: "${PASSWORD}",
  roles:[{
    role: "root",
    db: "admin"
  },{
    role: "restore",
    db: "admin"
  }]
})
CREACION_DE_USUARIO

logger "El usuario ${USUARIO} ha sido creado con éxito!"

exit 0

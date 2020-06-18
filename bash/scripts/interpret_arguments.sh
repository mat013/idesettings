#!/bin/bash

OPTS=`getopt -o u:p:n:m:t:d:e:h --long username:,password:,project:,host:,timeout:,pod:,expose:,help -n 'parse-options' -- "$@"`
if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi

eval set -- "$OPTS"

# default arguments
USERNAME=$USER
PASSWORD=
PROJECT=project1
HOST="https://localhost:8443"
TIMEOUT=0
POD=
PORT=

while true; do
  case "$1" in
    -u | --username ) USERNAME=$2; shift 2; ;;
    -p | --password ) PASSWORD=$2; shift 2; ;;
    -n | --project ) PROJECT=$2; shift 2; ;;
    -m | --host ) HOST=$2; shift 2; ;;
    -t | --timeout ) TIMEOUT=$2; shift 2; ;;
    -d | --pod ) POD=$2; shift 2; ;;
    -e | --port ) PORT=$2; shift 2; ;;
    -h ) echo "HELP"; exit 0; ;;
    -- ) shift; break ;;
    * ) shift; ;;
  esac
done

echo USERNAME=$USERNAME
echo PASSWORD=$PASSWORD
echo PROJECT=$PROJECT
echo HOST=$HOST
echo TIMEOUT=$TIMEOUT
echo POD=$POD
echo PORT=$PORT

echo oc login $HOST -n $PROJECT -u $USERNAME -p $PASSWORD

#OPENSHIFT_ENVIRONMENT=$(oc project)
#M=${OPENSHIFT_ENVIRONMENT/Using project \"/}
#OPENSHIFT_ENVIRONMENT=${M/\" on server*/}
OPENSHIFT_ENVIRONMENT=$PROJECT

if [ $OPENSHIFT_ENVIRONMENT != $PROJECT ]; then
  echo Terminating due to environment was set to $OPENSHIFT_ENVIRONMENT and not to to $PROJECT as expected
  exit 2
fi

if [ $TIMEOUT == "0" ]; then
  echo oc login $POD $PORT
else
  echo timeout $TIMEOUT oc port-forward $POD $PORT
fi

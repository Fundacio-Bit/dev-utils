#!/usr/bin/env bash

#### Description: Build from source
#### Written by: Guillermo de Ignacio - gdeignacio on 04-2021

# Revision 2024-08-01

###################################
###   BUILD MVN UTILS           ###
###################################

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./projectebase_generar.sh

    Generate project using maven archetype

'
    exit
fi

echo ""
PROJECT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"
echo "Project path at $PROJECT_PATH"
echo ""
echo "[$(date +"%Y-%m-%d %T")] Build and deploy project..."
echo ""

# Taking values from .env file
source $PROJECT_PATH/bin/lib_string_utils.sh
source $PROJECT_PATH/bin/lib_env_utils.sh

lib_env_utils.loadenv ${PROJECT_PATH}

echo off
if [[ -f help.txt ]]
then
  cat help.txt
else
  echo "help.txt no existe"
fi


if [ "$APP_PROJECT_FOLDER" == "" ]; then
  # Project dir value is empty
  echo  =================================================================
  echo    Definex la variable d\'entorn APP_PROJECT_FOLDER apuntant al
  echo    directori del projecte a generar.
  echo  =================================================================
  # End of not project section
else
  # Project dir value is informed
  echo on
  # Check if APP_FOLDER directory exists 
  if [ -d "$APP_PROJECT_FOLDER" ]; then
    ### Take action if $DIR exists ###
    echo --------- La carpeta $APP_PROJECT_FOLDER existeix  ---------
  else
    ###  Control will jump here if dir does NOT exists ###
    echo "${APP_PROJECT_FOLDER} not found. Creating ..."
    mkdir -p $APP_PROJECT_FOLDER
  fi

  #cd $PROJECT_PATH/..
  cd $APP_PROJECT_PATH

  MAVEN_OPTS="-Dfile.encoding=UTF-8" && mvn org.apache.maven.plugins:maven-archetype-plugin:3.2.0:generate \
      -B -DarchetypeGroupId=es.caib.projectebase \
      -DarchetypeArtifactId=projectebase-archetype \
      -DarchetypeVersion=${archetypeVersion} \
      -Dpackage=${APP_PACKAGE_NAME}.${LONG_APP_NAME_LOWER} \
      -Dpackagepath=${APP_PACKAGE_PATH}/${LONG_APP_NAME_LOWER} \
      -Dinversepackage=${LONG_APP_NAME_LOWER}.${APP_DOMAIN_NAME} \
      -DgroupId=${APP_PACKAGE_NAME}.${LONG_APP_NAME_LOWER} \
      -DartifactId=${LONG_APP_NAME_LOWER} \
      -Dversion=${APP_PROJECT_TAG} \
      -Dprojectname=${LONG_APP_NAME_CAMEL} \
      -Dprojectnameuppercase=${LONG_APP_NAME_UPPER} \
      -Dprefix=${SHORT_APP_NAME_LOWER} \
      -Dprefixuppercase=${SHORT_APP_NAME_UPPER} \
      -DperfilBack=${perfilBack} \
      -DperfilFront=${perfilFront} \
      -DperfilApiInterna=${perfilApiInterna} \
      -DperfilApiExterna=${perfilApiExterna} \
      -DperfilApiFirmaSimple=${perfilApiFirmaSimple} \
      -DperfilArxiu=${perfilArxiu} \
      -DperfilRegistre=${perfilRegistre} \
      -DperfilNotib=${perfilNotib} \
      -DperfilDir3Caib=${perfilDir3Caib} \
      -DperfilDistribucio=${perfilDistribucio} \
      -DperfilPinbal=${perfilPinbal} \
      -DperfilSistra2=${perfilSistra2} \
      -DperfilWS=${perfilWS} \
      -DperfilBatSh=${perfilBatSh} \
      --settings $PROJECT_PATH/builds/maven-dist/maven/conf/settings.xml
    
  cd $PROJECT_PATH

fi

  





















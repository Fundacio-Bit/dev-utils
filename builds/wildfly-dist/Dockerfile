###############################################################################################
# Wildfly 26.0.1.Final adaptado al entorno de desarrollo del Govern de les Illes Balears (GOIB)
#
# Esta versión comunitaria de Wildfly 26.0.1.Final corresponde con la versión de Jboss EAP 7.4
# según la web oficial de Redhat https://access.redhat.com/solutions/21906
#
# Comando para construir la imagen: 
# docker build --build-arg KEYCLOAK_URI_ARG=http://keycloak-goib:8180 -t goib/wildfly:14.0.1 .
#
# Comando para crear y ejecutar un contenedor: 
# docker run -p 8080:8080 -p 9990:9990 goib/wildfly:14.0.1
#
# Incluye la mini aplicación /goibusuari que muestra información del usuario autenticado 
# mediante un servidor keycloak que deberá escuchar en la dirección ${KEYCLOAK_URI_ARG}/auth
# y tener configurado el realm GOIB y los clientes goib-default y goib-ws.
#
# Puede utilizarse la siguiente imagen de keycloak:
# docker run -p 8180:8180 goib/keycloak:6.0.1
#
###############################################################################################

# By default, build on JDK 11 on UBI 9.
ARG jdk=11
# Red Hat UBI 9 (ubi9-minimal) should be used on JDK 11 and later.
ARG dist=ubi9-minimal
FROM eclipse-temurin:${jdk}-${dist}

ARG DOCKER_FILE_MAINTAINER="Maintainer <user@example.com>"

LABEL org.opencontainers.image.authors="${DOCKER_FILE_MAINTAINER}"

LABEL org.opencontainers.image.source=https://github.com/jboss-dockerfiles/wildfly org.opencontainers.image.title=wildfly org.opencontainers.imag.url=https://github.com/jboss-dockerfiles/wildfly org.opencontainers.image.vendor=WildFly

# Starting on jdk 17 eclipse-temurin is based on ubi9-minimal version 9.3 
#   that doesn't includes shadow-utils package that provides groupadd & useradd commands
# Conditional RUN: IF no groupadd AND microdnf THEN: update, install shadow-utils, clean
RUN if ! [ -x "$(command -v groupadd)" ] && [ -x "$(command -v microdnf)" ]; then microdnf update -y && microdnf install --best --nodocs -y shadow-utils && microdnf clean all; fi

WORKDIR /opt/jboss

RUN groupadd -r jboss -g 1000 && useradd -u 1000 -r -g jboss -m -d /opt/jboss -s /sbin/nologin -c "JBoss user" jboss && \
    chmod 755 /opt/jboss

ARG KEYCLOAK_URI_ARG=http://keycloak-goib:8180

ENV WILDFLY_VERSION=26.0.1.Final \
    WILDFLY_SHA1=08908faf9ae99e5fb6374979afbffea461aadc2c \
    # WILDFLY_SHA1=757d89d86d01a9a3144f34243878393102d57384 \
    JBOSS_HOME=/opt/jboss/wildfly \
    #JBOSS_USER=jboss \
    KEYCLOAK_URI=$KEYCLOAK_URI_ARG \
    KEYCLOAK_VERSION=6.0.1 \
    POSTGRESQL_JDBC_VERSION=42.2.5 \
    ORACLE_JDBC_VERSION=12.2.0.1 \
    LOMBOK_VERSION=1.18.18

ENV PATH=${JBOSS_HOME}/bin:/tmp:${PATH}

USER root

RUN microdnf -y update && \
    microdnf -y install glibc-common glibc-locale-source && \
    localedef -i es_ES -f UTF-8 es_ES.UTF-8

RUN microdnf -y install tzdata && microdnf -y update && microdnf -y reinstall tzdata && \
    cp -fs /usr/share/zoneinfo/Europe/Madrid /etc/localtime && \
    echo "Europe/Madrid" > /etc/timezone

ENV LANG=es_ES.UTF-8 \
    LANGUAGE=es_ES:es \
    LC_ALL=es_ES.UTF-8 \
    TZ=Europe/Madrid

# Add the WildFly distribution to /opt, and make wildfly the owner of the extracted tar content
# Make sure the distribution is available from a well-known place

# curl -L -O -A "Mozilla/5.0" https://github.com/wildfly/wildfly/releases/download/27.0.0.Final/wildfly-27.0.0.Final.tar.gz


RUN cd $HOME \
    && curl -L -O -A "Mozilla/5.0" https://github.com/wildfly/wildfly/releases/download/$WILDFLY_VERSION/wildfly-$WILDFLY_VERSION.tar.gz \
    && sha1sum wildfly-$WILDFLY_VERSION.tar.gz | grep $WILDFLY_SHA1 \
    && tar xf wildfly-$WILDFLY_VERSION.tar.gz \
    && mv $HOME/wildfly-$WILDFLY_VERSION $JBOSS_HOME \
    && rm wildfly-$WILDFLY_VERSION.tar.gz \
    && chown -R jboss:0 ${JBOSS_HOME} \
    && chmod -R g+rw ${JBOSS_HOME}

# Ensure signals are forwarded to the JVM process correctly for graceful shutdown
ENV LAUNCH_JBOSS_IN_BACKGROUND=true

USER root
WORKDIR /tmp

RUN printenv > env.properties 

USER ${JBOSS_USER}
WORKDIR ${JBOSS_HOME}

# Wildfly administration
# RUN bin/add-user.sh ${ADMIN_USER} ${ADMIN_PASSWORD} --silent 

# PostgreSQL drivers
RUN curl -OL https://jdbc.postgresql.org/download/postgresql-${POSTGRESQL_JDBC_VERSION}.jar
COPY ./wildfly/bin/driver-postgresql-install-offline.cli bin
RUN bin/jboss-cli.sh --file=bin/driver-postgresql-install-offline.cli && \
    rm postgresql-42.2.5.jar && \
    rm bin/driver-postgresql-install-offline.cli

# Oracle drivers
RUN curl -OL https://repo1.maven.org/maven2/com/oracle/database/jdbc/ojdbc8/${ORACLE_JDBC_VERSION}/ojdbc8-${ORACLE_JDBC_VERSION}.jar
COPY ./wildfly/bin/driver-oracle-install-offline.cli bin
RUN bin/jboss-cli.sh --file=bin/driver-oracle-install-offline.cli && \
    rm ojdbc8-${ORACLE_JDBC_VERSION}.jar && \
    rm bin/driver-oracle-install-offline.cli

# SQL Server Drivers
# RUN curl -o sqljdbc_12.2.0.0_enu.tar.gz -L https://go.microsoft.com/fwlink/?linkid=2222954 && \
#     tar -xvzf sqljdbc_12.2.0.0_enu.tar.gz
# COPY ./wildfly/bin/driver-sqlserver-install-offline.cli bin
# RUN bin/jboss-cli.sh --file=bin/driver-sqlserver-install-offline.cli && \
#     rm sqljdbc_12.2.0.0_enu.tar.gz && \
#     rm -rf sqljdbc_12.2  && \
#     rm bin/driver-sqlserver-install-offline.cli

# Wildfly-Keycloak connector

# RUN curl -L https://downloads.jboss.org/keycloak/${KEYCLOAK_VERSION}/adapters/keycloak-oidc/keycloak-wildfly-adapter-dist-${KEYCLOAK_VERSION}.tar.gz | tar zx &&\
#      bin/jboss-cli.sh --file=bin/adapter-elytron-install-offline.cli
# COPY ./wildfly/bin/goibusuari-add-keycloak-offline.cli bin
# RUN sed -i "s/<resolve-parameter-values>false<\/resolve-parameter-values>/ <resolve-parameter-values>true<\/resolve-parameter-values>/" bin/jboss-cli.xml &&\ 
#      bin/jboss-cli.sh --file=bin/goibusuari-add-keycloak-offline.cli --properties=/tmp/env.properties

COPY ./wildfly/bin/elytronkeycloakbridge-install-offline.cli bin
RUN bin/jboss-cli.sh --file=bin/elytronkeycloakbridge-install-offline.cli && \
    rm bin/elytronkeycloakbridge-install-offline.cli

COPY ./wildfly/bin/goibusuari-add-keycloak-offline.cli bin
RUN bin/jboss-cli.sh --file=bin/goibusuari-add-keycloak-offline.cli && \
    rm bin/goibusuari-add-keycloak-offline.cli

# RUN bin/add-user.sh -a -u u999000 -p u999000 -g EBO_ADMIN,EBO_USER,NBM_ADMIN,NBM_USER

COPY ./wildfly/bin/add-system-properties.cli bin
RUN bin/jboss-cli.sh --file=bin/add-system-properties.cli && \
    rm bin/add-system-properties.cli

# Log settings
COPY ./wildfly/bin/https-add-offline.cli bin
RUN bin/jboss-cli.sh --file=bin/https-add-offline.cli && \
    rm bin/https-add-offline.cli

# Project lombok
# RUN curl -OL https://repo1.maven.org/maven2/org/projectlombok/lombok/${LOMBOK_VERSION}/lombok-${LOMBOK_VERSION}.jar
# COPY ./wildfly/bin/lombok-install-offline.cli bin
# RUN bin/jboss-cli.sh --file=bin/lombok-install-offline.cli && \
#    rm lombok-${LOMBOK_VERSION}.jar && \
#    rm bin/lombok-install-offline.cli

# Log settings
COPY ./wildfly/bin/logger-add-offline.cli bin
 RUN bin/jboss-cli.sh --file=bin/logger-add-offline.cli && \
    rm bin/logger-add-offline.cli


# Ajp connector settings
COPY ./wildfly/bin/ajp-add-offline.cli bin
 RUN bin/jboss-cli.sh --file=bin/ajp-add-offline.cli && \
    rm bin/ajp-add-offline.cli


    
######################################################################################################

RUN rm -rf standalone/configuration/standalone_xml_history/current


COPY docker-entrypoint.sh /opt/jboss/
RUN chmod +x /opt/jboss/docker-entrypoint.sh

EXPOSE 8080 8443 9990 8009

ENTRYPOINT ["/opt/jboss/docker-entrypoint.sh"]


#ENTRYPOINT ["/bin/bash", "-c"]

#CMD ["bin/standalone.sh -b 0.0.0.0 -bmanagement 0.0.0.0"]

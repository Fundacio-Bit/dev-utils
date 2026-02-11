#############################################################################################
# Keycloak 6.0.1 adaptado al entorno de desarrollo del Govern de les Illes Balears (GOIB)
#
# Comando para construir la imagen: 
# docker build -t goib/keycloak:6.0.1 .
#
# Comando para crear y ejecutar un contenedor: 
# docker run -p 8180:8180 goib/keycloak:6.0.1
#
# Expone el puerto 8180
#
# Incluye: el realm GOIB; los clientes goib-default y goib-ws; el rol EBO_SUPERVISOR a nivel
# de realm y clientes; el usuario u999000 con password u999000 para autenticación goib-default;
# y el usuario $GOIB_USUARI con password $GOIB_USUARI para autenticación goib-ws
#
#############################################################################################


FROM quay.io/keycloak/keycloak:24.0.1
# FROM quay.io/keycloak/keycloak:24.0.1 as builder

# Enable health and metrics support
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true
ENV KC_HTTP_PORT=8080
ENV KC_HTTPS_PORT=8443

# WORKDIR /opt/keycloak
# # for demonstration purposes only, please make sure to use proper certificates in production instead
# RUN keytool -genkeypair -storepass password -storetype PKCS12 -keyalg RSA -keysize 2048 -dname "CN=server" -alias server -ext "SAN:c=DNS:localhost,IP:127.0.0.1" -keystore conf/server.keystore
# RUN /opt/keycloak/bin/kc.sh build


# FROM quay.io/keycloak/keycloak:24.0.1

# COPY --from=builder /opt/keycloak/ /opt/keycloak/

LABEL MAINTAINER=${DOCKER_FILE_MAINTAINER}
ENV KEYCLOAK_ADMIN=${KEYCLOAK_ADMIN_USER} \
    KEYCLOAK_ADMIN_PASSWORD=${KEYCLOAK_ADMIN_PASS}
    # KEYCLOAK_IMPORT=/tmp/import-goib-realm.json

WORKDIR /opt/keycloak/

# COPY ./keycloak/conf/import-goib-realm.json /tmp

# Https settings
# COPY ./keycloak/bin/https-add-offline.cli /tmp

USER root

# COPY ./keycloak/bin/add-system-properties.cli keycloak/bin
# RUN keycloak/bin/jboss-cli.sh --file=keycloak/bin/add-system-properties.cli && \
#     rm keycloak/bin/add-system-properties.cli

# # Log settings
# COPY ./keycloak/bin/https-add-offline.cli keycloak/bin
# RUN keycloak/bin/jboss-cli.sh --file=keycloak/bin/https-add-offline.cli && \
#    rm keycloak/bin/https-add-offline.cli

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]

# #####################################################################################################

# RUN rm -rf keycloak/standalone/configuration/standalone_xml_history/current

EXPOSE 8080 8443

# CMD ["start -b 0.0.0.0 -bmanagement 0.0.0.0 -Djboss.socket.binding.port-offset=100"]

# CMD ["start -b 0.0.0.0 -bmanagement 0.0.0.0"]

CMD ["start", "--verbose"]
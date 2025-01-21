# Usa nginx:latest como imagen base
FROM nginx:1.26.2

# Actualiza los paquetes e instala nginx-extras
RUN apt-get update && \
    apt-get install -y --no-install-recommends alien dpkg-dev debhelper build-essential curl tzdata && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Configurar la zona horaria a CET
RUN ln -fs /usr/share/zoneinfo/Europe/Madrid /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata


RUN curl -O https://extras.getpagespeed.com/fedora/41/x86_64/RPMS/nginx-module-ajp-1.26.2+0.3.3-8.fc41.gps.x86_64.rpm  \
    && alien -k nginx-module-ajp-1.26.2+0.3.3-8.fc41.gps.x86_64.rpm \
    && dpkg -i nginx-module-ajp_1.26.2+0.3.3-8.fc41.gps_amd64.deb \
    && rm nginx-module-ajp-1.26.2+0.3.3-8.fc41.gps.x86_64.rpm

# Binarios del módulo AJP de NGINX en /usr/lib64/nginx/modules

RUN echo "load_module /usr/lib64/nginx/modules/ngx_http_ajp_module.so;" | cat - /etc/nginx/nginx.conf > temp && mv temp /etc/nginx/nginx.conf 

# Exponer los puertos que utilizará el contenedor
EXPOSE 80 81 443

# Comando por defecto para iniciar NGINX
CMD ["nginx", "-g", "daemon off;"]

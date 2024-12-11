#!/bin/bash
# Copiar los archivos SSL al directorio correcto
cp /docker-entrypoint-initdb.d/server.crt /var/lib/postgresql/ssl/server.crt
cp /docker-entrypoint-initdb.d/server.key /var/lib/postgresql/ssl/server.key
cp /docker-entrypoint-initdb.d/ca.crt /var/lib/postgresql/ssl/ca.crt

# Cambiar los permisos de los archivos SSL
chmod 600 /var/lib/postgresql/ssl/server.key
chmod 644 /var/lib/postgresql/ssl/server.crt
chmod 644 /var/lib/postgresql/ssl/ca.crt

# Iniciar PostgreSQL con SSL habilitado
exec postgres -c ssl=on -c ssl_cert_file=/var/lib/postgresql/ssl/server.crt -c ssl_key_file=/var/lib/postgresql/ssl/server.key -c ssl_ca_file=/var/lib/postgresql/ssl/ca.crt
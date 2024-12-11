#!/bin/bash

# Variables de configuración
DEFAULT_USER="guest"
DEFAULT_PASS="guest"
NEW_USER=${NEW_USER}
NEW_PASS=${NEW_PASS}
VHOST="koyunmft"

LOGS_EXCHANGE="logs_exchange"
LOGS_QUEUES=("audit_logs" "system_logs" "transfer_logs")
LOGS_ROUTING_KEY=("audit_logs" "system_logs" "transfer_logs")

SYSTEM_EVENTS_EXCHANGE="system_events"
SYSTEM_EVENTS_QUEUES=("sftp_system_events" "pesit_system_events")
SYSTEM_EVENTS_ROUTING_KEY=("sftp_system_events" "pesit_system_events")

# Esperar a que RabbitMQ esté listo
sleep 15

# Crear un nuevo usuario
rabbitmqctl add_user $NEW_USER $NEW_PASS
rabbitmqctl set_user_tags $NEW_USER administrator
rabbitmqctl set_permissions -p / $NEW_USER ".*" ".*" ".*"

# Crear un virtual host
rabbitmqctl add_vhost $VHOST
rabbitmqctl set_permissions -p $VHOST $NEW_USER ".*" ".*" ".*"

# Crear exchanges
rabbitmqadmin -u $NEW_USER -p $NEW_PASS -V $VHOST declare exchange name=$LOGS_EXCHANGE type=topic durable=true
rabbitmqadmin -u $NEW_USER -p $NEW_PASS -V $VHOST declare exchange name=$SYSTEM_EVENTS_EXCHANGE type=topic durable=true

# Crear y vincular las colas de logs
for i in "${!LOGS_QUEUES[@]}"; do
  queue=${LOGS_QUEUES[$i]}
  routing_key=${LOGS_ROUTING_KEY[$i]}
  rabbitmqadmin -u $NEW_USER -p $NEW_PASS -V $VHOST declare queue name=$queue durable=true
  rabbitmqadmin -u $NEW_USER -p $NEW_PASS -V $VHOST declare binding source=$LOGS_EXCHANGE destination_type=queue destination=$queue routing_key=$routing_key
done

# Crear y vincular las colas de eventos del sistema
for i in "${!SYSTEM_EVENTS_QUEUES[@]}"; do
  queue=${SYSTEM_EVENTS_QUEUES[$i]}
  routing_key=${SYSTEM_EVENTS_ROUTING_KEY[$i]}
  rabbitmqadmin -u $NEW_USER -p $NEW_PASS -V $VHOST declare queue name=$queue durable=true
  rabbitmqadmin -u $NEW_USER -p $NEW_PASS -V $VHOST declare binding source=$SYSTEM_EVENTS_EXCHANGE destination_type=queue destination=$queue routing_key=$routing_key
done

echo "Configuración completada."
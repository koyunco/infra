FROM rabbitmq:4-management

# Crear directorio para los certificados y configuración
RUN mkdir -p /etc/rabbitmq/certs /etc/rabbitmq/init

# Copiar certificados, configuración y el script de inicialización
COPY rabbitmq.conf /etc/rabbitmq/
COPY server.key /etc/rabbitmq/certs/
COPY server.crt /etc/rabbitmq/certs/
COPY init_rabbitmq.sh /etc/rabbitmq/init/

# Dar permisos de ejecución al script
RUN chmod +x /etc/rabbitmq/init/init_rabbitmq.sh

# Exponer los puertos SSL
EXPOSE 5671 15671

# Definir el punto de entrada para ejecutar RabbitMQ y el script de inicialización
CMD ["sh", "-c", "/etc/rabbitmq/init/init_rabbitmq.sh & rabbitmq-server"]

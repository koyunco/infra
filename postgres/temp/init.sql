-- Crear usuarios
CREATE USER koyunmft WITH ENCRYPTED PASSWORD 'KoyunMft_Password!';
CREATE USER koyunmftqa WITH ENCRYPTED PASSWORD 'KoyunMft_Password!_qa';
CREATE USER koyunmftdev WITH ENCRYPTED PASSWORD 'KoyunMft_Password!_dev';

-- Crear bases de datos
CREATE DATABASE koyunmft OWNER koyunmft;
CREATE DATABASE koyunmftqa OWNER koyunmftqa;
CREATE DATABASE koyunmftdev OWNER koyunmftdev;

-- Asignar privilegios adicionales si es necesario
GRANT ALL PRIVILEGES ON DATABASE koyunmft TO koyunmft;
GRANT ALL PRIVILEGES ON DATABASE koyunmftqa TO koyunmftqa;
GRANT ALL PRIVILEGES ON DATABASE koyunmftdev TO koyunmftdev;

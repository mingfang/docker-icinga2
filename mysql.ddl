CREATE DATABASE icinga;
GRANT SELECT, INSERT, UPDATE, DELETE, DROP, CREATE VIEW, INDEX, EXECUTE ON icinga.* TO 'icinga'@'localhost' IDENTIFIED BY 'icinga';

CREATE USER `icingaweb`@`localhost` IDENTIFIED BY 'icingaweb';
CREATE DATABASE `icingaweb`;
GRANT ALL PRIVILEGES ON `icingaweb`.* TO `icingaweb`@`localhost`;
FLUSH PRIVILEGES;

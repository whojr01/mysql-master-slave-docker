/*
  * config_users
  * Sets the root password after datadir is created
  * Creates mysql user with passowrd mysql-pass
  * Creates replication user with password replication
  * Grants privileges to mysql user
*/

ALTER USER 'root'@'localhost' IDENTIFIED BY 'mysql-pass';

CREATE USER 'root'@'127.0.0.1' IDENTIFIED BY 'mysql-pass';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost', 'root'@'127.0.0.1' WITH GRANT OPTION;

CREATE USER 'mysql'@'localhost' IDENTIFIED BY 'mysql-pass';
CREATE USER 'mysql'@'127.0.0.1' IDENTIFIED BY 'mysql-pass';

GRANT CREATE, INSERT, DROP, UPDATE, SELECT, SHUTDOWN ON *.* TO 'mysql'@'localhost', 'mysql'@'127.0.0.1';

CREATE USER 'replication'@'localhost' IDENTIFIED BY 'replication';
CREATE USER 'replication'@'127.0.0.1' IDENTIFIED BY 'replication';

GRANT REPLICATION SLAVE ON *.* TO 'replication'@'localhost', 'replication'@'127.0.0.1';

flush privileges;
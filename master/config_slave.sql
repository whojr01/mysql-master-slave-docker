/*
  * config_master
  * Sets the root password after datadir is created
  * Creates mysql user with passowrd mysql-pass
  * Grants privileges to mysql user
  * Creates the replication user and grants privileges to it.
*/

ALTER USER 'root'@'localhost' IDENTIFIED BY 'mysql-pass';

CREATE USER 'mysql'@'localhost' IDENTIFIED BY 'mysql-pass';
GRANT CREATE, INSERT, DROP, UPDATE, SELECT, SHUTDOWN ON *.* TO 'mysql'@'localhost';

CREATE USER 'replication'@'localhost' IDENTIFIED BY 'replication';
GRANT REPLICATION SLAVE ON *.* TO 'replication'@'localhost';

flush privileges;

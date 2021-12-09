/*
  * config_master
  * Sets the root password after datadir is created
  * Creates mysql user with passowrd mysql-pass
  * Grants privileges to mysql user
*/

ALTER USER 'root'@'localhost' IDENTIFIED BY 'mysql-pass';

CREATE USER 'mysql'@'localhost' IDENTIFIED BY 'mysql-pass';
GRANT CREATE, INSERT, DROP, UPDATE, SELECT,SHUTDOWN ON *.* TO 'mysql'@'localhost';
flush privileges;

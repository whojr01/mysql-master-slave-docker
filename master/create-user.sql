CREATE USER 'mysql'@'localhost' IDENTIFIED BY 'mysql-pass';
GRANT CREATE, INSERT, DROP, UPDATE, SELECT ON *.* TO 'mysql'@'localhost';
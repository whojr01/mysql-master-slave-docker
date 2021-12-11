# Step *** 1/18
FROM debian:bullseye-slim

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
# Step *** 2/18
RUN groupadd -r mysql && useradd -r -g mysql mysql

# Step *** 3/18
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y --no-install-recommends gnupg dirmngr gosu pwgen openssl perl && \
    rm -rf /var/lib/apt/lists/* && \
    gosu nobody true

# Step *** 4/18
# Check for missing chown in output
RUN mkdir /docker-entrypoint-initdb.d /var/lib/mysql-files /var/lib/mysql_slave \
          /var/lib/mysql /var/log/mysql /var/log/mysql_slave; \
          chown mysql:mysql -R /var/lib/mysql_slave /var/lib/mysql-files \
          /var/lib/mysql /var/log/mysql /var/log/mysql_slave


# gpg: key 5072E1F5: public key "MySQL Release Engineering <mysql-build@oss.oracle.com>" imported
# Step *** 5/18
RUN set -ex; \
        key='A4A9406876FCBD3C456770C88C718D3B5072E1F5'; \
        export GNUPGHOME="$(mktemp -d)"; \
        gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key"; \
        gpg --batch --export "$key" > /etc/apt/trusted.gpg.d/mysql.gpg; \
        gpgconf --kill all; \
        rm -rf "$GNUPGHOME"; \
        apt-key list > /dev/null

# Step *** 6/18
ENV MYSQL_MAJOR 8.0
# Step *** 7/18
ENV MYSQL_VERSION 8.0.27-1debian11

# Step *** 8/18
RUN echo "deb http://repo.mysql.com/apt/debian/ bullseye mysql-${MYSQL_MAJOR}" > /etc/apt/sources.list.d/mysql.list

# the "/var/lib/mysql" stuff here is because the mysql-server postinst doesn't have an explicit way to disable the mysql_install_db codepath besides having a database already "configured" (ie, stuff in /var/lib/mysql/mysql)
# also, we set debconf keys to make APT a little quieter
# Step *** 9/18
RUN { \
                echo mysql-community-server mysql-community-server/data-dir select ''; \
                echo mysql-community-server mysql-community-server/root-pass password ''; \
                echo mysql-community-server mysql-community-server/re-root-pass password ''; \
                echo mysql-community-server mysql-community-server/remove-test-db select false; \
        } | debconf-set-selections \
        && apt-get update && apt-get install -y mysql-community-client="${MYSQL_VERSION}" mysql-community-server-core="${MYSQL_VERSION}" && rm -rf /var/lib/apt/lists/* \
        && rm -rf /var/lib/mysql && mkdir -p /var/lib/mysql /var/run/mysqld \
        && chown -R mysql:mysql /var/lib/mysql /var/run/mysqld \
# ensure that /var/run/mysqld (used for socket and lock files) is writable regardless of the UID our mysqld instance ends up having at runtime
        && chmod 700 /var/run/mysqld


## TODO: REMOVE BELOW FOR DEBUG ONLY
# Step *** 10/18
RUN apt-get update && apt-get install -y procps net-tools iproute2 file vim


# Config files
# Step *** 12/18
COPY  mysql/my.cnf /etc/mysql/
COPY mysql/conf.d/docker.cnf /etc/mysql/conf.d/

# Step *** 13/18
COPY docker-entrypoint.sh /usr/local/bin/

COPY replication.sh /scripts/
COPY config_users.sql /scripts/
RUN chmod 755 /scripts/replication.sh

#
# --------------------------
# Resequence from here
#---------------------------

RUN ln -s usr/local/bin/docker-entrypoint.sh /entrypoint.sh # backwards compat

RUN chmod -R 700 /var/lib/mysql /var/lib/mysql-files /var/lib/mysql_slave \
    && gosu mysql mysqld --initialize --basedir=/usr --user=mysql --datadir=/var/lib/mysql --port=3306 --secure-file-priv=/var/lib/mysql > /var/log/mysql/error_master.log 2>&1 \
    && gosu mysql mysqld --datadir=/var/lib/mysql & \
    while [ ! -f /var/lib/mysql/*.pid ]; do sleep 2; echo mysql looking for pid; done \
    && export MPASS=$(cat /var/log/mysql/error_master.log | tail -1 | sed -e 's/.*localhost: \(.*\)$/\1/') \
    && gosu mysql mysql -uroot -p$MPASS --connect-expired-password < /scripts/config_users.sql \
    && kill -TERM $(cat /var/lib/mysql/*.pid) \
    && gosu mysql mysqld --initialize --basedir=/usr --user=mysql --datadir=/var/lib/mysql_slave --port=3306 --secure-file-priv=/var/lib/mysql_slave > /var/log/mysql_slave/error_slave.log 2>&1 \
    && gosu mysql mysqld --datadir=/var/lib/mysql_slave & \
    while [ ! -f /var/lib/mysql_slave/*.pid ]; do sleep 2; echo mysql_slave looking for pid; done \
    && export MPASS=$(cat /var/log/mysql_slave/error_slave.log | tail -1 | sed -e 's/.*localhost: \(.*\)$/\1/') \
    && gosu mysql mysql -uroot -p$MPASS --connect-expired-password < /scripts/config_users.sql \
    && kill -TERM $(cat /var/lib/mysql_slave/*.pid) \
    && chown -R mysql:mysql /var/log/mysql /var/log/mysql_slave \
    && ls -l /var/lib/mysql/*.pid /var/lib/mysql_slave/*.pid || true \
    && rm -f /var/lib/mysql/*.pid /var/lib/mysql_slave/*.pid || true \
    && mysqld_multi report \
    && mysqld_multi start \
    && sleep 30 \
    && mysqld_multi report \
    && mysqldump -uroot -pmysql-pass --port=3306 --protocol=tcp --all-databases --source-data=2 > /var/log/mysql/replicationdump.sql \
    && /scripts/replication.sh /var/log/mysql/replicationdump.sql > /scripts/replication_cmd.sql \
    && mysql -uroot -pmysql-pass --port=3307 --protocol=tcp < /scripts/replication_cmd.sql

RUN mysqld_multi report

VOLUME /var/lib/mysql /var/lib/mysql_slave

EXPOSE 3306 3307 33161 33262

#ENTRYPOINT ["docker-entrypoint.sh"]


# CMD ["mysqld_multi", "start"]
CMD ["/bin/bash"]

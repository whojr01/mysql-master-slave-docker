FROM debian:bullseye-slim

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r mysql && useradd -r -g mysql mysql

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y --no-install-recommends gnupg dirmngr gosu pwgen openssl perl && \
    rm -rf /var/lib/apt/lists/* && \
    gosu nobody true

RUN mkdir /docker-entrypoint-initdb.d /var/lib/mysql-files /var/lib/mysql_slave \
          /var/lib/mysql /var/log/mysql /var/log/mysql_slave \
          && chown mysql:mysql -R /var/lib/mysql-files /var/lib/mysql_slave \
          /var/lib/mysql /var/log/mysql /var/log/mysql_slave


# gpg: key 5072E1F5: public key "MySQL Release Engineering <mysql-build@oss.oracle.com>" imported
RUN set -ex; \
        key='A4A9406876FCBD3C456770C88C718D3B5072E1F5'; \
        export GNUPGHOME="$(mktemp -d)"; \
        gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key"; \
        gpg --batch --export "$key" > /etc/apt/trusted.gpg.d/mysql.gpg; \
        gpgconf --kill all; \
        rm -rf "$GNUPGHOME"; \
        apt-key list > /dev/null

ENV MYSQL_MAJOR 8.0
ENV MYSQL_VERSION 8.0.27-1debian11

RUN echo "deb http://repo.mysql.com/apt/debian/ bullseye mysql-${MYSQL_MAJOR}" > /etc/apt/sources.list.d/mysql.list

# the "/var/lib/mysql" stuff here is because the mysql-server postinst doesn't have an explicit way to disable the mysql_install_db codepath besides having a database already "configured" (ie, stuff in /var/lib/mysql/mysql)
# also, we set debconf keys to make APT a little quieter
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
        && chmod 777 /var/run/mysqld


## TODO: REMOVE BELOW FOR DEBUG ONLY
RUN apt-get update && apt-get install -y procps net-tools iproute2 file vim

VOLUME /var/lib/mysql
# Config files
COPY  etc-mysql/mysql/ /etc/mysql/
COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh /entrypoint.sh # backwards compat
# RUN mysqld --initialize --user=mysql --basedir=/usr --datadir=/var/lib/mysql_slave
RUN mysqld --initialize --defaults-file=/etc/mysql/my.cnf
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 3306 3307 3308 33060 33161 33262
CMD ["bash"]


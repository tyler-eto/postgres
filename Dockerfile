FROM ubuntu:14.04

RUN apt-get -yq install git
RUN git clone https://github.com/tyler-eto/postgres

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/pgdg.list

RUN apt-get update && apt-get -y -q install python-software-properties software-properties-common \
    && apt-get -y -q install postgresql-9.3 postgresql-client-9.3 postgresql-contrib-9.3

USER postgres
RUN /etc/init.d/postgresql start \
    && psql -c "CREATE USER tyler WITH SUPERUSER PASSWORD 'changemoi'" \
    && psql -c "ALTER ROLE tyler WITH superuser" \
	&& psql -c "ALTER ROLE tyler WITH createdb" \
	&& psql -c "ALTER ROLE tyler WITH replication" \
	&& psql -c "ALTER ROLE tyler WITH createrole" \
	&& psql -c "CREATE DATABASE iterations" \
	&& psql -c "GRANT ALL PRIVILEGES ON DATABASE iterations TO tyler" \
	&& psql -c "CREATE TABLE sublime (id SERIAL PRIMARY KEY, dataset_id INTEGER, dataset_nm VARCHAR, records_acquired INTEGER,
                records_cleaned INTEGER, status VARCHAR, complete BOOLEAN)" \
	&& psql -c "GRANT ALL PRIVILEGES ON TABLE sublime TO tyler" \
	&& psql -c "COPY sublime (dataset_nm, dataset_nm, records_acquired, records_cleaned, status, complete) FROM '/postgres/datasets.txt' (DELIMITER('|'))"

USER root
RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/9.3/main/pg_hba.conf
RUN echo "listen_addresses='*'" >> /etc/postgresql/9.3/main/postgresql.conf

EXPOSE 5432

RUN mkdir -p /var/run/postgresql && chown -R postgres /var/run/postgresql
VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

USER postgres
CMD ["/usr/lib/postgresql/9.3/bin/postgres", "-D", "/var/lib/postgresql/9.3/main", "-c", "config_file=/etc/postgresql/9.3/main/postgresql.conf"]


### solve connection issues, can't connect bc it can't find the sublime table, make sure sublime is within iterations db!
### may not need to create database since it'll just default to "public" schema
### for psycopg2, just don't use "dbname" argument

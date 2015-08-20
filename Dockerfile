FROM ubuntu:14.04

RUN apt-get -yq install git
RUN git clone https://github.com/tyler-eto/postgres.git

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
	&& psql -c "CREATE SCHEMA iterations" \
	&& psql -c "GRANT ALL ON SCHEMA iterations TO tyler" \
	&& psql -c "GRANT ALL ON ALL TABLES IN SCHEMA iterations TO tyler" \
	&& psql -c "CREATE TABLE iterations.sublime (id SERIAL PRIMARY KEY, dataset_id INTEGER, dataset_nm VARCHAR, records_acquired INTEGER, \
                records_cleaned INTEGER, status VARCHAR, complete BOOLEAN)" \
	&& psql -c "COPY iterations.sublime (dataset_id, dataset_nm, records_acquired, records_cleaned, status, complete) FROM '/postgres/datasets.txt' (DELIMITER('|'))"

USER root
RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/9.3/main/pg_hba.conf
RUN echo "listen_addresses='*'" >> /etc/postgresql/9.3/main/postgresql.conf

EXPOSE 5432

RUN mkdir -p /var/run/postgresql && chown -R postgres /var/run/postgresql
VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

USER postgres
CMD ["/usr/lib/postgresql/9.3/bin/postgres", "-D", "/var/lib/postgresql/9.3/main", "-c", "config_file=/etc/postgresql/9.3/main/postgresql.conf &"]

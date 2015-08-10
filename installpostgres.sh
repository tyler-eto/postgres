#!/usr/bin/env bash

# automation of database creation
psql -c "CREATE USER tyler WITH PASSWORD changemoi"
psql -c "ALTER ROLE tyler WITH superuser"
psql -c "ALTER ROLE tyler WITH createdb"
psql -c "ALTER ROLE tyler WITH replication"
psql -c "ALTER ROLE tyler WITH createrole"
psql -c "CREATE DATABASE iterations"
psql -c "GRANT ALL PRIVILEGES ON DATABASE iterations TO tyler"
psql -c "CREATE TABLE sublime (id SERIAL PRIMARY KEY, dataset_id INTEGER, dataset_nm VARCHAR, records_acquired INTEGER,
                        records_cleaned INTEGER, complete BOOLEAN)"
psql -c "GRANT ALL PRIVILEGES ON TABLE sublime TO tyler"

# copy data from text file to table - sublime
psql -c "COPY sublime (dataset_nm, dataset_nm, records_acquired, records_cleaned, complete) FROM 'dataset.txt' (DELIMITERS(','))"

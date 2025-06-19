CREATE USER kirvano CREATEDB;
ALTER USER kirvano PASSWORD 'REPLACE_WITH_PASSWORD';
ALTER ROLE kirvano SUPERUSER;

UPDATE pg_database SET datistemplate = FALSE WHERE datname = 'template1';
DROP DATABASE template1;
CREATE DATABASE template1 WITH TEMPLATE = template0 ENCODING = 'UNICODE';
UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'template1';

\c template1;
VACUUM FREEZE;

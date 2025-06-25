-- Create test database for running tests
CREATE DATABASE kirvano_test;
GRANT ALL PRIVILEGES ON DATABASE kirvano_test TO kirvano;

-- Create additional schemas if needed
\c kirvano_development;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";

\c kirvano_test;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";
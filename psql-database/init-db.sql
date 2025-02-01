-- Check if the user 'test' exists, and create it if it does not
DO
$$
BEGIN
   IF NOT EXISTS (
      SELECT FROM pg_catalog.pg_roles
      WHERE rolname = 'test') THEN
      CREATE USER test WITH PASSWORD '1234';
   END IF;
END
$$;

-- Check if the database 'employees' exists, and create it if it does not
DO
$$
BEGIN
   IF NOT EXISTS (
      SELECT FROM pg_database
      WHERE datname = 'employees') THEN
      CREATE DATABASE employees;
   END IF;
END
$$;

-- Grant all privileges on the database 'employees' to the user 'test'
GRANT ALL PRIVILEGES ON DATABASE employees TO test;

-- Switch to the 'employees' database
\c employees

-- Grant usage and privileges on the public schema to the user 'test'
GRANT USAGE ON SCHEMA public TO test;
GRANT CREATE ON SCHEMA public TO test;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO test;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO test

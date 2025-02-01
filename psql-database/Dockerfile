# Use the official PostgreSQL image from the Docker Hub
FROM postgres:latest

# Environment variables for PostgreSQL
ENV POSTGRES_DB=employees
ENV POSTGRES_USER=test
ENV POSTGRES_PASSWORD=1234

# Define a custom path for PostgreSQL data
ENV PGDATA=/var/lib/postgresql/custom_data

# Create the custom data directory and set permissions
RUN mkdir -p /var/lib/postgresql/custom_data && chown -R postgres:postgres /var/lib/postgresql/custom_data

# Create the configuration directory to avoid missing directory errors
RUN mkdir -p /etc/postgresql/conf.d

# Copy initialization SQL script to the Docker image
COPY init-db.sql /docker-entrypoint-initdb.d/

# Copy custom PostgreSQL configuration file
COPY postgresql.conf /etc/postgresql/postgresql.conf

# Expose the PostgreSQL port
EXPOSE 5432

# Ensure PostgreSQL uses the custom configuration and data directory
CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf"]

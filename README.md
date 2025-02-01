# Deploy Employee App through Docker

## Step 1: Create an Instance and Connect

![Screenshot](https://github.com/user-attachments/assets/2e71e7cb-9673-4c80-aeb1-dfad9d5d2fa4)

- Create a virtual machine (VM) or EC2 instance and connect to it via SSH.
- Ensure your instance is running Ubuntu.

## Step 2: Write the Dockerfile for the Backend

Create a `Dockerfile` for the PostgreSQL database used by your backend.

```Dockerfile
# Use the official PostgreSQL image from Docker Hub
FROM postgres:latest

# Set environment variables for PostgreSQL configuration
ENV POSTGRES_DB=employees
ENV POSTGRES_USER=test
ENV POSTGRES_PASSWORD=1234
ENV PGDATA=/var/lib/postgresql/custom_data

# Create a custom data directory and set proper permissions
RUN mkdir -p /var/lib/postgresql/custom_data && chown -R postgres:postgres /var/lib/postgresql/custom_data

# Create configuration directory to avoid errors
RUN mkdir -p /etc/postgresql/conf.d

# Copy the initialization SQL script to the container
COPY init-db.sql /docker-entrypoint-initdb.d/

# Copy custom PostgreSQL configuration file
COPY postgresql.conf /etc/postgresql/postgresql.conf

# Expose PostgreSQL port
EXPOSE 5432

# Start PostgreSQL with custom configuration
CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf"]
```

### PostgreSQL Configuration File (`postgresql.conf`)

```plaintext
# PostgreSQL configuration file
# Set the data directory for the PostgreSQL instance
data_directory = '/var/lib/postgresql/custom_data'

# Set the connection settings
listen_addresses = '*'
port = 5432

# Enable logging and set the log directory
logging_collector = on
log_directory = 'log'
log_filename = 'postgresql.log'

# Additional PostgreSQL settings can go here
```

### Database Initialization Script (`init-db.sql`)

```sql
-- Check if the user 'test' exists, and create it if it doesn't
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

-- Check if the database 'employees' exists, and create it if it doesn't
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

-- Grant privileges on the 'employees' database to the 'test' user
GRANT ALL PRIVILEGES ON DATABASE employees TO test;

-- Switch to the 'employees' database
\c employees

-- Grant usage and privileges on the public schema to the 'test' user
GRANT USAGE ON SCHEMA public TO test;
GRANT CREATE ON SCHEMA public TO test;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO test;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO test;
```

## Step 3: Write Dockerfile for the Backend Service

Create a `Dockerfile` for the backend, which will be a Go-based service that connects to the PostgreSQL database.

```Dockerfile
# Use Ubuntu as the base image
FROM ubuntu:latest

# Set environment variables for the database connection
ENV DB_HOST="<instance_pub_ip>"
ENV DB_USER="test"
ENV DB_PASSWORD="1234"
ENV DB_NAME="employees"
ENV DB_PORT="5432"
ENV ALLOWED_ORIGINS="http://<instance_pub_ip>:3000"

# Set Go environment variables
ENV GOPATH=/go
ENV GOROOT=/usr/local/go
ENV PATH=$PATH:/usr/local/go/bin:$GOPATH/bin

# Update and install dependencies
RUN apt-get update && \
    apt-get install -y wget git build-essential

# Install Go
RUN wget https://golang.org/dl/go1.19.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.19.linux-amd64.tar.gz && \
    rm go1.19.linux-amd64.tar.gz

# Create the working directory for the Go application
RUN mkdir -p /home/ubuntu/project

# Set the working directory
WORKDIR /home/ubuntu/project

# Copy the Go application code to the container
COPY . .

# Expose the port the app will run on
EXPOSE 8080

# Command to run the Go application
CMD ["go", "run", "main.go"]
```

## Step 4: Write Dockerfile for the Frontend Service

Create a `Dockerfile` for the frontend, which is based on Node.js and will be built and served using npm.

```Dockerfile
# Use the official Ubuntu base image for a supported version
FROM ubuntu:bionic

# Set the working directory inside the container
WORKDIR /usr/src/app

# Install curl and Node.js setup script dependencies
RUN apt-get update && \
    apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_14.x | bash -

# Install Node.js (which includes npm)
RUN apt-get install -y nodejs

# Install n globally (optional)
RUN npm install -g n

# Install a specific version of Node.js using n
RUN n 14.17.0

# Copy package.json and package-lock.json files
COPY package*.json ./
COPY .env ./

# Install application dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Expose port 3000
EXPOSE 3000

# Command to start the frontend application
CMD ["npm", "start"]
```

## Step 5: Configure the Public IP in `.env` File

Ensure that your `.env` file contains the correct public IP of your instance for communication between frontend and backend.

```plaintext
REACT_APP_SERVER_URL=http://<instance_pub_ip>:8080/employees
```

Replace `<instance_pub_ip>` with your instance's actual public IP.

## Step 6: Build Docker Images for Database, Backend, and Frontend

Navigate to each service directory (database, backend, frontend) and build the Docker images using the following command:

```bash
docker build -t <image_name> .
```

### Example:

For the database service:
```bash
docker build -t postgres-db .
```

For the backend service:
```bash
docker build -t backend-service .
```

For the frontend service:
```bash
docker build -t frontend-service .
```

## Step 7: Run Containers from the Built Images

Once the Docker images are built, run containers from those images with the following command:

```bash
docker run -d -p <host_port>:<container_port> <image_name>
```

For example:

```bash
docker run -d -p 5432:5432 postgres-db
docker run -d -p 8080:8080 backend-service
docker run -d -p 3000:3000 frontend-service
```

This command will run the containers in detached mode and map the ports from the container to your host.

## Step 8: Access the Application

After running the containers, you can access your frontend app by navigating to the public IP of your instance at port `3000` in your browser.

```plaintext
http://<instance_pub_ip>:3000
```

You should now see your Employee app running.

---

### Notes:
- Make sure you replace `<instance_pub_ip>` with the actual public IP of your instance.
- Ensure that ports `5432`, `8080`, and `3000` are open in your instance's security group to allow external access.
- If you encounter any issues, check the logs of the running containers using `docker logs <container_id>` for debugging.

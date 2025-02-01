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

# Install n globally (if needed)
RUN npm install -g n

# Install Node.js version 14.17.0 using n
RUN n 14.17.0

# Copy package.json and package-lock.json files
COPY package*.json ./
COPY .env ./

# Install application dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Expose port 3000 to the outside world
EXPOSE 3000

# Start the application
CMD ["npm", "start"]

# Use Ubuntu as the base image
FROM ubuntu:latest

# Set environment variables for non-interactive apt installs
ENV DB_HOST="aa4e56e04f37142d9904c2b1a78ecde2-488863630.ap-south-1.elb.amazonaws.com" 
ENV DB_USER="test" 
ENV DB_PASSWORD="1234" 
ENV DB_NAME="employees" 
ENV DB_PORT="5432" 
ENV ALLOWED_ORIGINS="http://a92c35eee02634c09a81847ce1ff7d69-437757805.ap-south-1.elb.amazonaws.com:3000"

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

# Create the Go working directory
RUN mkdir -p /home/ubuntu/project

# Set the working directory
WORKDIR /home/ubuntu/project

# Copy the Go application code to the container
COPY . .

# Expose port 8080 to the outside world
EXPOSE 8080

# Command to run the Go application
CMD ["go", "run", "main.go"]

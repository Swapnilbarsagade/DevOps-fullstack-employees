# Use official Node.js image (Alpine for smaller size)
FROM node:14.17.0-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json first to optimize caching
COPY package*.json ./
COPY .env ./

# Install dependencies
RUN npm install

# Copy the rest of the application files
COPY . .

# Expose port 3000
EXPOSE 3000

# Start the React development server
CMD ["npm", "start"]

# Base image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package.json and install dependencies
COPY package.json .
RUN npm install

# Copy source code
COPY . .

# Expose the necessary port
EXPOSE 3001

# Start the application
CMD ["npm", "start"]

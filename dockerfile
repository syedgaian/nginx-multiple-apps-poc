# Stage 1: Build the Vite applications
FROM node:18-alpine AS builder

# Set working directory for the main site
WORKDIR /app/mainsite

# Copy the main site package files and install dependencies
COPY mainsite/package*.json ./
RUN npm install

# Copy the main site source code and build it
COPY mainsite/ .
RUN npm run build

# Set working directory for the subsite
WORKDIR /app/subsite

# Copy the subsite package files and install dependencies
COPY subsite/package*.json ./
RUN npm install

# Copy the subsite source code and build it
COPY subsite/ .
RUN npm run build

# Stage 2: Serve the Vite applications using Nginx
FROM nginx:alpine

# Copy the built files to Nginx's web root directory
COPY --from=builder /app/mainsite/dist /usr/share/nginx/html
COPY --from=builder /app/subsite/dist /usr/share/nginx/html/subsite

# Copy the custom Nginx configuration file
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 3000
EXPOSE 3000

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]

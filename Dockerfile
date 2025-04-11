# Dockerfile for Angular Frontend
# Build stage
FROM node:20-alpine AS build
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies with specific strategy to avoid ETXTBSY errors
RUN npm config set fetch-retries 5 && \
    npm config set fetch-retry-mintimeout 20000 && \
    npm config set fetch-retry-maxtimeout 120000 && \
    npm config set registry https://registry.npmjs.org/ && \
    # The sleep commands help avoid file busy errors
    (npm install --no-fund || (sleep 5 && npm install --no-fund)) && \
    # Add permissions fix for esbuild
    find node_modules -type f -name "esbuild" -exec chmod +x {} \;

# Copy the rest of the application code
COPY . .

# Comment out the URL replacement since we're using relative URLs now
# RUN sed -i 's|http://localhost:8080/api/hello|http://backend:8080/api/hello|g' src/app/app.component.ts

# Build the application
RUN npm run build

# Runtime stage
FROM nginx:alpine
# Update this line to copy from the browser subdirectory
COPY --from=build /app/dist/frontend/browser /usr/share/nginx/html

# Create nginx config
RUN echo 'server { \
    listen 80; \
    server_name localhost; \
    root /usr/share/nginx/html; \
    index index.html; \
    location / { \
        try_files $uri $uri/ /index.html; \
    } \
    location /api/ { \
        proxy_pass http://backend:8080/api/; \
        proxy_set_header Host $host; \
        proxy_set_header X-Real-IP $remote_addr; \
    } \
}' > /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

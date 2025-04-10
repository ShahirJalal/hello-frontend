# Dockerfile for Angular Frontend
# Build stage
FROM node:20-alpine AS build
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Update API URL to use Docker service name
RUN sed -i 's|http://localhost:8080/api/hello|http://backend:8080/api/hello|g' src/app/app.component.ts

# Build the application
RUN npm run build

# Runtime stage
FROM nginx:alpine
COPY --from=build /app/dist/frontend /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
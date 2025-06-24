# Build stage
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
# ... (your existing Dockerfile content)

# Before installing other packages or building your application, ensure packages are updated
RUN apk update && \
    apk upgrade libxml2 --available && \
    rm -rf /var/cache/apk/*

# Or, if you know you need a specific version:
# RUN apk add libxml2=2.13.4-r6

# ... (rest of your Dockerfile)
RUN npm ci
COPY . .
RUN npm run build

# Production stage
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
# Add nginx configuration if needed
# COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

# Build stage
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./

# It's good practice to update the build image too, but it doesn't affect the final scan
# RUN apk update && \
#     apk upgrade --no-cache && \
#     rm -rf /var/cache/apk/*

RUN npm ci
COPY . .
RUN npm run build

# Production stage
FROM nginx:alpine

# >>> IMPORTANT: Apply the package updates in the final production stage <<<
# Update all packages and specifically upgrade libxml2 to its latest available fixed version
RUN apk update && \
    apk upgrade libxml2 --available && \
    rm -rf /var/cache/apk/*

# If you prefer to be explicit with the fixed version (though `upgrade --available` is generally good):
# RUN apk add --no-cache libxml2=2.13.4-r6 || true # The `|| true` is a safeguard if the exact version isn't immediately available.
# RUN apk update && apk add --no-cache libxml2@community=2.13.4-r6  # For community package

COPY --from=build /app/dist /usr/share/nginx/html
# Add nginx configuration if needed
# COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

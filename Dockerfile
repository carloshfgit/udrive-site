FROM nginx:alpine

# Copy the built files from the dist directory
COPY dist /usr/share/nginx/html

# Copy the custom nginx configuration
# Cloud Run listens on port 8080 by default, our nginx.conf must match this
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 8080 for Cloud Run
EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]

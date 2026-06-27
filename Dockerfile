FROM nginx:1.27-alpine
RUN rm -rf /usr/share/nginx/html/*
COPY k8s-platform.html /usr/share/nginx/html/index.html
COPY nginx.conf /etc/nginx/conf.d/default.conf
RUN printf 'worker_processes auto;\nerror_log /var/log/nginx/error.log warn;\npid /tmp/nginx.pid;\n\nevents {\n    worker_connections 1024;\n}\n\nhttp {\n    client_body_temp_path /tmp/client_temp;\n    proxy_temp_path       /tmp/proxy_temp_path;\n    fastcgi_temp_path     /tmp/fastcgi_temp;\n    uwsgi_temp_path       /tmp/uwsgi_temp;\n    scgi_temp_path        /tmp/scgi_temp;\n\n    include       /etc/nginx/mime.types;\n    default_type  application/octet-stream;\n\n    log_format  main  '"'"'$remote_addr - $remote_user [$time_local] "$request" '"'"'\n                      '"'"'$status $body_bytes_sent "$http_referer" '"'"'\n                      '"'"'"$http_user_agent" "$http_x_forwarded_for"'"'"';\n\n    access_log  /var/log/nginx/access.log  main;\n\n    sendfile        on;\n    keepalive_timeout  65;\n\n    include /etc/nginx/conf.d/*.conf;\n}\n' > /etc/nginx/nginx.conf
RUN addgroup -S appgroup && adduser -S appuser -G appgroup \
    && mkdir -p \
        /tmp/client_temp \
        /tmp/proxy_temp_path \
        /tmp/fastcgi_temp \
        /tmp/uwsgi_temp \
        /tmp/scgi_temp \
        /var/cache/nginx \
        /var/log/nginx \
    && chown -R appuser:appgroup \
        /usr/share/nginx/html \
        /var/cache/nginx \
        /var/log/nginx \
        /etc/nginx/conf.d \
        /tmp/client_temp \
        /tmp/proxy_temp_path \
        /tmp/fastcgi_temp \
        /tmp/uwsgi_temp \
        /tmp/scgi_temp

USER appuser

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:8080/healthz || exit 1

CMD ["nginx", "-g", "daemon off;"]

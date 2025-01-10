# NGINX configuration with best practices and rate limiting for forwarding traffic to Kubernetes NodePorts

events {
    # Maximum number of simultaneous connections that a worker process can handle
    worker_connections 1024;

    # Enable or disable multi-threaded connection handling
    use epoll; # Use efficient I/O for modern Linux systems
}

http {
    # Log formatting for easier debugging
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;

    # Optimize connection handling
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;

    # MIME types
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # Limit large client requests to prevent abuse
    client_max_body_size 10m;

    # Rate limiting configuration
    limit_req_zone $binary_remote_addr zone=rate_limit_zone:10m rate=10r/s;

    # Upstream pools
    upstream ingress_http {
%{ for ip in control_plane_ips ~}
        server ${ip}:30080 max_fails=3 fail_timeout=30s;
%{ endfor ~}
    }

    upstream ingress_https {
%{ for ip in control_plane_ips ~}
        server ${ip}:30443 max_fails=3 fail_timeout=30s;
%{ endfor ~}
    }

    # HTTP Server
    server {
        listen 80;
        server_name _; # Catch-all server name

        # Apply rate limiting to this server block
        limit_req zone=rate_limit_zone burst=20 nodelay;

        location / {
            proxy_pass http://ingress_http;
            proxy_http_version 1.1;  # Ensure compatibility with modern servers
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;

            # Caching headers for static content
            proxy_cache_bypass $http_upgrade;
            proxy_cache_valid 200 10m;
            proxy_cache_valid 404 1m;
        }
    }

    # HTTPS Server
    server {
        listen 443;
        server_name _; # Catch-all server name

        # Apply rate limiting to this server block
        limit_req zone=rate_limit_zone burst=20 nodelay;

        location / {
            proxy_pass http://ingress_https;
            proxy_http_version 1.1;  # Ensure compatibility with modern servers
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;

            # Caching headers for static content
            proxy_cache_bypass $http_upgrade;
            proxy_cache_valid 200 10m;
            proxy_cache_valid 404 1m;
        }
    }

    # Security headers
    add_header X-Content-Type-Options nosniff;
    add_header X-Frame-Options SAMEORIGIN;
    add_header X-XSS-Protection "1; mode=block";
}

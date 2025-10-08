
# Docker PHP Base Image

[![Semantic Versioning, Docker Build, Push, and Scan](https://github.com/aburaihan-dev/docker-php-base-image/actions/workflows/build-and-push-docker-image.yaml/badge.svg)](https://github.com/aburaihan-dev/docker-php-base-image/actions/workflows/build-and-push-docker-image.yaml)

Production-ready Docker base images for Laravel 11 applications with PHP 8.2, 8.3, and 8.4. Optimized for performance with Alpine and Debian variants.

## Features

- **Multi-version PHP support**: 8.2, 8.3, 8.4
- **Dual variants**: Alpine (~175MB) and Debian (~595MB)
- **Laravel 11 optimized**: All required extensions pre-installed
- **Runtime-configurable**: Environment variables for PHP settings
- **Auto-updates**: Dependabot + scheduled rebuilds for security patches
- **Multi-platform**: AMD64 support (ARM64 ready)
- **CI/CD optimized**: Build caching, parallel builds, vulnerability scanning

## Available Images

All images available at `ghcr.io/aburaihan-dev/docker-php-base-image`

### Tags
```
php8.2-alpine, php8.2-debian
php8.3-alpine, php8.3-debian
php8.4-alpine, php8.4-debian

# Versioned tags
v1.0.0-php8.2-alpine
latest-php8.2-alpine
```

## Quick Start

### Pull from GHCR
```bash
docker pull ghcr.io/aburaihan-dev/docker-php-base-image:php8.2-alpine
```

### Use in Your Laravel Project
```dockerfile
FROM ghcr.io/aburaihan-dev/docker-php-base-image:php8.2-alpine

COPY . /app
RUN composer install --no-dev --optimize-autoloader
RUN php artisan config:cache && php artisan route:cache

EXPOSE 80
```

### Run with Custom PHP Settings
```bash
docker run -d \
  -p 8080:80 \
  -e PHP_MEMORY_LIMIT=2G \
  -e PHP_MAX_EXECUTION_TIME=300 \
  -e OPCACHE_VALIDATE_TIMESTAMPS=1 \
  ghcr.io/aburaihan-dev/docker-php-base-image:php8.2-alpine
```

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PHP_MEMORY_LIMIT` | `256M` | PHP memory limit |
| `PHP_MAX_EXECUTION_TIME` | `60` | Max execution time (seconds) |
| `PHP_POST_MAX_SIZE` | `100M` | POST data size limit |
| `PHP_UPLOAD_MAX_FILESIZE` | `100M` | Upload file size limit |
| `PHP_TIMEZONE` | `UTC` | Default timezone |
| `PHP_DISPLAY_ERRORS` | `Off` | Display errors (use `On` for dev) |
| `OPCACHE_ENABLE` | `1` | Enable OPcache |
| `OPCACHE_VALIDATE_TIMESTAMPS` | `0` | Validate file changes (use `1` for dev) |

### Example: Development Configuration
```bash
docker run -d \
  -e PHP_DISPLAY_ERRORS=On \
  -e OPCACHE_VALIDATE_TIMESTAMPS=1 \
  -e PHP_MEMORY_LIMIT=512M \
  -v ./your-laravel-app:/app \
  ghcr.io/aburaihan-dev/docker-php-base-image:php8.2-alpine
```

## Included PHP Extensions

All Laravel 11 required and recommended extensions:

**Core**: pdo, pdo_mysql, mysqli, mbstring, openssl, tokenizer, xml, json

**Performance**: opcache (with production-optimized settings)

**Features**: redis, zip, gd, intl, bcmath, exif, pcntl, sockets, amqp

## Folder Structure

```
.
├── php-8.2/
│   ├── Dockerfile              # Debian variant
│   ├── Dockerfile.optimized    # Alpine variant
│   ├── configs/
│   │   ├── nginx/laravel*.conf
│   │   ├── supervisor/supervisord.conf
│   │   └── docker-entrypoint.sh
│   └── .dockerignore
├── php-8.3/                    # Same structure
├── php-8.4/                    # Same structure
└── .github/
    ├── workflows/
    │   ├── build-and-push-docker-image.yaml
    │   └── scheduled-rebuild.yaml
    └── dependabot.yml
```

## Build Locally

### Alpine (Recommended)
```bash
docker build -f php-8.2/Dockerfile.optimized -t php-laravel:8.2-alpine php-8.2/
```

### Debian
```bash
docker build -t php-laravel:8.2-debian php-8.2/
```

### Compare Sizes
```bash
docker images | grep php-laravel
# Expected:
# php-laravel  8.2-alpine   ~175MB
# php-laravel  8.2-debian   ~595MB
```

## CI/CD

### Automated Workflows

1. **Build & Push**: Triggers on push to `main`, builds all 6 variants in parallel
2. **Security Scan**: Trivy scans Alpine variants for vulnerabilities
3. **Scheduled Rebuild**: Weekly rebuild (Mondays) for latest base images
4. **Dependabot**: Auto-creates PRs for base image updates

### Semantic Versioning

Commit messages control version bumps:

```bash
# Patch (v1.0.0 → v1.0.1)
git commit -m "bump: patch - fix nginx config"

# Minor (v1.0.0 → v1.1.0)
git commit -m "bump: minor - add PHP 8.4 support"

# Major (v1.0.0 → v2.0.0)
git commit -m "bump: major - breaking: remove PHP 8.1"
```

## Production Deployment

### Docker Compose Example
```yaml
version: '3.8'
services:
  app:
    image: ghcr.io/aburaihan-dev/docker-php-base-image:php8.2-alpine
    volumes:
      - ./your-laravel-app:/app
    ports:
      - "80:80"
    environment:
      PHP_MEMORY_LIMIT: 512M
      OPCACHE_VALIDATE_TIMESTAMPS: 0
      DB_HOST: mysql
      REDIS_HOST: redis
```

### Kubernetes Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: laravel-app
spec:
  replicas: 3
  template:
    spec:
      containers:
      - name: app
        image: ghcr.io/aburaihan-dev/docker-php-base-image:v1.0.0-php8.2-alpine
        env:
        - name: PHP_MEMORY_LIMIT
          value: "512M"
        - name: OPCACHE_VALIDATE_TIMESTAMPS
          value: "0"
```

## Performance Tips

1. **Use Alpine** for production (3x smaller, faster deployments)
2. **Set `OPCACHE_VALIDATE_TIMESTAMPS=0`** in production (no file checks)
3. **Adjust `PHP_MEMORY_LIMIT`** based on workload (migrations may need 2G+)
4. **Use versioned tags** in production (e.g., `v1.0.0-php8.2-alpine`)
5. **Enable BuildKit** for faster local builds: `DOCKER_BUILDKIT=1 docker build ...`

## Troubleshooting

### Container won't start
```bash
docker logs container-name
# Check for missing ENV vars or permission issues
```

### Increase memory for migrations
```bash
docker run -e PHP_MEMORY_LIMIT=2G your-image php artisan migrate
```

### Enable dev mode
```bash
docker run \
  -e PHP_DISPLAY_ERRORS=On \
  -e OPCACHE_VALIDATE_TIMESTAMPS=1 \
  your-image
```

## Contributing

Contributions welcome! Please:
1. Test changes locally with both Alpine and Debian variants
2. Update documentation for any new features
3. Use semantic commit messages for versioning

## License

MIT License

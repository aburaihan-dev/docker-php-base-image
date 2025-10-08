# Quick Start Guide

## 🚀 Getting Started with the Optimized Alpine Image

### Option 1: Build and Test the Alpine Image

```bash
# Navigate to the project directory
cd /home/ddcl-devops/Projects/Personal/docker-php-base-image

# Build the optimized Alpine image
docker build -f php-8.2/Dockerfile.optimized -t php-laravel:8.2-alpine php-8.2/

# Check the image size
docker images php-laravel:8.2-alpine

# Expected: ~150-180 MB (vs ~450-500 MB with Debian)
```

### Option 2: Compare Both Versions

```bash
# Build Debian version (original)
docker build -t php-laravel:8.2-debian php-8.2/

# Build Alpine version (optimized)
docker build -f php-8.2/Dockerfile.optimized -t php-laravel:8.2-alpine php-8.2/

# Compare sizes
docker images | grep php-laravel

# You should see something like:
# php-laravel  8.2-alpine   abc123   ~150-180 MB
# php-laravel  8.2-debian   def456   ~450-500 MB
```

### Option 3: Test with Docker Compose

```bash
# Copy the example compose file
cp docker-compose.example.yml docker-compose.yml

# Edit docker-compose.yml to point to your Laravel app
# Change: - ./example-app:/app
# To:     - /path/to/your/laravel-app:/app

# Start the stack
docker-compose up -d

# View logs
docker-compose logs -f app

# Access your app at http://localhost:8080

# Stop the stack
docker-compose down
```

## 🧪 Quick Test Without a Laravel App

```bash
# Run the Alpine container
docker run -d -p 8080:80 --name test-laravel php-laravel:8.2-alpine

# Test the PHP-FPM ping endpoint
curl http://localhost:8080/fpm-ping
# Expected: pong

# Check PHP version and extensions
docker exec test-laravel php -v
docker exec test-laravel php -m

# Check supervisor status
docker exec test-laravel supervisorctl status
# Expected: 
# nginx     RUNNING
# php-fpm   RUNNING

# View logs
docker logs test-laravel

# Clean up
docker stop test-laravel && docker rm test-laravel
```

## 📝 Using with Your Laravel 11 Application

### Method 1: Volume Mount (Development)

```bash
# Run with your Laravel app mounted
docker run -d -p 8080:80 \
  -v /path/to/your/laravel-app:/app \
  -e APP_ENV=local \
  -e APP_DEBUG=true \
  -e APP_KEY=base64:your-key-here \
  -e DB_HOST=host.docker.internal \
  -e DB_DATABASE=laravel \
  -e DB_USERNAME=root \
  -e DB_PASSWORD=secret \
  --name laravel-dev \
  php-laravel:8.2-alpine

# Access at http://localhost:8080
```

### Method 2: Build Your App Image (Production)

Create a `Dockerfile` in your Laravel project:

```dockerfile
# Use the optimized base image
FROM php-laravel:8.2-alpine

# Copy application files
COPY . /app

# Set permissions
RUN chown -R www-data:www-data /app/storage /app/bootstrap/cache

# Install Composer dependencies (production)
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Optimize Laravel for production
RUN php artisan config:cache && \
    php artisan route:cache && \
    php artisan view:cache

# Expose port
EXPOSE 80

# Start services via supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
```

Then build and run:

```bash
# In your Laravel project directory
docker build -t my-laravel-app:latest .

# Run it
docker run -d -p 8080:80 \
  -e APP_ENV=production \
  -e APP_KEY=base64:your-production-key \
  -e DB_HOST=your-db-host \
  -e DB_DATABASE=laravel \
  -e DB_USERNAME=laravel \
  -e DB_PASSWORD=secret \
  my-laravel-app:latest
```

## 🔍 Verification Checklist

After building the image, verify:

- [ ] Image size is ~150-180 MB (Alpine) or ~380-420 MB (Debian)
- [ ] PHP version is 8.2.x
- [ ] All required extensions are installed
- [ ] OPcache is enabled
- [ ] Nginx is running
- [ ] PHP-FPM is running
- [ ] Supervisor is managing processes
- [ ] Health check responds to `/fpm-ping`

### Verification Commands

```bash
# Check image size
docker images php-laravel:8.2-alpine

# Check PHP version
docker run --rm php-laravel:8.2-alpine php -v

# Check installed extensions
docker run --rm php-laravel:8.2-alpine php -m

# Check OPcache status
docker run --rm php-laravel:8.2-alpine php -i | grep opcache.enable

# Start container and check services
docker run -d --name verify php-laravel:8.2-alpine
sleep 5
docker exec verify supervisorctl status
docker exec verify curl -f http://localhost/fpm-ping
docker stop verify && docker rm verify
```

## 🎯 Expected PHP Extensions

The image includes all Laravel 11 required and recommended extensions:

**Core Extensions:**
- ✅ pdo
- ✅ pdo_mysql
- ✅ mysqli
- ✅ mbstring (built-in)
- ✅ openssl (built-in)
- ✅ tokenizer (built-in)
- ✅ xml (built-in)
- ✅ json (built-in)

**Recommended Extensions:**
- ✅ opcache (performance)
- ✅ redis (caching)
- ✅ zip (package management)
- ✅ gd (image processing)
- ✅ intl (internationalization)
- ✅ bcmath (precision math)
- ✅ exif (image metadata)
- ✅ pcntl (process control)
- ✅ sockets (websockets)

**Queue/Message Extensions:**
- ✅ amqp (RabbitMQ)

## 📊 Performance Tips

### 1. OPcache Preloading (Laravel 11)
Add to your Laravel Dockerfile after base image:

```dockerfile
# Enable OPcache preloading for Laravel
RUN echo "opcache.preload=/app/preload.php" >> /usr/local/etc/php/conf.d/opcache.ini && \
    echo "opcache.preload_user=www-data" >> /usr/local/etc/php/conf.d/opcache.ini
```

### 2. Adjust PHP-FPM for Your Load
Environment variables you can override:

```bash
docker run -e PHP_FPM_MAX_CHILDREN=100 \
           -e PHP_FPM_START_SERVERS=20 \
           php-laravel:8.2-alpine
```

### 3. Optimize for Production
In production, ensure:
- APP_DEBUG=false
- APP_ENV=production
- OPcache validate_timestamps=0 (already set)
- Run: `php artisan config:cache route:cache view:cache`

## 🐛 Troubleshooting

### Container won't start
```bash
# Check logs
docker logs container-name

# Common issues:
# - Missing .env file (mount or set env vars)
# - Wrong permissions on storage/bootstrap/cache
# - Missing APP_KEY
```

### Permission issues
```bash
# Fix storage permissions
docker exec container-name chown -R www-data:www-data /app/storage /app/bootstrap/cache
docker exec container-name chmod -R 775 /app/storage /app/bootstrap/cache
```

### Nginx 502 Bad Gateway
```bash
# Check if PHP-FPM is running
docker exec container-name supervisorctl status php-fpm

# Check PHP-FPM logs
docker exec container-name tail -f /var/log/php_errors.log
```

## 📈 Next Steps

1. **Test the Alpine image** with your Laravel app
2. **Run performance benchmarks** comparing Alpine vs Debian
3. **Update your CI/CD** to use the new image
4. **Monitor in production** for any issues
5. **Celebrate** the 60% size reduction! 🎉

## 💡 Pro Tips

- Use multi-stage builds for your app to further reduce size
- Consider using `--squash` flag when building (reduces layers)
- Tag images with semantic versions (v1.0.0, v1.1.0, etc.)
- Use BuildKit for faster builds: `DOCKER_BUILDKIT=1 docker build ...`
- Cache Composer dependencies in a separate layer

## 🔗 Useful Links

- [Full Optimization Guide](./OPTIMIZATION_GUIDE.md)
- [Docker Compose Example](./docker-compose.example.yml)
- [Alpine Dockerfile](./php-8.2/Dockerfile.optimized)
- [Original Dockerfile](./php-8.2/Dockerfile)

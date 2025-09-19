FROM webdevops/php:8.2-alpine

WORKDIR /app

# Instalar dependencias necesarias y la extensión pdo_pgsql
RUN apk add --no-cache postgresql-dev && \
    docker-php-ext-install pdo pdo_pgsql

# Instalar Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
ENV COMPOSER_ALLOW_SUPERUSER=1

# Establecer variables de entorno por defecto
ENV APP_ENV=prod
ENV APP_DEBUG=0

# Copiar archivos de configuración de Composer
COPY composer.json composer.lock ./

# Instalar todas las dependencias primero
RUN composer install --no-interaction --prefer-dist --no-scripts

# Copiar todo el código
COPY . .

# Crear archivo .env mínimo para evitar errores de Symfony
RUN echo "APP_ENV=prod" > .env && \
    echo "APP_DEBUG=0" >> .env && \
    echo "DATABASE_URL=" >> .env

# Limpiar cache y preparar para producción
RUN APP_ENV=prod php bin/console cache:clear --env=prod --no-debug || true

# Remover dependencias de desarrollo para la imagen final
RUN composer install --no-interaction --prefer-dist --no-scripts --no-dev --optimize-autoloader

# Crear directorios necesarios y establecer permisos
RUN mkdir -p var/cache var/log && \
    chown -R application:application var/ && \
    chmod -R 775 var/

# Exponer puerto
EXPOSE 8000

# Comando de inicio mejorado
CMD sh -c "\
    export APP_ENV=\${APP_ENV:-prod} && \
    export APP_DEBUG=\${APP_DEBUG:-0} && \
    php bin/console cache:clear --env=\${APP_ENV} --no-debug && \
    php bin/console doctrine:database:create --if-not-exists --env=\${APP_ENV} && \
    php bin/console doctrine:migrations:migrate --no-interaction --env=\${APP_ENV} && \
    php -S 0.0.0.0:${PORT:-8000} -t public \
"
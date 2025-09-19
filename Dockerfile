FROM webdevops/php:8.2-alpine

WORKDIR /app

# Instalar Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
ENV COMPOSER_ALLOW_SUPERUSER=1

# Copiar archivos de configuración de Composer
COPY composer.json composer.lock ./

# Instalar todas las dependencias primero (con dev para tener symfony/runtime)
RUN composer install --no-interaction --prefer-dist --no-scripts

# Copiar todo el código
COPY . .

# Limpiar cache y preparar para producción
RUN php bin/console cache:clear --env=prod --no-debug || true

# Remover dependencias de desarrollo para la imagen final
RUN composer install --no-interaction --prefer-dist --no-scripts --no-dev --optimize-autoloader

# Crear directorios necesarios y establecer permisos
RUN mkdir -p var/cache var/log && \
    chown -R application:application var/ && \
    chmod -R 775 var/

# Variables de entorno
ENV APP_ENV=prod
ENV DATABASE_URL="${DATABASE_URL}"

# Exponer puerto
EXPOSE 8000

# Comando de inicio
CMD sh -c "\
    php bin/console cache:clear --env=prod && \
    php bin/console doctrine:database:create --if-not-exists && \
    php bin/console doctrine:migrations:migrate --no-interaction && \
    php bin/console doctrine:fixtures:load --no-interaction --append && \
    php -S 0.0.0.0:8000 -t public \
"
FROM webdevops/php:8.2-alpine

WORKDIR /app

# Instalar Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copiar composer.json y composer.lock primero para cache
COPY composer.json composer.lock ./

# Instalar dependencias SIN ejecutar scripts
RUN composer install --no-interaction --prefer-dist --no-scripts --no-dev

# Asegurar que symfony/runtime está instalado
RUN composer require symfony/runtime --no-scripts

# Copiar el resto del código
COPY . .

# Ejecutar scripts de composer después de copiar todo el código
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Configurar permisos para var/
RUN mkdir -p var/cache var/log && \
    chown -R application:application var/ && \
    chmod -R 775 var/

# Variables de entorno para la DB (configurar en Render)
ENV APP_ENV=prod
ENV DATABASE_URL="${DATABASE_URL}"

# Exponer puerto 8000
EXPOSE 8000

# Comando por defecto: migraciones, fixtures y levantar servidor PHP embebido
CMD sh -c "\
    php bin/console cache:clear --env=prod && \
    php bin/console doctrine:database:create --if-not-exists && \
    php bin/console doctrine:migrations:migrate --no-interaction && \
    php bin/console doctrine:fixtures:load --no-interaction --append && \
    php -S 0.0.0.0:8000 -t public \
"
FROM webdevops/php:8.2-alpine

WORKDIR /app

# Instalar Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copiar composer.json y composer.lock para cache
COPY composer.json composer.lock ./

# Instalar dependencias SIN ejecutar scripts
RUN composer install --no-interaction --prefer-dist --no-scripts

# Copiar el resto del código
COPY . .

# Variables de entorno para la DB (configurar en Render)
ENV DATABASE_URL="postgresql://${POSTGRES_USER:-app}:${POSTGRES_PASSWORD:-!ChangeMe!}@${DATABASE_HOST:-database}:5432/${POSTGRES_DB:-app}?serverVersion=16&charset=utf8"

# Exponer puerto 8000
EXPOSE 8000

# Comando por defecto: migraciones, fixtures y levantar servidor PHP embebido
CMD sh -c "\
    php bin/console doctrine:database:create --if-not-exists && \
    php bin/console doctrine:migrations:migrate --no-interaction && \
    php bin/console doctrine:fixtures:load --no-interaction --append && \
    php -S 0.0.0.0:8000 -t public \
"

# Usamos la misma imagen base de tu docker-compose
FROM webdevops/php:8.2-alpine

# Directorio de trabajo
WORKDIR /app

# Instalar Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copiamos solo composer primero para instalar dependencias y aprovechar cache
COPY composer.json composer.lock ./
RUN composer install --no-interaction --prefer-dist

# Copiamos el resto del código
COPY . .

# Variables de entorno para la DB
ENV DATABASE_URL="postgresql://${POSTGRES_USER:-app}:${POSTGRES_PASSWORD:-!ChangeMe!}@${DATABASE_HOST:-database}:5432/${POSTGRES_DB:-app}?serverVersion=16&charset=utf8"

# Exponemos el puerto 8000
EXPOSE 8000

# Comando por defecto
CMD sh -c "\
    php bin/console doctrine:database:create --if-not-exists && \
    php bin/console doctrine:migrations:migrate --no-interaction && \
    php bin/console doctrine:fixtures:load --no-interaction --append && \
    php -S 0.0.0.0:8000 -t public \
"

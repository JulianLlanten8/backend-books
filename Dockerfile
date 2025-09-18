services:
  ###> doctrine/doctrine-bundle ###
  database:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: ${POSTGRES_DB:-app}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-!ChangeMe!}
      POSTGRES_USER: ${POSTGRES_USER:-app}
    healthcheck:
      test: ["CMD", "pg_isready", "-d", "${POSTGRES_DB:-app}", "-U", "${POSTGRES_USER:-app}"]
      timeout: 5s
      retries: 5
      start_period: 60s
    volumes:
      - database_data:/var/lib/postgresql/data:rw
    ports:
      - "5432:5432"
  ###< doctrine/doctrine-bundle ###

  ###> Symfony App ###
  app:
    image: webdevops/php:8.2-alpine
    working_dir: /app
    volumes:
      - .:/app
    ports:
      - "8000:8000"
    depends_on:
      database:
        condition: service_healthy
    environment:
      - DATABASE_URL=postgresql://${POSTGRES_USER:-app}:${POSTGRES_PASSWORD:-!ChangeMe!}@database:5432/${POSTGRES_DB:-app}?serverVersion=16&charset=utf8
    command: >
      sh -c "
        curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer &&
        composer install --no-interaction &&
        php bin/console doctrine:database:create --if-not-exists &&
        php bin/console doctrine:migrations:migrate --no-interaction &&
        php bin/console doctrine:fixtures:load --no-interaction --append &&
        php -S 0.0.0.0:8000 -t public
      "
  ###< Symfony App ###

volumes:
  ###> doctrine/doctrine-bundle ###
  database_data:
  ###< doctrine/doctrine-bundle ###
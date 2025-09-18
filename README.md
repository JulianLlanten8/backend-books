# Proyecto: Tidelit Libros (Symfony 6 + Vue 3)
![alt text](docs/preview.png)

### Requisitos

1. PHP >= 8.1
2. Composer
5. MySQL/PostgreSQL


### Instalación
1. Clona el repositorio:
   ```bash
   git clone <URL_DEL_REPOSITORIO>
   ````
2. Navega al directorio del proyecto:
   ```bash
   cd tidelit-books
   ```
3. Instala las dependencias de PHP:
   ```bash
   composer install
   ```
4. Crear base de datos:
   ```bash
   CREATE DATABASE tidelit_books;

   php bin/console doctrine:database:create
   ```
5. Ejecuta las migraciones para crear las tablas necesarias:
    ```bash
    php bin/console doctrine:migrations:migrate
    ```
6. Cargar datos iniciales (fixtures):
    ```bash
    php bin/console doctrine:fixtures:load
    ```
7. Configura las variables de entorno en el archivo `.env` o `.env.local` según tus necesidades.
8. Inicia el servidor de desarrollo:
   ```bash
   symfony server:start
   ```
9. Accede a la aplicación en tu navegador web en `http://localhost:8000/api/books` o mira la colección de Postman aqui: [text](docs/books.postman_collection.json)
FROM composer:1.10 as backend

COPY . /app/
WORKDIR /app

# COPY laravel/composer.json laravel/composer.lock /app/
RUN composer install  \
    --ignore-platform-reqs \
    --no-ansi \
    --no-autoloader \
    --no-dev \
    --no-interaction \
    --no-scripts

# Reset (PHP) Class Loading
RUN composer dump-autoload --optimize --classmap-authoritative \ 
    --no-ansi \
    --no-dev \
    --no-interaction \
    --no-scripts


# Build frontend assets
FROM node as frontend
# COPY package.json package-lock.json webpack.mix.js /app/
COPY . /app/
WORKDIR /app

RUN npm install
RUN npm run production


FROM php:7.2-fpm

# Copy existing application directory contents
# COPY . /var/www
# Single Stage Build
# COPY laravel /app/www
# Multi-Stage Build
COPY --from=backend /app /var/www
COPY --from=frontend /app/resources /var/www/resources
COPY --from=frontend /app/public /var/www/public

# Set working directory
WORKDIR /var/www

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install extensions
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl
RUN docker-php-ext-configure gd --with-gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/
RUN docker-php-ext-install gd

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Add user for laravel application
RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

# Copy existing application directory permissions
COPY --chown=www:www . /var/www

# Change current user to www
USER www

# Expose port 8080 and start php-fpm server
EXPOSE 8080
CMD ["php-fpm"]

FROM centos:7

MAINTAINER kariedo <kariedo@gmail.com>

# Add the ngix repository
COPY config/nginx/nginx.repo /etc/yum.repos.d/nginx.repo

# Install EPEL and Remi
RUN yum -y install http://rpms.famillecollet.com/enterprise/remi-release-7.rpm

# Enable Remi PHP 7.3
RUN yum-config-manager --enable remi-php73

# Install supervisor, nginx PHP-FPM and extensions
RUN yum -y install nginx supervisor openssh-server ssmtp \
                    php \
                    php-bcmath \
                    php-cli \
                    php-fpm \
                    php-gd \
                    php-intl \
                    php-mbstring \
                    php-mcrypt \
                    php-mysqlnd \
                    php-pdo \
                    php-pecl-igbinary \
                    php-pecl-imagick \
                    php-pecl-oauth \
                    php-pecl-redis \
                    php-pecl-zendopcache \
                    php-process \
                    php-soap \
                    php-xml \
                    php-zip && yum clean all

# Add nginx service configs
COPY config/nginx/nginx.conf /etc/nginx/nginx.conf
COPY config/nginx/www.conf /etc/nginx/conf.d/default.conf

# Add PHP-FPM configuration
COPY config/php/www.conf /etc/php-fpm.d/www.conf
COPY config/php/mail.ini /etc/php.d/mail.ini

# Add Supervisor configuration
COPY config/supervisor/nginx.ini /etc/supervisord.d/nginx.ini
COPY config/supervisor/php-fpm.ini /etc/supervisord.d/php-fpm.ini
COPY config/supervisor/sshd.ini /etc/supervisord.d/sshd.ini.template

# Add Kick-start script
COPY bin/kick-start /usr/local/bin/kick-start
RUN chmod -v +x /usr/local/bin/kick-start

#Internal TLS
RUN openssl ecparam -out /etc/nginx/ssl-nginx.key -name prime256v1 -genkey && \
    openssl req -new -sha256 -nodes -subj "/C=IC/ST=InternalCommunication/L=InternalCommunication/O=InternalCommunication/CN=InternalCommunication" -key /etc/nginx/ssl-nginx.key -out /etc/nginx/ssl-nginx.csr && \
    openssl req -x509 -sha256 -days 3650 -key /etc/nginx/ssl-nginx.key -in /etc/nginx/ssl-nginx.csr -out /etc/nginx/ssl-nginx.crt
#SSHD and PHP-FPM fixes
RUN /usr/bin/ssh-keygen -A && \
    mkdir /run/php-fpm

RUN groupadd www-user && adduser www-user -d /var/www/html -g www-user

RUN sed -i -e 's/mailhub=mail/mailhub=smtp-relay/' \
    /etc/ssmtp/ssmtp.conf

EXPOSE 80
EXPOSE 443

CMD ["kick-start"]

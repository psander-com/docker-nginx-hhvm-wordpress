FROM debian:jessie
MAINTAINER Philipp Sander <psander@gmx.com>

RUN apt-get clean && \
    apt-get update && \
    apt-get install -y gnupg2 && \
    apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0x5a16e7281be7a449 && \
    echo deb http://dl.hhvm.com/debian jessie main | tee /etc/apt/sources.list.d/hhvm.list && \
    apt-get clean && \
    apt-get update && \
    apt-get install -y hhvm nginx curl nano && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/wordpress

# Wordpress
RUN set -x \
	&& curl -o wordpress.tar.gz -fSL "https://wordpress.org/latest.tar.gz" \
	&& tar -xzf wordpress.tar.gz -C /var/www \
	&& rm wordpress.tar.gz \
	&& chown -R www-data:www-data /var/www/wordpress

# HHVM config
ADD config/php.ini /etc/hhvm
ADD config/server.ini /etc/hhvm

# Nginx config
ADD config/nginx.conf /etc/nginx/
ADD config/wordpress.conf /etc/nginx/sites-available/default

# Auto-configure HHVM
CMD sh /usr/share/hhvm/install_fastcgi.sh

# Start up HHVM on next boot
RUN update-rc.d hhvm defaults

# Boot up Nginx, and HHVM when container is started
CMD service hhvm start && nginx

EXPOSE 80

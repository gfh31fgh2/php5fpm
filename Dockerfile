FROM phusion/baseimage:0.9.15
MAINTAINER MMM <mail>

ENV DEBIAN_FRONTEND noninteractive

# Get updates
# Installing php-fpm
# We need to create an empty file, otherwise the volume will belong to root.
RUN apt-get update && \
            apt-get install -y --no-install-recommends \
            php5-fpm \
            php5-imap \
            php5-json \
            php5-mysql \
            php5-curl \
            unzip \
	    nano \
            php5-gd \
            php5-intl \
            php5-mcrypt \
            php5-tidy \
            php5-xmlrpc \
            php5-memcached && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    mkdir -p /home/www && mkdir -p /home/www/siteplace && chown -R www-data.www-data /home/www && \
    mkdir /etc/service/php5-fpm && \
    mkdir /var/run/php5-fpm &&\
    touch /var/run/php5-fpm/php5-fpm.sock && chown www-data /var/run/php5-fpm/php5-fpm.sock

# Runit php5-fpm  service
ADD php5-fpm.sh /etc/service/php5-fpm/run

# Make executable run file
RUN chmod 700 /etc/service/php5-fpm/run

# error_reporting and display_errors should be enabled on development only
RUN sed -i \
        -e "s~^display_errors.*$~display_errors = Off~g" \
        -e "s~^ignore_repeated_errors.*$~ignore_repeated_errors = On~g" \
        -e "s~^ignore_repeated_source.*$~ignore_repeated_source = On~g" \
        -e "s~^display_startup_errors.*$~display_startup_errors = Off~g" \
        -e "s~^track_errors.*$~track_errors = Off~g" \
        -e "s~^;date.timezone.*$~date.timezone = UTC~g" \
        -e "s~^;cgi.fix_pathinfo.*$~cgi.fix_pathinfo=0~g" \
        -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 100M/g" \
        -e "s/post_max_size\s*=\s*8M/post_max_size = 101M/g" \
        -e "s/;pm.max_requests\s*=\s*500/pm.max_requests = 500/g" \
        -e "s/;security.limit_extensions = .php .php3 .php4 .php5/security.limit_extensions = .php/g" \
            /etc/php5/fpm/php.ini

RUN sed -i \
        -e "s~^;daemonize = yes*$~daemonize = no~g" \
        -e "s~^;emergency_restart_threshold.*$~emergency_restart_threshold = 10~g" \
        -e "s~^;emergency_restart_interval.*$~emergency_restart_interval = 1m~g" \
	-e "s~^error_log = /var/log/php5-fpm.log/error_log = /var/log/php5/php5-fpm.log" \
        -e "s~^;process_control_timeout.*$~process_control_timeout = 10s~g" \
            /etc/php5/fpm/php-fpm.conf

RUN sed -i \
        -e "s/^pm.max_children\(.*\)/pm.max_children = 100/g" \
        -e "s/^pm.start_servers\(.*\)/pm.start_servers = 10/g" \
        -e "s/^pm.min_spare_servers\(.*\)/pm.min_spare_servers = 5/g" \
        -e "s/^pm.max_spare_servers\(.*\)/pm.max_spare_servers = 15/g" \
        -e "s/^;pm.max_requests\(.*\)/pm.max_requests = 1000/g" \
        -e "s/^pm.max_requests\(.*\)/pm.max_requests = 1000/g" \
        -e "s/^;slowlog/slowlog/g" \
        -e "s/^slowlog\(.*\)/slowlog = \/var\/log\/slowlog.log/g" \
         -e "s/^;request_slowlog_timeout/request_slowlog_timeout/g" \
        -e "s/^;pm.status_path/pm.status_path/g" \
	-e "s/^listen = /var/run/php5-fpm.sock/listen = /var/run/php5-fpm/php5-fpm.sock/g" \
        -e "s/^;request_terminate_timeout/request_terminate_timeout/g" \
        -e "s/^;catch_workers_output/catch_workers_output/g" \
        -e "s/^;catch_workers_output/catch_workers_output/g" \
            /etc/php5/fpm/pool.d/www.conf

RUN echo "\n\nopcache.memory_consumption=128" >> /etc/php5/mods-available/opcache.ini && \
    echo "opcache.interned_strings_buffer=8" >> /etc/php5/mods-available/opcache.ini && \
    echo "opcache.max_accelerated_files=4000" >> /etc/php5/mods-available/opcache.ini && \
    echo "opcache.revalidate_freq=60" >> /etc/php5/mods-available/opcache.ini && \
    echo "opcache.fast_shutdown=1" >> /etc/php5/mods-available/opcache.ini && \
    echo "opcache.enable_file_override=1" >> /etc/php5/mods-available/opcache.ini && \
    echo "opcache.save_comments=0" >> /etc/php5/mods-available/opcache.ini


# Port to expose (default: 9000)
# EXPOSE 9000

# Use baseimage-dockers init system.
CMD ["/sbin/my_init"]

# Set entrypoint
# ENTRYPOINT ["/usr/sbin/php-fpm", "-FO"]

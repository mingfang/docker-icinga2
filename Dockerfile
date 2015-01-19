FROM ubuntu:14.04
 
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN locale-gen en_US en_US.UTF-8
ENV LANG en_US.UTF-8

#Runit
RUN apt-get install -y runit 
CMD export > /etc/envvars && /usr/sbin/runsvdir-start
RUN echo 'export > /etc/envvars' >> /root/.bashrc

#Utilities
RUN apt-get install -y vim less net-tools inetutils-ping wget curl git telnet nmap socat dnsutils netcat tree htop unzip sudo software-properties-common

#Nginx
RUN apt-get install -y nginx

#MySql
RUN apt-get install -y mysql-server

#PHP
RUN apt-get install -y php5-dev
RUN apt-get install -y php5-gd php5-json php5-mysql php5-curl
RUN apt-get install -y php5-intl php5-mcrypt php5-imagick
RUN apt-get install -y php5-fpm
RUN sed -i "s|;cgi.fix_pathinfo=1|cgi.fix_pathinfo=0|" /etc/php5/fpm/php.ini
RUN sed -i "s|upload_max_filesize = 2M|upload_max_filesize = 16G|" /etc/php5/fpm/php.ini
RUN sed -i "s|post_max_size = 8M|post_max_size = 16G|" /etc/php5/fpm/php.ini
RUN sed -i "s|output_buffering = 4096|output_buffering = Off|" /etc/php5/fpm/php.ini
RUN sed -i "s|memory_limit = 128M|memory_limit = 512M|" /etc/php5/fpm/php.ini
RUN sed -i "s|;pm.max_requests = 500|pm.max_requests = 500|" /etc/php5/fpm/pool.d/www.conf

#Icinga 2
RUN add-apt-repository ppa:formorer/icinga && \
    apt-get update
RUN apt-get install -y icinga2
RUN mkdir -p /var/run/icinga2 && \
    chown -R nagios:nagios /var/run/icinga2 && \
    chown -R nagios:nagios /etc/icinga2


#Icinga 2 IDO
RUN apt-get install -y icinga2-ido-mysql
RUN icinga2 feature enable ido-mysql
ADD ido-mysql.conf /etc/icinga2/features-available/ido-mysql.conf

#Command Feature
RUN icinga2 feature enable command
RUN mkdir -p /run/icinga2/cmd && \
    chown -R nagios:nagios /run/icinga2/cmd

#Other features
RUN icinga2 feature enable livestatus
RUN icinga2 feature enable compatlog
RUN chown -R nagios:nagios /etc/icinga2

#Icinga Web 2
RUN git clone --depth 1 git://git.icinga.org/icingaweb2.git
RUN mv /icingaweb2 /usr/share/icingaweb2
RUN addgroup --system icingaweb2 && \
    usermod -a -G icingaweb2 www-data && \
    usermod -a -G nagios www-data

#Init MySql
ADD mysql.ddl /
ADD preparedb.sh /
RUN /preparedb.sh

#Icingaweb 2 config
ADD nginx.conf /etc/nginx/nginx.conf
RUN sed -i "s|;date.timezone =|date.timezone = America/New_York|" /etc/php5/fpm/php.ini
RUN mkdir -p /var/log/icingaweb2 && \
    chown -R www-data /var/log/icingaweb2
ADD icingaweb2 /etc/icingaweb2
RUN chown -R www-data:www-data /etc/icingaweb2
RUN ln -s /usr/share/icingaweb2/modules/doc /etc/icingaweb2/enabledModules/doc && \
    ln -s /usr/share/icingaweb2/modules/monitoring /etc/icingaweb2/enabledModules/monitoring

#Add runit services
ADD sv /etc/service 


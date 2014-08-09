FROM ubuntu
MAINTAINER Yusuke SAITO <yusuke.saito@jibunstyle.com>

# install
RUN apt-get update
RUN apt-get install -y vim
RUN apt-get install -y nginx
RUN apt-get install -y php5 php5-fpm php5-mysql php5-common php5-gd
RUN apt-get install -y sysv-rc-conf
RUN apt-get install -y openssh-server openssh-client
RUN apt-get clean

# configuration
ADD www.conf /etc/php5/fpm/pool.d/
ADD nginx.conf /etc/nginx/
ADD mynginx.conf /etc/nginx/conf.d/
ADD sshd_config /etc/ssh/

RUN mkdir /var/log/nginx/itzemi.jp
RUN chown www-data. /var/log/nginx/itzemi.jp
RUN mkdir -p /var/www/html
RUN echo '<?php echo phpinfo(); ?>' > /var/www/html/index.php
RUN chown -R www-data. /var/www
#RUN rm /etc/ssh/ssh_host_dsa_key && /usr/bin/ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -C '' -N ''
#RUN rm /etc/ssh/ssh_host_rsa_key && /usr/bin/ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -C '' -N ''

RUN sysv-rc-conf php5-fpm on
RUN sysv-rc-conf nginx on
RUN sysv-rc-conf sshd on

# add user
RUN useradd aws
RUN sed -ri 's/aws:\!:/aws::/g' /etc/shadow
RUN mkdir -p /home/aws/.ssh
ADD id_rsa_unwp.pub /home/aws/.ssh/authorized_keys
RUN chown -R aws. /home/aws/
RUN chmod 700 /home/aws/.ssh
RUN chmod 600 /home/aws/.ssh/authorized_keys
RUN echo "aws  ALL=(ALL)  NOPASSWD:ALL" >> /etc/sudoers.d/aws

EXPOSE 80 22

CMD ["nginx"]

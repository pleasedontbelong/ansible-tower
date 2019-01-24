# Ansible Tower Dockerfie
FROM ubuntu:xenial

WORKDIR /opt

ENV ANSIBLE_TOWER_VER 3.4.1-1
ENV PG_DATA /var/lib/postgresql/9.6/main
ENV AWX_PROJECTS /var/lib/awx/projects

# Set locale
RUN apt-get clean && apt-get update && apt-get install -y locales
RUN locale-gen "en_US.UTF-8" \
	&& export LC_ALL="en_US.UTF-8" \
	&& dpkg-reconfigure locales

RUN localedef -i en_US -f UTF-8 en_US.UTF-8

RUN apt-get install -y software-properties-common python2.7 python-pip\
	&& apt-get update

# Install libpython2.7; missing dependency in Tower setup
RUN apt-get install -y libpython2.7

# Install support for https apt sources
RUN apt-get install -y apt-transport-https ca-certificates

# create /var/log/tower
RUN mkdir -p /var/log/tower

# COPY ansible-tower-setup-${ANSIBLE_TOWER_VER}/* ./ansible-tower-setup-${ANSIBLE_TOWER_VER}/
# Download & extract Tower tarball
ADD http://releases.ansible.com/ansible-tower/setup/ansible-tower-setup-${ANSIBLE_TOWER_VER}.tar.gz ansible-tower-setup-${ANSIBLE_TOWER_VER}.tar.gz
RUN tar xvf ansible-tower-setup-${ANSIBLE_TOWER_VER}.tar.gz \
    && rm -f ansible-tower-setup-${ANSIBLE_TOWER_VER}.tar.gz

WORKDIR /opt/ansible-tower-setup-${ANSIBLE_TOWER_VER}

# Tower setup
ADD ansible.cfg ./ansible.cfg
ADD inventory ./inventory
RUN ./setup.sh

# Docker entrypoint script
ADD docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# volumes and ports
VOLUME ["${PG_DATA}", "${AWX_PROJECTS}", "/certs",]
EXPOSE 443
EXPOSE 80

CMD ["/docker-entrypoint.sh", "ansible-tower"]

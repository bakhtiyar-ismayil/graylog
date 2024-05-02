#!/bin/bash

sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm  -y

sudo dnf install -y pwgen wget curl perl-Digest-SHA

sudo dnf install java-11-openjdk java-11-openjdk-devel -y

rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

sudo cat << EOF >> /etc/yum.repos.d/elasticsearch.repo
[elasticsearch-7.x]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/oss-7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF

sudo dnf install elasticsearch-oss -y

sudo sed -i 's/^#cluster.name:.*/cluster.name: graylog/' /etc/elasticsearch/elasticsearch.yml

sudo /bin/systemctl daemon-reload

sudo /bin/systemctl enable elasticsearch.service

sudo systemctl start elasticsearch.service

sudo cat << EOF >> /etc/yum.repos.d/mongodb-org-7.0.repo
[mongodb-org-7.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/8/mongodb-org/7.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://pgp.mongodb.com/server-7.0.asc
EOF

sudo yum install -y mongodb-org

sudo systemctl daemon-reload

sudo systemctl enable --now  mongod

sudo rpm -Uvh https://packages.graylog2.org/repo/packages/graylog-5.0-repository_latest.rpm

sudo yum install graylog-server -y

sudo sed -i "s/^password_secret =.*/password_secret = $(< /dev/urandom tr -dc A-Za-z0-9 | head -c${1:-96})/" /etc/graylog/server/server.conf

sudo sed -i "s/^root_password_sha2 =.*/root_password_sha2 = 8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918/" /etc/graylog/server/server.conf

sudo sed -i "s/^#http_bind_address =.*/http_bind_address = 192.168.78.14/" /etc/graylog/server/server.conf


sudo systemctl daemon-reload

sudo systemctl enable graylog-server.service

sudo systemctl start graylog-server.service

#sudo setsebool -P httpd_can_network_connect 1

#sudo semanage port -a -t http_port_t -p tcp 9000

#sudo semanage port -a -t http_port_t -p tcp 9200

#sudo semanage port -a -t mongod_port_t -p tcp 27017

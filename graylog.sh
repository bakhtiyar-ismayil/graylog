#!/bin/bash

dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm  -y

dnf install -y pwgen wget curl perl-Digest-SHA

dnf install java-11-openjdk java-11-openjdk-devel -y

rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

# Add Elasticsearch repo

cat << EOF >> /etc/yum.repos.d/elasticsearch.repo

[elasticsearch-7.x]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/oss-7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF

dnf install elasticsearch-oss -y

sed -i 's/^#cluster.name:.*/cluster.name: graylog/' /etc/elasticsearch/elasticsearch.yml

/bin/systemctl daemon-reload

/bin/systemctl enable elasticsearch.service

systemctl start elasticsearch.service

# Add MongoDB repo

cat << EOF >> /etc/yum.repos.d/mongodb-org-7.0.repo

[mongodb-org-7.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/8/mongodb-org/7.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://pgp.mongodb.com/server-7.0.asc
EOF

yum install -y mongodb-org

systemctl daemon-reload

systemctl enable --now  mongod

# Add Graylog rpm's

rpm -Uvh https://packages.graylog2.org/repo/packages/graylog-5.0-repository_latest.rpm

yum install graylog-server -y

sed -i "s/^password_secret =.*/password_secret = $(< /dev/urandom tr -dc A-Za-z0-9 | head -c${1:-96})/" /etc/graylog/server/server.conf

# Password is "admin" >> "8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918" but you can change it 

# echo -n "Enter Password: " && head -1 </dev/stdin | tr -d '\n' | sha256sum | cut -d" " -f1

sed -i "s/^root_password_sha2 =.*/root_password_sha2 = 8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918/" /etc/graylog/server/server.conf

sed -i "s/^#http_bind_address =.*/http_bind_address = 192.168.78.14/" /etc/graylog/server/server.conf


systemctl daemon-reload

systemctl enable graylog-server.service

systemctl start graylog-server.service

#sudo setsebool -P httpd_can_network_connect 1

#sudo semanage port -a -t http_port_t -p tcp 9000

#sudo semanage port -a -t http_port_t -p tcp 9200

#sudo semanage port -a -t mongod_port_t -p tcp 27017

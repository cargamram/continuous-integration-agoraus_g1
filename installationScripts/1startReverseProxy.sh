#! /bin/bash
CERTS_PATH=~/LetsEncryptCerts

docker run -d -p 80:80 -p 443:443 \
  --name reverse-proxy \
  --restart=always \
  -v $CERTS_PATH:/etc/nginx/certs:ro \
  -v /etc/nginx/vhost.d \
  -v /usr/share/nginx/html \
  -v /var/run/docker.sock:/tmp/docker.sock:ro \
  jwilder/nginx-proxy
  
  
echo "Docker nginx-proxy (reverse-proxy)"
echo "The docker use the certs in $CERTS_PATH"

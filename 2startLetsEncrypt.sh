#! /bin/bash
CERTS_PATH=~/LetsEncryptCerts

docker run -d \
  -v $CERTS_PATH:/etc/nginx/certs:rw \
  --volumes-from nginx-proxy \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  jrcs/letsencrypt-nginx-proxy-companion
  
  
echo "Docker Let's Encrypt"
echo "The docker create the certs in $CERTS_PATH"

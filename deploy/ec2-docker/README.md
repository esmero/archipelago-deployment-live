# Self Signed Cert

To use a Self Signed Cert run on your host machine, from this folder

sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ../../data_storage/selfcert/private/nginx.key -out ../../data_storage/selfcert/certs/nginx.crt
sudo openssl dhparam -out ../../data_storage/selfcert/dhparam.pem 4096

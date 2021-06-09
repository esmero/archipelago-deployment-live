# Self Signed Cert

To use a Self Signed Cert run on your host machine, from this folder

sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ../../data_storage/selfcert/private/nginx.key -out ../../data_storage/selfcert/certs/nginx.crt
sudo openssl dhparam -out ../../data_storage/selfcert/dhparam.pem 4096

#EC2 on AWS Linux
1.- If you added a secondary Volumen for persistent data that is not S3 based follow this guide
https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-using-volumes.html

2.- Install Docker using this guide https://docs.aws.amazon.com/AmazonECS/latest/developerguide/docker-basics.html. You may need to reboot afterwards

Customizing

cp .env.template to .env and modify passwords/domains

Rename the file found inside archipelago-deployment-live/config_storage/nginxconfig/certbot_extra_domains and name it like your primary domain
Add all your subdomains there (if any) if not leave empty

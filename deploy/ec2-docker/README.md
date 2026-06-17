#EC2 on AWS Linux
1.- If you added a secondary Volumen for persistent data that is not S3 based follow this guide
https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-using-volumes.html

2.- Install Docker using this guide https://docs.aws.amazon.com/AmazonECS/latest/developerguide/docker-basics.html. You may need to reboot afterwards

Customizing

cp .env.template to .env and modify passwords/domains

# archipelago-deployment-live

A Cloud / Local production ready Archipelago Deployment using Docker and soon Kubernetes.


## What is this repo for?

Running Archipelago Commons on a live public instance using SSL with Blob/Object Storage backend 

- Cloud based deployment. E.g AWS/Azure under Linux
- Self managed servers running Linux
- x86/AMD86 or ARM64/v8 CPU architectures

## What is this repo not for? 
- Running your own local/development Archipelago. For that we suggest using https://github.com/esmero/archipelago-deployment

## Requirements
###Minimal
- 4 Gbytes of RAM (e.g AWS EC2 t3.medium) 2 CPUs, Single SSD Drive of 100 Gbytes
###Recommend base line
- 8 Gbytes of RAM (AWS EC2 t3.medium)  2 CPUs, Single SSD Drive of 100 Gbytes, optional: one magnetic Drive of 500 Gbytes for Caches/Temp files/Backups.
### Good for all large repository
- 16 Gbytes of RAM (AWS EC2 m6g.xlarge - Graviton)  4 CPUs, Single SSD Drive of 200 Gbytes, optional: one magnetic Drive of 1TB for Caches/Temp files/Backups.
### OS:
- Ubuntu 20.04 /Amazon Linux 2/Debian 10.9 / AlmaLinux (Centos replacement) matching your CPU archicture (of course)
- Most recent Docker as a running as a service and docker-compose 
- Basic Unix/Linux terminal skills and a root/sudo account

# Deployment on Linux/X86/AMD system

## Step 1:
Deploy your base system


Make sure your Firewall/AWS Security group has these ports open for everyone to access
- 443 (NGINX SSL)
- 80 (NGINX HTTP)
And protected/modally open for your own development/testing/administration
- 8183 (Cantaloupe)
- 8983 (Solr)
- 6400 (NLP64)
- 9000 (Minio)
- 22 (so you can ssh into your machine)

Setup your system using your fav. package manager with 

- Docker
- git
- htop
- tree
- docker-compose

e.g for Amazon Linux 2 these steps are tested:
```SHELL
sudo yum update -y
sudo amazon-linux-extras install docker
sudo yum install -y docker
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo chkconfig docker on
sudo systemctl enable docker
sudo yum install -y git htop tree
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
sudo reboot
```
Reboot is needed to allow Docker to take full control over your OS resources.

## Step 2:

In your location of choice clone this repo
```SHELL
git clone https://github.com/esmero/archipelago-deployment-live
cd archipelago-deployment-live
git checkout 1.0.0-RC2
```

## Step 3. Setup your enviromental variables for Docker/Services

### Setup Enviromentals

Setup your deployment enviromental variables by copying the template

```
cp deploy/ec2-docker/.env.template deploy/ec2-docker/cd ec2-docker/.env
```
and editing it

```Shell
nano deploy/ec2-docker/ec2-docker/.env
```

The content of that file is the following
```ENV
ARCHIPELAGO_ROOT=/home/ec2-user/archipelago-deployment-live
ARCHIPELAGO_EMAIL=your@validemail.org
ARCHIPELAGO_DOMAIN=your.domain.org
MINIO_ACCESS_KEY=THE_S3_AZURE_OR_LOCAL_MINIO_KEY
MINIO_SECRET_KEY=THE_S3_AZURE_OR_LOCAL_MINIO_SECRET
MYSQL_ROOT_PASSWORD=YOUR_MYSQL_PASSWORD_FOR_ARCHIPELAGO
MINIO_BUCKET_MEDIA=THE_NAME_OF_YOUR_S3_BUCKET_FOR_PERSISTEN_STORAGE
MINIO_FOLDER_PREFIX_MEDIA=media/
MINIO_BUCKET_CACHE=THE_NAME_OF_YOUR_S3_BUCKET_FOR_IIIF_STORAGE
MINIO_FOLDER_PREFIX_CACHE=iiifcache/
```

What does each key mean?

- `ARCHIPELAGO_ROOT`: the absolute path to your `archipelago-deployment-live` git repo in your host machine.
- `ARCHIPELAGO_EMAIL`: a valid email, will be used to register your SSL Certificate via Certbot.
- `ARCHIPELAGO_DOMAIN`: A valid domain name for your repository. If not using your own it may be one provided by your Cloud provider. e.g http://ec2-xx-xxx-xxx-xx.compute-1.amazonaws.com. This domain will be also used to request your SSL Certificate via Certbot.
- `MINIO_ACCESS_KEY`: If you are running a Cloud Service backed S3/Azure Storage this needs to generated there. The user/IAM owner of this ACCESS KEY needs to have access to read/write the bucket you will configure in this same .env file. If running local `min.io` whatever you set will be used.
- `MINIO_SECRET_KEY`: If you are running a Cloud Service backed S3/Azure Storage this needs to generated there. The user/IAM owner of the matching SECRET_KEY needs to have access to read/write the bucket you will configure in this same .env file. If running local `min.io` whatever you set will be used.
- `MYSQL_ROOT_PASSWORD`: The MYSQL 8 or Mariadb 15 password. This password will be used later also during Drupal deployment via `drush`
- `MINIO_BUCKET_MEDIA`: The name of your Persistant Storage Bucket. If using mini.io local we recommend keeping it simple. E.g `archipelago`
- `MINIO_FOLDER_PREFIX_MEDIA`: The `folder` (a prefix really) where your DO Storage and File storage will go inside the `MINIO_BUCKET_MEDIA` Bucket. `media/` is a fine name for this one and common in archipelago deployments
- `MINIO_BUCKET_CACHE`: The name of your IIIF Cache storage Bucket. May be the same as `MINIO_BUCKET_MEDIA`. If different make sure your your `MINIO_ACCESS_KEY` and/or IAM role ACL have permission to read write to this one too. 
- `MINIO_FOLDER_PREFIX_CACHE`:  The `folder` (a prefix really) where Cantaloupe will/can write its iiif caches. `iiifcache/` is a good name.

`IMPORTANT NOTE`: For AWS EC2. If your selected an `IAM role` for your server when setting it up/deploying it, `min.io` will use the AWS EC2 backed internal API to request access to your S3. This means the ROLE itself needs to have read/write access (ACL) to the given Bucket(s) and your key/secrets won't be able to override that. Please do not ignore this note. It will save you a LOT of frustration and coffee. You can also run an EC2 instace without a given IAM and in that case just the ACCESS_KEY/SECRET will matter.

Now that you know, you also know that these values should be not **shared** and this `.env` file **should not** commited/kept in version control. Please be careful.

`docker-compose` will read this .env and start all services for you based on its content.
Once you have modified this and you are ready for your first big decision. 

### Running a fully qualified domain you wish a valid/signed certificate for?

This means you will use the  `docker-compose-aws-s3.yml`. Do the following
```Shell
cp deploy/ec2-docker/docker-compose-aws-s3.yml deploy/ec2-docker/docker-compose.yml
```
##### Optional (expert) extra domains:
If you have more than a single domain you may create a text file inside 
`config_storage/nginxconfig/certbot_extra_domains/your.domain.org` and write for each subdomain there an entry/line.

### OR Running self-signed? (optional) . 

Only if you are not running a fully qualified domain you wish a valid/signed

Generate a self signed Cert
```SHELL
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout data_storage/selfcert/private/nginx.key -out data_storage/selfcert/certs/nginx.crt 
sudo openssl dhparam -out data_storage/selfcert/dhparam.pem 4096
cp deploy/ec2-docker/docker-compose-selfsigned.yml deploy/ec2-docker/docker-compose.yml
```

Note: Self signed docker-compose.yml file is setup to use min.io with local storage
```YAML
    volumes:
      - ${ARCHIPELAGO_ROOT}/data_storage/miniodata:/data:cached
```
This folder will be created by minio. If you are using a secondary Drive (e.g magnetic) you can modify your `deploy/ec2-docker/docker-compose.yml` to use a folder there e.g . 

```YAML
    volumes:
      - /persistentinotherdrive/data_storage/miniodata:/data:cached
```

Make sure your logged in user can read/write to it.

NOTE: If you want to use AWS S3 storage for the self signed version replace the minio Service YAML block with this [Service Block](https://github.com/esmero/archipelago-deployment-live/blob/e90cf7701f1ae8e0a580a0901aaadb669baa21fd/deploy/ec2-docker/docker-compose-aws-s3.yml#L108-L125) in your new `deploy/ec2-docker/docker-compose.yml`. You can mix and match services and even remove all `:cached` statements for improved volumen performance.


### Now Permissions

```SHELL
sudo chown -R 100:100 data_storage/iiifcache
sudo chown -R 8983:8983 data_storage/solrcore
```

### First Run

Time to spin our docker containers for the first time. We will start all without going into background so log/error checking is easier. Specially if you have selected a Valid/Signed Cert choice and also want to be sure S3 keys/access are working

```SHELL
cd deploy/ec2-docker
docker-compose up
```
You will see a lot of things happening. Check for errors/problems/clear alerts and give all a minute or so to start. 

... More soon






# Ubuntu Deployment Scripts for mrnaid.dichlab.org

This repository contains the deployment configuration for the public http://mrnaid.dichlab.org/ server.


## Deploying a new release

To deploy a new release, simply run the `./deploy.sh` script. 

## First time setup on Ubuntu

Here's how to set up the deployment. You'll need root acces for this (us `su root` or `sudo bash` to run as root).

Summary of the following steps:
- Set up directory and mrnaid user
- Install Conda
- Install and set up redis database
- Set up uwsgi & celery worker services
- Set up Nginx server and SSL

Some steps might be skipped here. If you get stuck, Google is your friend 😊

### Create deployment directory

This directory will host all the settings.

```bash
# Create deployment directory (you need root access for this and everything that follows)
mkdir /opt/mrnaid-deployment
cd /opt/mrnaid-deployment
# Clone this repo (or your own fork) into current directory
git clone git@github.com:lich-uct/mrnaid.dichlab.org.git .
```


### Add mrnaid user

```bash
useradd mrnaid
addgroup mrnaid staff
addgroup mrnaid www-data
mkdir /home/mrnaid /home/mrnaid/run
chown mrnaid:mrnaid /home/mrnaid /home/mrnaid/run
```

### Create Conda environment

Install [Conda](https://docs.conda.io/projects/conda/en/latest/user-guide/install/download.html) or one of the alternatives ([Miniconda](https://docs.conda.io/en/latest/miniconda.html), [Miniforge](https://github.com/conda-forge/miniforge), [Mamba](https://github.com/mamba-org/mamba)).

```bash
# Create the mRNAid conda environment
conda env create -n mRNAid -f /opt/mrnaid-code/backend/flask_app/environment.yml
conda activate mRNAid

```

### Install redis

```bash
apt-get install redis-server
```

This will automatically start it as a service in the background

```bash
# Try calling redis
redis-cli PING
# You should get PONG
```

### Clone mRNAid repository
```bash
# create directory for code
mkdir /opt/mrnaid-code
cd /opt/mrnaid-code
# clone repository
git clone git@github.com:Merck/mRNAid.git .
```




### Set up uWSGI service

Check the local uWSGI web server config and adjust as needed: 

- [uwsgi/mrnaid-uwsgi.service](uwsgi/mrnaid-uwsgi.service) uWSGI service config
- [uwsgi/uwsgi.sh](uwsgi/uwsgi.sh) uWSGI script
- [activate.sh](activate.sh) Conda and ENV var activation, adjust path to conda installation

Register the config as a systemd service:

```
ln -s /opt/mrnaid-deployment/uwsgi/mrnaid-uwsgi.service /etc/systemd/system/mrnaid-uwsgi.service
```

```bash
# Start uWSGI
systemctl start mrnaid-uwsgi
# Register uwsgi at startup (important!)
systemctl enable mrnaid-uwsgi
# Check the status of uwsgi
systemctl status mrnaid-uwsgi
```

See flask uwsgi log using: `journalctl -u mrnaid-uwsgi.service -e`

### Set up celery service

Check the local celery worker config and adjust as needed: 

- [celery/mrnaid-celery.service](celery/mrnaid-celery.service) Celery service config
- [celery/celery.sh](celery/celery.sh) Celery script, adjust concurrency based on your CPU count here
- [activate.sh](activate.sh) Conda and ENV var activation

Register the config as a systemd service:

```bash
ln -s /opt/mrnaid-deployment/celery/mrnaid-celery.service /etc/systemd/system/mrnaid-celery.service
```

```bash
# Start celery
systemctl start mrnaid-celery
# Register celery at startup (important!)
systemctl enable mrnaid-celery
# Check the status of celery
systemctl status mrnaid-celery
```

See celery task log using: `journalctl -u mrnaid-celery.service -e`

## Set up nginx

Nginx will listen to HTTP & HTTPS traffic and serve the uwsgi responses as a proxy server.

Based on: https://www.nginx.com/blog/using-free-ssltls-certificates-from-lets-encrypt-with-nginx/

Remove default config files:
```
# location may vary based on your system and installation
rm /etc/nginx/conf.d/default.conf
```
and replace them with custom ones:
```
# target location may vary based on your system and installation
cp ./config/nginx.conf /etc/nginx/conf.d/
```
Copy the build files:
```
cp -R /opt/mrnaid-code/frontend/build/* /usr/share/nginx/html
```
(See [mRNAid readme](https://github.com/Merck/mRNAid))

Enable the config:

```
ln -s /etc/nginx/sites-available/mrnaid.dichlab.org /etc/nginx/sites-enabled/mrnaid.dichlab.org
```

```
# Restart nginx
systemctl restart nginx
# Check status
systemctl status nginx
```

### Set up HTTPS access

Generate SSL certificate using certbot 
(see [installation guide for Ubuntu 20](https://certbot.eff.org/lets-encrypt/ubuntufocal-nginx) 
or [other platforms](https://certbot.eff.org/instructions))

```
# Generate and install certificate
certbot --nginx -d mrnaid.dichlab.org
```

Your nginx config file `/etc/nginx/sites-available/mrnaid.dichlab.org` should now be updated with the SSL config.

```
# Restart nginx
systemctl restart nginx
# Check status
systemctl status nginx
```

### Done!

You should be all good to go. 

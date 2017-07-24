## Setting Kubernetes dashboard with authentication using htpasswd.

##### By default Kubernetes dashboard is open. I put some authentication using nginx and htpasswd. Images available in docker hub ```prasenforu/loginkubedash```. Just use yml file (loginkubedash.yml) and change last line volume host path.

#### Step 1	
Create a folder and set that folder as SELINUX is enable so container can mount files from host.
```
mkdir /root/pkar
cd /root/pkar
chcon -Rt svirt_sandbox_file_t /root/pkar	- not required for ubuntu
```
where container will be deploy in host (where container will be deploy)
```
yum install -y httpd-tools
apt-get install apache2-utils             - for ubuntu

htpasswd -c /root/pkar/users.htpasswd admin
htpasswd /root/pkar/users.htpasswd testuser
htpasswd /root/pkar/users.htpasswd pkar 
```
##### Note : Make sure you install packages & create htpasswd file, where container will be deploy.

#### Step 2
Create nginx "Dockerfile" in this “/root/pkar“ with below content

```
FROM nginx:latest

MAINTAINER Prasenjit Kar <prasenforu@hotmail.com>

RUN apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install --no-install-recommends -y apache2-utils && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
COPY default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

#### Step 3
Creat nginx configuration file “default.conf” in this “/root/pkar“ with below content.
And change below highlighted part as below with your master ip.

```
upstream backend {
        server kubernetes-dashboard:80;
}

server {
  listen       80;
  server_name  localhost;
  location / {
      proxy_pass http://backend/;
      root   /usr/share/nginx/html;
      index  index.html index.htm;
      auth_basic "Restricted";                         #For Basic Auth
      auth_basic_user_file /etc/nginx/users.htpasswd;  #For Basic Auth
  }
}
```

#### Step 4
Build your custom nginx container, make sure build done and you can see image.

```
docker build -t loginkubedash .
```


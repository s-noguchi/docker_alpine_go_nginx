# docker_alpine_go_nginx

# Overview
alpine3.4  
go1.7  
nginx1.11.3

# Usage
## 1.Pull or Download this Repository

## 2.Docker Build
```
docker build --no-cache . -t alpine-go-nginx
```

## 3.Start Docker container
```
docker run -d -v /YOUR LOCAL PATH/hello:/home/go/hello -p 1000:80 -i -t alpine-go-nginx /bin/bash
```

## 4.Start Nginx
```
nginx
```

## 5.Start Fresh(Go)
```
cd /home/go/hello
fresh
```

## 6.Access Hello World
Access your browser 
```
http://localhost:1000
```

FROM alpine:3.4

MAINTAINER Shinobu Noguchi

# Update apk
RUN apk update

# Install Necessary packages
RUN apk add --no-cache wget bash git supervisor gcc build-base openssl-dev pcre-dev

# Install glibc
RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub --no-check-certificate -P /tmp
RUN wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.23-r3/glibc-2.23-r3.apk --no-check-certificate -P /tmp
RUN apk add --no-cache /tmp/glibc-2.23-r3.apk

# Install Go1.7.1
RUN wget https://storage.googleapis.com/golang/go1.7.1.linux-amd64.tar.gz --no-check-certificate -P /tmp
RUN tar -C /usr/local -xzf /tmp/go1.7.1.linux-amd64.tar.gz

# Set Go path
ENV GOPATH /home/go
ENV PATH $PATH:/usr/local/go/bin:$GOPATH/bin

# Install Fresh
# https://github.com/pilu/fresh
RUN go get github.com/pilu/fresh

# Remove /tmp files
RUN rm /tmp/go1.7.1.linux-amd64.tar.gz
RUN rm /tmp/glibc-2.23-r3.apk

## Install Nginx
WORKDIR /tmp
RUN wget https://nginx.org/download/nginx-1.11.3.tar.gz
RUN tar zxvf /tmp/nginx-1.11.3.tar.gz
WORKDIR /tmp/nginx-1.11.3
RUN ./configure --prefix=/usr/local/nginx --user=nginx --group=nginx --with-http_ssl_module
RUN make
RUN make install

# Add nginx user
RUN adduser -D nginx
RUN passwd nginx -d nginx
RUN addgroup nginx nginx

# Set nginx psth
ENV PATH $PATH:/usr/local/nginx/sbin

# Set default.conf
WORKDIR /usr/local/nginx/conf
COPY ./nginx/nginx.conf nginx.conf

# Set virtual.conf
WORKDIR /usr/local/nginx
RUN mkdir conf.d
WORKDIR /usr/local/nginx/conf.d
COPY ./nginx/virtual.conf virtual.conf

# Set Supervisor
RUN touch /etc/supervisord.conf
RUN echo '[supervisord]'  >> /etc/supervisord.conf
RUN echo 'nodaemon=true'  >> /etc/supervisord.conf
RUN echo '[program:nginx]' >> /etc/supervisord.conf
RUN echo 'command=/usr/local/nginx/sbin/nginx -g "daemon off;"'   >> /etc/supervisord.conf
RUN echo '[program:hello]' >> /etc/supervisord.conf
RUN echo 'command=go run /home/go/hello/hello.go'   >> /etc/supervisord.conf

# Option Setting
# If you use JST TimeZone
RUN apk --update add tzdata && \
    cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
    apk del tzdata

# Start Supervisor
CMD ["/usr/bin/supervisord"]

EXPOSE 80 443 22

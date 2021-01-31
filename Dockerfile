FROM debian:buster-slim
SHELL ["bash", "-c"]
WORKDIR /usr/share/bind9
ENV DEBIAN_FRONTEND noninteractive
RUN apt update && apt-get install -y bind9
RUN echo 'include "/usr/share/bind9/named.conf.jsxjp-zone";' >> /etc/bind/named.conf
COPY named.conf.jsxjp-zone .
COPY db.jsxjp .
RUN rm -fr /var/lib/apt/lists/*
EXPOSE 53
CMD ["/usr/sbin/named", "-u", "bind", "-g"]

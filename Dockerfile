FROM debian:bullseye-slim
SHELL ["bash", "-c"]
WORKDIR /usr/share/bind9
ENV DEBIAN_FRONTEND noninteractive
RUN apt update && apt-get install -y bind9
RUN rm -fr /var/lib/apt/lists/*
RUN echo 'include "/usr/share/bind9/named.conf.jsxjp-zone";' >> /etc/bind/named.conf
RUN echo 'include "/usr/share/bind9/named.conf.deny-zone";' >> /etc/bind/named.conf
COPY named*zone .
COPY db* .
RUN chown -R bind. .
EXPOSE 53
CMD ["/usr/sbin/named", "-u", "bind", "-g"]

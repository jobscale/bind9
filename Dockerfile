FROM node:lts-trixie-slim
SHELL ["bash", "-c"]
WORKDIR /usr/share/bind9
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get upgrade -y --no-install-recommends \
 && apt-get install -y --no-install-recommends bind9 ca-certificates curl vim dnsutils netcat-openbsd \
 && apt-get clean && rm -fr /var/lib/apt/lists/*

RUN sed -i -e 's/\/\/ forwarders {/allow-query { any; };\n\tforwarders { 8.8.8.8; };/' /etc/bind/named.conf.options \
 && sed -i -e 's/dnssec-validation auto;/dnssec-validation no;/' /etc/bind/named.conf.options
RUN echo 'include "/usr/share/bind9/named.conf.jsxjp-zone";' >> /etc/bind/named.conf
RUN echo 'include "/usr/share/bind9/named.conf.deny-zone";' >> /etc/bind/named.conf

COPY --chown=bind:staff named*zone .
COPY --chown=bind:staff db* .
RUN chown -R bind. . && chmod -R go+rX .
COPY --chown=bind:staff index.js .
COPY docker-entrypoint /
EXPOSE 53
# /usr/sbin/named -u bind -g
CMD ["/docker-entrypoint"]

FROM debian:bookworm-slim
SHELL ["bash", "-c"]
WORKDIR /usr/share/bind9
ENV DEBIAN_FRONTEND noninteractive
RUN apt update && apt-get install -y bind9 vim dnsutils
RUN rm -fr /var/lib/apt/lists/*
RUN echo 'include "/usr/share/bind9/named.conf.jsxjp-zone";' >> /etc/bind/named.conf
RUN echo 'include "/usr/share/bind9/named.conf.deny-zone";' >> /etc/bind/named.conf
RUN sed -i -e 's/\/\/ forwarders {/allow-query { any; };\n\tforwarders { 8.8.8.8; };/' /etc/bind/named.conf.options
COPY --chown=bind:staff named*zone .
COPY --chown=bind:staff db* .
RUN chown -R bind. . && chmod -R go+rX .
EXPOSE 53
CMD ["/usr/sbin/named", "-u", "bind", "-g"]

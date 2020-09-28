FROM buildpack-deps:buster

RUN apt-get update && apt-get install -y \
    libgmp-dev \
    iptables \
    kmod \
    && rm -rf /var/lib/apt/lists/* \
    # Starting with Debian Buster iptables uses nf_tables as a backend for iptables.
    # Since we use iptables on the host we have to switch the backend:
    # https://wiki.debian.org/iptables
    && update-alternatives --set iptables /usr/sbin/iptables-legacy \
    && update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy

RUN groupadd vpn

ARG STRONGSWAN_VERSION
RUN mkdir -p /usr/src/strongswan \
    && curl -SL "https://download.strongswan.org/strongswan-$STRONGSWAN_VERSION.tar.bz2" \
    | tar -jxC /usr/src/strongswan --strip-components 1 \
    && cd /usr/src/strongswan \
    && ./configure --prefix=/usr --sysconfdir=/etc \
    && make -j \
    && cd /usr/src/strongswan && make install \
    && rm -rf /usr/src/strongswan 

RUN rm /etc/ipsec.secrets
RUN mkdir -p /etc/ipsec.d/conf && touch /etc/ipsec.d/conf/placeholder.conf
RUN echo "include /etc/ipsec.d/conf/*.conf" >> /etc/ipsec.conf

ADD ipsec_start /usr/local/bin/ipsec_start
ADD pipework /usr/local/bin/pipework

VOLUME /etc/ipsec.d

EXPOSE 4500/udp 500/udp

ENTRYPOINT ["/usr/local/bin/ipsec_start"]
CMD []

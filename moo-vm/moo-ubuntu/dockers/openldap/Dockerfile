FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    build-essential \
    libtool \
    libssl-dev \
    libsasl2-dev \
    libdb-dev \
    libldap2-dev \
    curl \
    groff \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L -o /tmp/openldap.tgz \
    https://www.openldap.org/software/download/OpenLDAP/openldap-release/openldap-2.4.59.tgz \
    && cd /tmp && tar xzf openldap.tgz \
    && cd openldap-2.4.59 \
    && ./configure \
        --prefix=/usr/local \
        --enable-slapd \
        --enable-modules \
        --enable-overlays=no \
        --enable-memberof=mod \
        --enable-refint=mod \
    && make -j4 && make install

RUN rm -f /usr/local/libexec/openldap/*translucent*

RUN groupadd -r ldap && useradd -r -g ldap ldap

RUN mkdir -p /usr/local/var/run \
    /usr/local/etc/openldap/schema \
    /usr/local/var/openldap-data \
    /container/service/slapd \
    /container/service/slapd/assets/ldif \
    /container/service/slapd/assets/schema \
    /container/service/slapd/assets/overlays

RUN chown -R ldap:ldap /usr/local/var

COPY slapd.conf /container/service/slapd/slapd.conf
COPY bootstrap.sh /container/service/slapd/bootstrap.sh
COPY schema/ /usr/local/etc/openldap/schema/
COPY ldif/ /container/service/slapd/assets/ldif/

RUN chmod +x /container/service/slapd/bootstrap.sh

RUN tr -d '\r' < /container/service/slapd/slapd.conf \
    | sed '1s/^\xEF\xBB\xBF//' \
    > /container/service/slapd/slapd.conf.clean \
    && mv /container/service/slapd/slapd.conf.clean /container/service/slapd/slapd.conf

CMD ["/container/service/slapd/bootstrap.sh"]

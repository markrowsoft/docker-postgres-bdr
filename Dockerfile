FROM ubuntu:16.04
MAINTAINER mark@markrowsoft.com

ENV PG_APP_HOME="/etc/docker-postgresql"\
    PG_VERSION=9.4 \
    PG_USER=postgres \
    PG_HOME=/var/lib/postgresql \
    PG_RUNDIR=/usr/lib/postgresql/$PG_VERSION/bin \
    PG_LOGDIR=/var/log/postgresql \
    PG_CERTDIR=/etc/postgresql/certs

ENV PG_BINDIR=/usr/lib/postgresql/${PG_VERSION}/bin \
    PG_DATADIR=/var/lib/postgresql/data
RUN apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8
RUN apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys 855AF5C7B897656417FA73D65D941908AA7A6805
RUN apt-get update
RUN apt-get install -y wget vim locate sudo

RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
 && echo 'deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main' > /etc/apt/sources.list.d/pgdg.list \
 && echo 'deb http://packages.2ndquadrant.com/bdr/apt/ jessie-2ndquadrant main' > /etc/apt/sources.list.d/pgdg.list \
 && apt-get update \
 && apt-get install -y postgresql-common \
 && sed -ri 's/#(create_main_cluster) .*$/\1 = false/' /etc/postgresql-common/createcluster.conf \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y acl \
      postgresql-bdr-${PG_VERSION} postgresql-client-${PG_VERSION} postgresql-bdr-contrib-${PG_VERSION} 
RUN cp -v /usr/share/postgresql/$PG_VERSION/postgresql.conf.sample /usr/share/postgresql/ \
#	&& ln -sv ../postgresql.conf.sample /usr/share/postgresql/$PG_MAJOR/ \
	&& sed -ri "s!^#?(listen_addresses)\s*=\s*\S+.*!\1 = '*'!" /usr/share/postgresql/postgresql.conf.sample
#  RUN mkdir -p /var/run/postgresql && chown -R postgres /var/run/postgresql
#  RUN ln -sf ${PG_DATADIR}/postgresql.conf /etc/postgresql/${PG_VERSION}/main/postgresql.conf \
#  && ln -sf ${PG_DATADIR}/pg_hba.conf /etc/postgresql/${PG_VERSION}/main/pg_hba.conf \
#  && ln -sf ${PG_DATADIR}/pg_ident.conf /etc/postgresql/${PG_VERSION}/main/pg_ident.conf \
#  && rm -rf ${PG_HOME} \
#  && rm -rf /var/lib/apt/lists/*

ENV PATH=/usr/lib/postgresql/$PG_MAJOR/bin:$PATH



COPY runtime/ ${PG_APP_HOME}/
COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 5432/tcp
VOLUME ["${PG_HOME}", "${PG_RUNDIR}"]
WORKDIR ${PG_HOME}
ENTRYPOINT ["/sbin/entrypoint.sh"]
CMD ["bash"]

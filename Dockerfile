FROM postgis/postgis:15beta3-3.3.0rc2-alpine

# https://github.com/citusdata/docker/blob/master/alpine/Dockerfile
# Build citus and delete all used libraries. Warning: Libraries installed in this section will be deleted after build completion
ARG VERSION=11.0.6

RUN apk add --no-cache \
            --virtual builddeps \
        build-base \
        krb5-dev \
        curl \
        curl-dev \
        openssl-dev \
        ca-certificates \
        clang \
        llvm \
        lz4-dev \
        zstd-dev \
        libxslt-dev \
        libxml2-dev \
        icu-dev && \
    apk add --no-cache libcurl && \
    curl -sfLO "https://github.com/citusdata/citus/tarball/master.tar.gz" && \
    tar xzf "master.tar.gz" && \
    cd "citusdata-citus-cc0eeea" && \
   ./configure --with-security-flags && \
    make install && \
    cd .. && \
    rm -rf "citusdata-citus-cc0eeea" "master.tar.gz" && \
    apk del builddeps

#--------End of Citus Build

# add citus to default PostgreSQL config
RUN echo "shared_preload_libraries='citus'" >> /usr/local/share/postgresql/postgresql.conf.sample

# add scripts to run after initdb
COPY 001-create-citus-extension.sql /docker-entrypoint-initdb.d/

# add health check script
COPY pg_healthcheck /

# entry point unsets PGPASSWORD, but we need it to connect to workers
# https://github.com/docker-library/postgres/blob/33bccfcaddd0679f55ee1028c012d26cd196537d/12/docker-entrypoint.sh#L303
RUN sed "/unset PGPASSWORD/d" -i /usr/local/bin/docker-entrypoint.sh

# Add lz4 dependencies
RUN apk add zstd zstd-dev lz4 lz4-dev

HEALTHCHECK --interval=4s --start-period=6s CMD ./pg_healthcheck
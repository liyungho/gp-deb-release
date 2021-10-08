FROM ubuntu:18.04

RUN apt-get update && \
    apt-get install -y software-properties-common \
                   debmake \
                   equivs \
                   git

WORKDIR /tmp

RUN git clone https://github.com/greenplum-db/gp-xerces.git

WORKDIR /tmp/gp-xerces

RUN mkdir build

WORKDIR /tmp/gp-xerces/build

RUN ../configure --prefix=/usr/local && make && make install && echo "/usr/local/lib" >> /etc/ld.so.conf && ldconfig

WORKDIR /tmp

RUN git clone https://github.com/greenplum-db/gpdb.git && \
    git clone https://github.com/greenplum-db/gporca.git gpdb/gporca

COPY ./debian/ /tmp/gpdb/debian/

WORKDIR /tmp/gpdb

RUN git checkout "6X_STABLE"

RUN dch --create -M --package greenplum-db-6 -v $(./getversion --short) "Test release" && \
    yes | mk-build-deps -i debian/control && \
	DEB_BUILD_OPTIONS='nocheck parallel=6' debuild -us -uc -b

RUN echo The debian package is at /tmp/greenplum-db-6_$(./getversion --short).build.dev_amd64.deb

WORKDIR /tmp

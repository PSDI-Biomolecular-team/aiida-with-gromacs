# syntax=docker/dockerfile:1
FROM aiida-core

LABEL maintainer="James Gebbie-Rayet <james.gebbie@stfc.ac.uk>"

USER root

ARG GMX_VERSION

ARG PGSQL_VERSION
ARG RMQ_VERSION

ENV GMX_VERSION=${GMX_VERSION}

ENV PGSQL_VERSION=${PGSQL_VERSION}
ENV RMQ_VERSION=${RMQ_VERSION}

WORKDIR /opt/

RUN mamba install --yes \
     --channel conda-forge \
     postgresql=${PGSQL_VERSION} && \
     mamba clean --all -f -y && \
     fix-permissions "${CONDA_DIR}" && \
     fix-permissions "/home/${SYSTEM_USER}"

# Install aiida-gromacs
RUN pip install aiida-gromacs

# Install erlang.
RUN apt-get update --yes && \
     apt-get install --yes --no-install-recommends \
     erlang \
     cmake \
     xz-utils && \
     apt-get clean && rm -rf /var/lib/apt/lists/* && \
     # Install rabbitmq.
     wget -c --no-check-certificate https://github.com/rabbitmq/rabbitmq-server/releases/download/v${RMQ_VERSION}/rabbitmq-server-generic-unix-${RMQ_VERSION}.tar.xz && \
     tar -xf rabbitmq-server-generic-unix-${RMQ_VERSION}.tar.xz && \
     rm rabbitmq-server-generic-unix-${RMQ_VERSION}.tar.xz && \
     ln -sf /opt/rabbitmq_server-${RMQ_VERSION}/sbin/* /usr/local/bin/ && \
     fix-permissions /opt/rabbitmq_server-${RMQ_VERSION}

# s6-overlay to start services
COPY --chown="${SYSTEM_UID}:${SYSTEM_GID}" s6-assets/config-quick-setup.yaml "/aiida/assets/config-quick-setup.yaml"
COPY s6-assets/s6-rc.d /etc/s6-overlay/s6-rc.d
COPY s6-assets/init /etc/init

WORKDIR /tmp
# Grab a specified version of gromacs
RUN wget ftp://ftp.gromacs.org/gromacs/gromacs-${GMX_VERSION}.tar.gz && \
    tar xvf gromacs-${GMX_VERSION}.tar.gz && \
    rm gromacs-${GMX_VERSION}.tar.gz

# make a build dir
WORKDIR /tmp/gromacs-${GMX_VERSION}
RUN mkdir build

# build gromacs
WORKDIR /tmp/gromacs-${GMX_VERSION}/build
RUN cmake .. -DCMAKE_INSTALL_PREFIX=/opt/gromacs-${GMX_VERSION} -DGMX_BUILD_OWN_FFTW=ON -DGMX_OPENMP=ON -DGMXAPI=OFF -DCMAKE_BUILD_TYPE=Release
RUN make -j8
RUN make install
RUN rm -r /tmp/gromacs-${GMX_VERSION} && \
    fix-permissions "/opt/gromacs-${GMX_VERSION}" 

ENV PATH=/opt/gromacs-${GMX_VERSION}/bin:$PATH

USER ${SYSTEM_UID}

WORKDIR "/home/${SYSTEM_USER}"

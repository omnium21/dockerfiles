FROM ubuntu:focal

# Environment variables used by CI scripts
ENV ARMLMD_LICENSE_FILE=27000@ci.trustedfirmware.org

ENV DEBIAN_FRONTEND=noninteractive
ENV TOOLS_DIR=/opt/toolchains
ENV PATH=${TOOLS_DIR}/bin:${PATH}
ENV PKG_DEPS="\
    acpica-tools \
    autoconf \
    automake \
    autopoint \
    bc \
    bison \
    build-essential \
    bridge-utils \
    cpio \
    curl \
    dc \
    default-jre \
    device-tree-compiler \
    dosfstools \
    doxygen \
    expect \
    file \
    flex \
    fuseext2 \
    g++-multilib \
    gcc-multilib \
    gdisk \
    genext2fs \
    gettext \
    git \
    git-review \
    git-email \
    gperf \
    graphviz \
    iputils-ping \
    iproute2 \
    jq \
    less \
    libffi-dev \
    libssl-dev \
    libxml2 \
    libxml2-dev \
    libxml2-utils \
    libyaml-dev \
    libxml-libxml-perl \
    lld \
    locales \
    make \
    mtools \
    net-tools \
    openssh-server \
    openssh-client \
    perl \
    pkg-config \
    python \
    python-psutil \
    python3 \
    python3-crypto \
    python3-dev \
    python3-pip \
    python3-pyelftools \
    python3-psutil \
    python3-pyasn1 \
    rsync \
    sbsigntool \
    srecord \
    sudo \
    tree \
    unzip \
    uuid-dev \
    vim \
    virtualenv \
    wget \
    zip \
"

# Can be overriden at build time
ARG USER=someuser
ARG UID=1000
ARG GID=${UID}
ARG USER_PASSWORD=${USER}

COPY requirements_*.txt /opt/
COPY toolchain.install /tmp

RUN set -e ;\
    echo 'locales locales/locales_to_be_generated multiselect C.UTF-8 UTF-8, en_US.UTF-8 UTF-8 ' | debconf-set-selections ;\
    echo 'locales locales/default_environment_locale select en_US.UTF-8' | debconf-set-selections ;\
    apt-get update -q=2 ;\
    apt-get dist-upgrade -q=2 --yes ;\
    apt-get install -q=2 --yes --no-install-recommends ${PKG_DEPS} ;\
    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash ;\
    apt-get update -q=2 ;\
    apt-get install -q=2 --yes --no-install-recommends git-lfs ;\
    # Install Python requirements
    curl -s https://bootstrap.pypa.io/pip/get-pip.py -o /tmp/get-pip.py ;\
    python3 /tmp/get-pip.py ;\
    pip3 install --no-cache-dir -r /opt/requirements_python3.txt ;\
    # Set Python 3 as default
    ln -s -f /usr/bin/python3 /usr/bin/python ;\
    # cmake
    wget https://cmake.org/files/v3.21/cmake-3.21.3.tar.gz ;\
    tar xf cmake-3.21.3.tar.gz ;\
    cd cmake-3.21.3 ;\
    ./configure ;\
    make ;\
    make install ;\
    # Setup user
    groupadd -g ${GID} ${USER};\
    useradd -m -s /bin/bash ${USER} --uid ${UID} --gid ${GID};\
    echo "${USER}:${USER_PASSWORD}" | chpasswd ;\
    echo "${USER} ALL = NOPASSWD: ALL" > /etc/sudoers.d/${USER} ;\
    chmod 0440 /etc/sudoers.d/${USER} ;\
    # FIXME: add /arm as a temporary workaround until ARM CI moves to Open CI paths
    mkdir -p /var/run/sshd ${TOOLS_DIR} /arm ;\
    # Run shell script(s) to install files, toolchains, etc...
    bash -ex /tmp/toolchain.install ;\
    # Fix permissions
    chown -R ${USER}:${USER} ${TOOLS_DIR} /arm ;\
    # Cleanup
    apt-get clean ;\
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV LANG en_GB.UTF-8
ENV LANGUAGE en_GB.UTF-8
ENV LC_ALL en_GB.UTF-8
RUN \
    sed -i -e 's/# en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_GB.UTF-8

EXPOSE 22
CMD ["/bin/bash"]

FROM ubuntu:bionic

# Environment variables used by CI scripts
ENV ARMLMD_LICENSE_FILE=27000@ci.trustedfirmware.org

ENV DEBIAN_FRONTEND=noninteractive
ENV TOOLS_DIR=/opt/toolchains
ENV PATH=${TOOLS_DIR}/bin:${PATH}
ENV PKG_DEPS="\
    acpica-tools \
    autoconf \
    autopoint \
    bc \
    bison \
    build-essential \
    bridge-utils \
    cpio \
    curl \
    default-jre \
    device-tree-compiler \
    doxygen \
    expect \
    file \
    flex \
    fuseext2 \
    g++-multilib \
    gcc-multilib \
    gcc-6 \
    g++-6 \
    gdisk \
    genext2fs \
    git \
    git-review \
    git-email \
    gperf \
    graphviz \
    jq \
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
    openssh-server \
    openssh-client \
    perl \
    pkg-config \
    python \
    python-pip \
    python-psutil \
    python3 \
    python3-crypto \
    python3-dev \
    python3-pyelftools \
    python3-psutil \
    python3-pyasn1 \
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
ARG BUILDSLAVE_PASSWORD=ryan

COPY requirements_*.txt /opt/
COPY toolchain.install /tmp

RUN set -e ;\
    echo 'locales locales/locales_to_be_generated multiselect C.UTF-8 UTF-8, en_US.UTF-8 UTF-8 ' | debconf-set-selections ;\
    echo 'locales locales/default_environment_locale select en_US.UTF-8' | debconf-set-selections ;\
    apt update -q=2 ;\
    apt dist-upgrade -q=2 --yes ;\
    apt install -q=2 --yes --no-install-recommends ${PKG_DEPS} ;\
    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash ;\
    apt update -q=2 ;\
    apt install -q=2 --yes --no-install-recommends git-lfs ;\
    # Install Python requirements
    curl -s https://bootstrap.pypa.io/pip/3.5/get-pip.py -o /tmp/get-pip.py ;\
    python2 /tmp/get-pip.py ;\
    pip2 install --no-cache-dir -r /opt/requirements_python2.txt ;\
    python3 /tmp/get-pip.py ;\
    pip3 install --no-cache-dir -r /opt/requirements_python3.txt ;\
    # Set Python 3 as default
    ln -s -f /usr/bin/python3 /usr/bin/python ;\
    # Setup user
    useradd -m -s /bin/bash ryan ;\
    echo "ryan:$BUILDSLAVE_PASSWORD" | chpasswd ;\
    echo 'ryan ALL = NOPASSWD: ALL' > /etc/sudoers.d/jenkins ;\
    chmod 0440 /etc/sudoers.d/jenkins ;\
    # FIXME: add /arm as a temporary workaround until ARM CI moves to Open CI paths
    mkdir -p /var/run/sshd ${TOOLS_DIR} /arm ;\
    # Run shell script(s) to install files, toolchains, etc...
    bash -ex /tmp/toolchain.install ;\
    # Fix permissions
    chown -R ryan:ryan ${TOOLS_DIR} /arm ;\
    # Cleanup
    apt clean ;\
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
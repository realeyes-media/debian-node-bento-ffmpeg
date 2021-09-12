FROM bitnami/python:2.7.18-prod-debian-10-r126 as python

FROM bitnami/node:12.18.4-prod-debian-10-r1

ENV PATH="$PATH:/opt/bento4/bin:/opt/bitnami/python/bin" \
    BENTO4_BIN="/opt/bento4/bin" \
    BENTO4_BASE_URL="http://zebulon.bok.net/Bento4/binaries/" \
    BENTO4_TYPE="SDK" \
    BENTO4_VERSION="1-5-1-628" \
    BENTO4_CHECKSUM="47959b638897a4fc185b0ed1f194bdf13194af45" \
    BENTO4_TARGET=".x86_64-unknown-linux" \
    BENTO4_PATH="/opt/bento4"

ENV BENTO4_ZIP="Bento4-${BENTO4_TYPE}-${BENTO4_VERSION}${BENTO4_TARGET}.zip" \
    BENTO4_FILE="Bento4-${BENTO4_TYPE}-${BENTO4_VERSION}${BENTO4_TARGET}"

# Force Node to update
RUN npm -g update && npm install -g npm && npm install pm2 -g

# Install Dependencies
RUN install_packages git openssh-client gawk tzdata openntpd scons unzip zip wget xz-utils

# Install FFMPEG : https://www.osradar.com/install-the-latest-version-ffmpeg-ubuntu-debian/
RUN apt autoremove --purge ffmpeg && \
    mkdir -p /opt/ffmpeg && \
    cd /opt/ffmpeg && \
    wget -c https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz && \
    tar xvf ffmpeg-release-amd64-static.tar.xz && \
    cd ffmpeg-4.4-amd64-static/ && \
    ln -s "${PWD}/ffmpeg" /usr/local/bin/ && \
    ln -s "${PWD}/ffprobe" /usr/local/bin/

# Install Bento4 from binaries, checking SHA
WORKDIR /tmp/bento4
RUN wget ${BENTO4_BASE_URL}${BENTO4_ZIP} && \
    sha1sum -b ${BENTO4_ZIP} | \
    grep -o "^$BENTO4_CHECKSUM " && \
    mkdir -p ${BENTO4_PATH} && \
    unzip ${BENTO4_ZIP} -d ${BENTO4_PATH} && \
    rm -rf ${BENTO4_ZIP} && \
    cd ${BENTO4_PATH}/${BENTO4_FILE} && \
    mv * ${BENTO4_PATH} && \
    rm -rf ${BENTO4_PATH}/docs && \
    rm -rf ${BENTO4_PATH}/${BENTO4_FILE} && \
    cd / && \
    rm -rf /tmp/bento4 && \
    apt-get update && \
    apt-get purge -y unzip curl mercurial mercurial-common zip wget systemd xz-utils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Add Python from Bitnami base image
COPY --from=python /opt/bitnami/python /opt/bitnami/python

WORKDIR /app

CMD [ "pm2","--version" ]

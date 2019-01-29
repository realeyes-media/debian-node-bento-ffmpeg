FROM bitnami/node:10-debian-9-prod 

ENV PATH="$PATH:/opt/bento4/bin" \
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
RUN npm -g update && npm install -g npm

# Install Dependencies and FFMPEG
RUN install_packages git openssh-client gawk tzdata ffmpeg openntpd scons unzip zip wget

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
    rm -rf ${BENTO4_PATH}/${BENTO4_FILE}

# Install PM2
WORKDIR /app
RUN npm install pm2 -g

# Remove unnecessary software
RUN rm -rf /tmp/bento4 && apt-get update && apt-get purge -y unzip mercurial mercurial-common curl git gawk zip wget systemd

CMD [ "pm2","--version" ]

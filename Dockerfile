FROM node:10-stretch

# Install Node Deps and FFMPEG
RUN apt-get update && apt-get upgrade -y
RUN apt-get update && \
    apt-get install -y git openssh-client gawk tzdata ffmpeg && \
    apt-get -qqy clean && \
    rm -rf /var/lib/apt/lists/*

# Force Node to upgrade
RUN npm -g update && npm install -g npm

# Install Bento4
RUN apt-get update && \
    apt-get install -y openntpd scons unzip zip && \
    apt-get -qqy clean && \
    rm -rf /var/lib/apt/lists/*

# Install Bento
ENV PATH="$PATH:/opt/bento4/bin" \
    BENTO4_BIN="/opt/bento4/bin" \
    BENTO4_BASE_URL="http://zebulon.bok.net/Bento4/source/" \
    BENTO4_VERSION="1-5-1-624" \
    BENTO4_CHECKSUM="eae7e2a0714a9dc2b9390fdbc1632851a29d42c3" \
    BENTO4_TARGET="" \
    BENTO4_PATH="/opt/bento4" \
    BENTO4_TYPE="SRC"

RUN rm /bin/sh && ln -s /bin/bash /bin/sh
WORKDIR /tmp/bento4
    # download and check bento4
RUN wget ${BENTO4_BASE_URL}Bento4-${BENTO4_TYPE}-${BENTO4_VERSION}.zip && \
    sha1sum -b Bento4-${BENTO4_TYPE}-${BENTO4_VERSION}${BENTO4_TARGET}.zip | grep -o "^$BENTO4_CHECKSUM "
    # Unzip
RUN mkdir -p ${BENTO4_PATH} && \
    unzip Bento4-${BENTO4_TYPE}-${BENTO4_VERSION}${BENTO4_TARGET}.zip -d ${BENTO4_PATH} && \
    rm -rf Bento4-${BENTO4_TYPE}-${BENTO4_VERSION}${BENTO4_TARGET}.zip && \
    apt-get remove -y unzip && \
    # don't do these steps if using binary install
    cd ${BENTO4_PATH} && scons -u build_config=Release target=x86_64-unknown-linux && \
    cp -R ${BENTO4_PATH}/Build/Targets/x86_64-unknown-linux/Release ${BENTO4_PATH}/bin && \
    cp -R ${BENTO4_PATH}/Source/Python/utils ${BENTO4_PATH}/utils && \
    cp -a ${BENTO4_PATH}/Source/Python/wrappers/. ${BENTO4_PATH}/bin

# Install PM2
RUN npm install pm2 -g

CMD [ "pm2","--version" ]
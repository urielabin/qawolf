# ubuntu & node
FROM node:12.6.0-stretch

ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    QAWOLF_DIR="/home/qawolf"

RUN apt-get -qqy update && \
    # Install chrome
    apt-get install -y wget && \
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list && \
    apt-get update && apt-get -y install google-chrome-stable && \
    # Install opencv dependencies
    apt-get install -y libsm6 libxext6 libxrender-dev \
    # Install ffmpeg, nano, java, xvfb
    ffmpeg \
    nano \
    netcat \
    openjdk-8-jre-headless \
    xvfb \
    xfonts-100dpi \
    xfonts-75dpi \
    xfonts-scalable \
    xfonts-cyrillic && \
    # Free up space
    apt-get clean && \
    # Add user so we don't need --no-sandbox.
    groupadd -r qawolf && useradd -r -g qawolf -G audio,video qawolf \
    && mkdir -p /home/qawolf/Downloads \
    && chown -R qawolf:qawolf /home/qawolf

# Run everything after as non-privileged user.
USER qawolf

# Copy everything and install dependencies in a static location that is not WORKDIR
# WORKDIR will be replaced by github action volume
COPY --chown=qawolf:qawolf . ${QAWOLF_DIR}/.

# uncomment to see what is copied
# RUN find ${QAWOLF_DIR}

RUN cd ${QAWOLF_DIR} && npm run bootstrap

# Set default env variables
ENV QAW_CHROME_EXECUTABLE_PATH="google-chrome-stable" \
    QAW_CHROME_OFFSET_Y=72 \
    QAW_DOCKER="true" \
    # for recording
    QAW_DISPLAY_HEIGHT=1080 \
    QAW_DISPLAY_WIDTH=1920 \ 
    QAW_HEADLESS="false" \
    QAW_SERIAL="true"

ENTRYPOINT ["/home/qawolf/entrypoint.sh"]

FROM circleci/ruby:2.5.1-node-browsers

USER root

# install Bundler
RUN gem install bundler -v 1.17.3 && \
    mkdir -p /usr/local/bundle && \
    chown -R circleci /usr/local/bundle

# install Imagemagick, etc.
RUN apt-get update
RUN apt-get install -y imagemagick libmagickcore-dev libmagickwand-dev libept-dev aptitude ghostscript

# install Android SDK
ARG sdk_version=sdk-tools-linux-4333796.zip
RUN wget https://dl.google.com/android/repository/${sdk_version} && \
    unzip -d /home/circleci/android-sdk ${sdk_version} && \
    rm -f ${sdk_version}.zip

ENV ANDROID_HOME /home/circleci/android-sdk
ENV PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/tools/bin64:$ANDROID_HOME/tools/lib:$ANDROID_HOME/tools/lib64:$ANDROID_HOME/tools/qemu/linux-x86_64
RUN mkdir ~/.android && echo '### User Sources for Android SDK Manager' > ~/.android/repositories.cfg

RUN yes | sdkmanager --licenses && yes | sdkmanager --update

# Update SDK manager and install system image, platform and build tools
RUN sdkmanager \
    "tools" \
    "platform-tools" \
    "emulator"

# install build tools APIs
RUN sdkmanager \
    "build-tools;23.0.2" \
    "build-tools;25.0.0" \
    "build-tools;25.0.1" \
    "build-tools;25.0.2" \
    "build-tools;25.0.3" \
    "build-tools;26.0.1" \
    "build-tools;26.0.2" \
    "build-tools;27.0.0" \
    "build-tools;27.0.1" \
    "build-tools;27.0.2" \
    "build-tools;27.0.3" \
    "build-tools;28.0.0" \
    "build-tools;28.0.1" \
    "build-tools;28.0.2" \
    "build-tools;28.0.3" \
    "build-tools;29.0.0" \
    "build-tools;29.0.1" \
    "build-tools;29.0.2"

RUN sdkmanager \
    "platforms;android-25" \
    "platforms;android-26" \
    "platforms;android-27" \
    "platforms;android-28"

RUN sdkmanager \
    "extras;android;m2repository" \
    "extras;google;m2repository" \
    "extras;google;google_play_services"

RUN rm -rf /usr/local/bin/node

RUN mkdir -p /usr/local/nvm
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 12.16.1

# Install nvm with node and npm
RUN curl https://raw.githubusercontent.com/creationix/nvm/v0.35.3/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

USER circleci
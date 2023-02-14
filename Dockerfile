# Build invocation:
# May need to be executed with --memory-swap -1 or else out of memory error
# docker build --memory-swap -1 . -t nztrain:latest

# Execution invocation:
# Privileged mode is required for control groups
# Must be invoked with '--network host' for port exposure
# docker run --privileged --network host -it nztrain:latest
# <C-p> <C-q> to detach

FROM ubuntu:xenial

# Services cannot be started within Docker build environment
RUN printf "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d
RUN apt-get update && apt-get install -y sudo git \
    libpq-dev software-properties-common curl locales

# Set locales for database
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
RUN echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen && locale-gen
RUN update-locale LANG=en_US.UTF-8

# Install RVM
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys \
    409B6B1796C275462A1703113804BB82D39DC0E3 \
    7D2BAF1CF37B13E2069D6956105BD0E739499BDB
RUN curl -L https://get.rvm.io | bash -s stable
ENV PATH="/usr/local/rvm/bin/:${PATH}"
SHELL ["/bin/bash", "-l", "-c"]

# Install Ruby 2.3.8
RUN rvm requirements
RUN rvm install 2.3.8
RUN gem install bundler --no-ri --no-rdoc

WORKDIR /nztrain
COPY script ./script
RUN bash script/install/maxmind.bash
RUN yes | bash script/install/imagemagick.bash

COPY config ./config
RUN RAILS_ENV=development DATABASE_USERNAME=root DATABASE=nztrain \
    TEST_DATABASE=nztraintest APP_NAME=nztrain USER=root \
    APP_USER=root UNICORN_PORT= REDIS_HOST=localhost REDIS_PORT=6379 \
    REDIS_PASS=@/etc/redis/redis.conf REDIS_INSTALL=true \
    SERVER_NAME=_ bash script/install/config.bash --defaults
# Avoid updating as database servers are not live yet
RUN yes | update=false bash script/install.bash

COPY Gemfile* ./
# Bundle installation is invoked in advance to avoid prompt 
RUN bundle install --deployment

COPY . .
RUN service postgresql start; \
    service redis start; \
    bash script/update.bash; \
    rm /var/run/redis/redis.pid; \
    service postgresql stop

CMD service redis start; \
    service postgresql start; \
    bundle exec rails server -d; \
    bundle exec rake qless:work


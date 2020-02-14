# Build invocation:
# May need to be executed with --memory-swap -1 or else out of memory error
# docker build --memory-swap -1 . -t nztrain:latest

# Execution invocation:
# Privileged mode is required for control groups
# Must be invoked with '--network host' for port exposure
# docker --privileged --network host -it nztrain:latest
# <C-p> <C-q> to detach

FROM drecom/ubuntu-ruby:2.3.8
RUN apt-get update && apt-get install -y sudo git libpq-dev software-properties-common
# Services cannot be started within Docker build environment
RUN printf "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d

WORKDIR /nztrain
COPY Gemfile* ./
COPY script ./script
RUN bash script/install/maxmind.bash

# Bundle installation is invoked in advance to avoid
# prompt at installation script
RUN bundle install --deployment

RUN RAILS_ENV=development DATABASE_USERNAME=root DATABASE=nztrain \
    TEST_DATABASE=nztraintest APP_NAME=nztrain USER=root \
    APP_USER=root UNICORN_PORT= REDIS_HOST=localhost REDIS_PORT=6379 \
    REDIS_PASS=@/etc/redis/redis.conf REDIS_INSTALL=true \
    SERVER_NAME=_ bash script/install/config.bash --defaults

COPY config ./config
# Avoid updating as database servers are not live yet
RUN yes | update=false bash script/install.bash

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


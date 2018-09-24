FROM alpine:3.6 as builder

ADD https://releases.hashicorp.com/envconsul/0.6.2/envconsul_0.6.2_linux_amd64.tgz /tmp/envconsul.tgz
RUN tar -xvzf /tmp/envconsul.tgz -C /usr/local/bin/

FROM ruby:2.4.2-alpine3.6

# Set your workdir
WORKDIR /app

# Install all the dependency
COPY --from=builder /usr/local/bin/envconsul /usr/local/bin/
COPY Gemfile Gemfile.lock /app/
RUN apk update && apk upgrade && apk add --no-cache git \
    && apk add --no-cache --virtual sqlite-dev sqlite3-dev \
    && apk add --no-cache --virtual build-base build-dependencies

# Add service
COPY . /app

# Expose your service port
EXPOSE 1234

# Add all web to PATH
ENV PATH "$PATH:/app/web"

# Set your entrypoint here just to start the webserver such as puma
ENTRYPOINT ["web"]

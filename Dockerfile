FROM alpine:3.8

RUN apk add --update \
    bash \
    git \
    curl \
    build-base \
    readline-dev \
    openssl-dev \
    zlib-dev \
    linux-headers \
    imagemagick-dev \
    libffi-dev \
    libffi-dev \
&& rm -rf /var/cache/apk/*

# rbenv
ENV PATH /usr/local/rbenv/shims:/usr/local/rbenv/bin:$PATH
ENV RBENV_ROOT /usr/local/rbenv
ENV CONFIGURE_OPTS --disable-install-doc

RUN git clone --depth 1 https://github.com/rbenv/rbenv.git ${RBENV_ROOT} \
&&  git clone --depth 1 https://github.com/rbenv/ruby-build.git ${RBENV_ROOT}/plugins/ruby-build \
&& ${RBENV_ROOT}/plugins/ruby-build/install.sh

RUN echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh 

ENV RUBY_VERSION 1.9.3-p551
ENV BUNDLER_VERSION 1.17.3

# Upgrade patch to version busybox-1.29.3-r10, required to apply the ruby compile patch below.
RUN apk add busybox=1.29.3-r10 --repository=http://dl-cdn.alpinelinux.org/alpine/v3.9/main/

# Include FIX to build ruby 1.9.3 (see https://github.com/ruby/ruby/pull/1485).
RUN curl https://patch-diff.githubusercontent.com/raw/ruby/ruby/pull/1485.patch -o /tmp/ruby_compile_fix.patch \
&& rbenv install --patch $RUBY_VERSION < /tmp/ruby_compile_fix.patch \
&& rbenv global $RUBY_VERSION \
&& gem install --no-rdoc --no-ri bundler -v $BUNDLER_VERSION \
&& rbenv rehash

# Add files
COPY docker-entrypoint.sh /

# CMD
ENTRYPOINT ["/docker-entrypoint.sh"]
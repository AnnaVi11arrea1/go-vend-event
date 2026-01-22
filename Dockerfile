# Use Ruby 3.3.4 as base image
FROM ruby:3.3.4-slim

# Install system dependencies
RUN apt-get update -qq && apt-get install -yq --no-install-recommends \
    build-essential \
    curl \
    gettext \
    git \
    libpq-dev \
    libsqlite3-dev \
    libvips \
    postgresql-client \
    sudo \
    unzip \
    wget \
    zip \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Node.js (v20)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g yarn \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create a non-root user 'dev'
RUN useradd -m -s /bin/bash dev \
    && echo "dev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set up work directory
WORKDIR /workspaces/go-vend-event
RUN chown -R dev:dev /workspaces/go-vend-event

USER dev

# Set environment variables
ENV BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3

# Add useful aliases
RUN echo "alias be='bundle exec'" >> ~/.bash_aliases \
    && echo "alias g='git status'" >> ~/.bash_aliases \
    && echo "alias rails='bundle exec rails'" >> ~/.bash_aliases

# Ensure bin/rails etc are executable
RUN mkdir -p bin && chmod +x bin/* 2>/dev/null || true

EXPOSE 3000

CMD ["bash"]

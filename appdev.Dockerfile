FROM ruby:3.4.4-bullseye

ENV DEBIAN_FRONTEND=noninteractive LANG=en_US.UTF-8

WORKDIR /rails-template

# Install system dependencies
RUN apt-get update && apt-get install -yq \
    curl wget acl zip unzip bash-completion build-essential jq locales \
    software-properties-common libpq-dev sudo git graphviz psmisc \
    redis-server postgresql-client gnupg ca-certificates \
    && locale-gen en_US.UTF-8 \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/*

# Install Node.js 18 and Yarn
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update && apt-get install -y yarn \
    && npm install -g n && n 18 && hash -r \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Bundler 2.5.23
RUN gem install bundler:2.5.23 --no-document

# Pre-install gems
COPY Gemfile Gemfile.lock /rails-template/
RUN bundle install

# Create container user
RUN useradd -l -u 33334 -G sudo -md /home/student -s /bin/bash -p student student \
    && sed -i.bkp -e 's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' /etc/sudoers

# Ensure the non-root user can write SQLite DB files and runtime tmp files.
RUN chown -R student:student /rails-template

USER student
ENV HOME=/home/student

# Setup shell
RUN mkdir -p $HOME/.bashrc.d \
    && (echo; echo "for i in \$(ls \$HOME/.bashrc.d/* 2>/dev/null); do source \$i; done"; echo) >> $HOME/.bashrc

# Setup PostgreSQL directories
RUN mkdir -p ~/.pg_ctl/bin ~/.pg_ctl/sockets

# Configure git
RUN git config --global push.default upstream \
    && git config --global merge.ff only \
    && git config --global alias.aa '!git add -A' \
    && git config --global alias.cm '!f(){ git commit -m "${*}"; };f' \
    && git config --global alias.acm '!f(){ git add -A && git commit -am "${*}"; };f' \
    && git config --global alias.as '!git add -A && git stash' \
    && git config --global alias.p 'push' \
    && git config --global alias.sla 'log --oneline --decorate --graph --all' \
    && git config --global alias.co 'checkout' \
    && git config --global alias.cob 'checkout -b' \
    && git config --global --add --bool push.autoSetupRemote true \
    && git config --global core.editor "code --wait"

# Setup bash aliases
RUN echo "alias be='bundle exec'" >> ~/.bash_aliases \
    && echo "alias grade='rake grade'" >> ~/.bash_aliases \
    && echo "alias grade:reset_token='rake grade:reset_token'" >> ~/.bash_aliases \
    && echo 'export PATH="$PWD/bin:$PATH"' >> ~/.bashrc

# Setup git completion and g alias
RUN echo "g() { if [[ \$# > 0 ]]; then git \$@; else git status; fi; }" >> ~/.bashrc \
    && echo "source /usr/share/bash-completion/completions/git 2>/dev/null" >> ~/.bashrc

# Copy app source after dependency install to preserve Docker layer caching.
COPY --chown=student:student . /rails-template

EXPOSE 3000

CMD ["bash", "-lc", "bundle exec rails db:prepare && bundle exec rails server -b 0.0.0.0 -p 3000"]

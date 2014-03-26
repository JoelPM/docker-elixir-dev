# Use phusion/baseimage as base image. To make your builds
# reproducible, make sure you lock down to a specific version, not
# to `latest`! See
# https://github.com/phusion/baseimage-docker/blob/master/Changelog.md
# for a list of version numbers.
FROM phusion/baseimage:0.9.9

MAINTAINER Joel Meyer, joel.meyer@gmail.com

# Set correct environment variables.
ENV HOME /root

# Regenerate SSH host keys. baseimage-docker does not contain any, so you
# have to do that yourself. You may also comment out this instruction; the
# init system will auto-generate one during boot.
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

# Install erlang solutions repo
RUN curl -O http://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb
RUN dpkg -i erlang-solutions_1.0_all.deb

# Remove default vim
RUN apt-get remove -y vim vim-runtime vim-tiny vim-common

# Install required packages 
# build-essential      # general
# autotools-dev        # general
# automake             # general
# man                  # general, git, tmux
# pkg-config           # tmux
# libevent-dev         # tmux
# libncurses-dev       # tmux, vim
# libssl-dev           # git
# libcurl4-openssl-dev # git
# libexpat1-dev        # git
# gettext              # git
RUN apt-get update
RUN apt-get install -y build-essential autotools-dev automake man pkg-config libevent-dev libncurses-dev libssl-dev libcurl4-openssl-dev libexpat1-dev gettext

# Install zsh 5.0.5
RUN mkdir /opt/zsh
RUN cd /opt/zsh && curl -L -o zsh-5.0.5.tar.bz2 -O http://sourceforge.net/projects/zsh/files/zsh/5.0.5/zsh-5.0.5.tar.bz2/download
RUN cd /opt/zsh && curl -L -o zsh-5.0.5-doc.tar.bz2 -O http://sourceforge.net/projects/zsh/files/zsh-doc/5.0.5/zsh-5.0.5-doc.tar.bz2/download
RUN cd /opt/zsh && tar -jxf zsh-5.0.5.tar.bz2
RUN cd /opt/zsh && tar -jxf zsh-5.0.5-doc.tar.bz2
RUN cd /opt/zsh/zsh-5.0.5 && ./configure --prefix=/usr/local --with-tcsetpgrp && make && make install
RUN echo "/usr/local/bin/zsh" | tee -a /etc/shells
RUN chsh -s /usr/local/bin/zsh

# Install tmux 1.9a
RUN mkdir /opt/tmux
RUN cd /opt/tmux && curl -L -O http://downloads.sourceforge.net/tmux/tmux-1.9a.tar.gz && tar xzf tmux-1.9a.tar.gz
RUN cd /opt/tmux/tmux-1.9a && ./configure && make && make install

# Install vim 7.4
RUN mkdir /opt/vim
RUN cd /opt/vim && curl -L -O ftp://ftp.vim.org/pub/vim/unix/vim-7.4.tar.bz2 && tar xjf vim-7.4.tar.bz2
RUN cd /opt/vim/vim74/ && ./configure --prefix=/usr/local --with-features=huge --enable-cscope && make && make install
RUN update-alternatives --install /usr/bin/editor editor /usr/local/bin/vim 1
RUN update-alternatives --set editor /usr/local/bin/vim
RUN update-alternatives --install /usr/bin/vi vi /usr/local/bin/vim 1
RUN update-alternatives --set vi /usr/local/bin/vim

# Install git
RUN mkdir /opt/git
RUN cd /opt/git && curl -O https://git-core.googlecode.com/files/git-1.9.0.tar.gz && tar xzf git-1.9.0.tar.gz
RUN cd /opt/git/git-1.9.0 && make prefix=/usr/local install
RUN cd /opt/git && curl -O https://git-core.googlecode.com/files/git-manpages-1.9.0.tar.gz && tar xz -C /usr/local/share/man -f git-manpages-1.9.0.tar.gz

# Install erlang 
RUN apt-get install -y erlang

# Install elixir
RUN mkdir /opt/elixir
RUN cd /opt/elixir && curl -L -O https://github.com/elixir-lang/elixir/archive/v0.12.5.tar.gz && tar xzf v0.12.5.tar.gz
RUN cd /opt/elixir/elixir-0.12.5 && make && make install

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# ...put your own build instructions here...

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

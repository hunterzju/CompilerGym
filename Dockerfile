FROM ubuntu:22.04

RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*

RUN  cp -a /etc/apt/sources.list /etc/apt/sources.list.bak

RUN sed -i "s@http://.*archive.ubuntu.com@http://mirrors.huaweicloud.com@g" /etc/apt/sources.list
RUN sed -i "s@http://.*security.ubuntu.com@http://mirrors.huaweicloud.com@g" /etc/apt/sources.list

# RUN apt-get update
# RUN apt-get install -y clang clang-format golang libjpeg-dev libtinfo5 m4 make patch zlib1g-dev tar bzip2 wget

# Setup the terminal to use color
ENV TERM=xterm-256color
# Create a user account in the docker container that is based on the account of the executor
# This will be dependent on the docker build command passing in the user_name and user_id that
# the container will be executed as.
ARG user_name
ARG user_id
RUN useradd --uid ${user_id} --shell /bin/bash --create-home --user-group ${user_name}
#RUN chpasswd && adduser ${user_name} sudo
#RUN echo ${user_name}':'${user_name} | chpasswd
RUN echo ${user_name}' ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN usermod -aG sudo ${user_name}
USER ${user_name}
WORKDIR /home/${user_name}
RUN chown -R ${user_name} /home/${user_name}

# for compiler gym install
RUN mkdir -pv ~/.local/bin
RUN wget https://github.com/bazelbuild/bazelisk/releases/download/v1.7.5/bazelisk-linux-amd64 -O ~/.local/bin/bazel
RUN wget https://github.com/hadolint/hadolint/releases/download/v1.19.0/hadolint-Linux-x86_64 -O ~/.local/bin/hadolint
RUN chmod +x ~/.local/bin/bazel ~/.local/bin/hadolint
RUN go install github.com/bazelbuild/buildtools/buildifier@latest
RUN GO111MODULE=on go install github.com/uber/prototool/cmd/prototool@dev
RUN export PATH="$HOME/.local/bin:$PATH"
RUN export CC=clang
RUN export CXX=clang++

# Create a directory to map to external host
VOLUME /home/${user_name}/workspace
# Change the working dir
WORKDIR /home/${user_name}/workspace

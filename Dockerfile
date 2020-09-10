FROM ubuntu:focal

# unminimize
ENV DEBIAN_FRONTEND=noninteractive
RUN yes | unminimize

# utf-8 locale
RUN apt-get update \
    && apt-get install -qq locales \
    && locale-gen en_US en_US.UTF-8 \
    && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8

# add ros sources
RUN apt-get install -qq curl gnupg2 lsb-release \
    && curl -fsSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add - \
    && sh -c 'echo "deb [arch=$(dpkg --print-architecture)] http://packages.ros.org/ros/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros-latest.list' \
    && sh -c 'echo "deb [arch=$(dpkg --print-architecture)] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2-latest.list' \
    && apt-get update

# install ros 1
RUN apt-get install -qq ros-noetic-desktop ros-noetic-rosbridge-suite

# install ros 2
RUN apt-get install -qq ros-foxy-desktop

# install node.js
RUN curl -fsSL https://deb.nodesource.com/setup_12.x | bash - \
    && apt-get install -y nodejs

# install openssh-server
RUN apt-get install -qq openssh-server \
    && mkdir /var/run/sshd

# install some more useful things
RUN apt-get install -qq \
    dnsutils \
    dumb-init \
    iputils-ping \
    less \
    mesa-utils \
    mlocate \
    python-is-python3 \
    python3-argcomplete \
    silversearcher-ag \
    sudo \
    tmux \
    vim

ENV DEBIAN_FRONTEND=
ENV DISPLAY=host.docker.internal:0

RUN echo "\nexport DISPLAY=\${DISPLAY:-$DISPLAY}" >> /etc/skel/.bashrc \
    && echo "\nsource /opt/ros/noetic/setup.bash  # ros1" >> /etc/skel/.bashrc \
    && echo "# source /opt/ros/foxy/setup.bash  # ros2" >> /etc/skel/.bashrc

# create unprivileged user
RUN useradd -m -s /bin/bash ubuntu \
    && echo "ubuntu ALL=(ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/ubuntu \
    && mkdir -p -m 700 /home/ubuntu/.ssh \
    && chown -R ubuntu:ubuntu /home/ubuntu/.ssh

COPY bin/docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["/usr/bin/dumb-init", "--", "docker-entrypoint.sh"]

RUN updatedb
CMD ["/usr/sbin/sshd", "-D"]

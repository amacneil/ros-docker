FROM ubuntu

# utf-8 locale
RUN apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -qq locales \
	&& locale-gen en_US en_US.UTF-8 \
	&& update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8

# add ros 2 sources
RUN DEBIAN_FRONTEND=noninteractive apt-get install -qq curl gnupg2 lsb-release \
	&& curl -fsSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc \
		| apt-key add - \
	&& sh -c 'echo "deb [arch=$(dpkg --print-architecture)] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2-latest.list' \
	&& apt-get update

# install ros 2
RUN DEBIAN_FRONTEND=noninteractive apt-get install -qq ros-foxy-desktop

# install more stuff
RUN DEBIAN_FRONTEND=noninteractive apt-get install -qq \
		python3-pip \
		sudo \
	&& pip3 install -U argcomplete

# unprivileged user
RUN useradd -m ubuntu \
	&& echo "ubuntu ALL=(ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/ubuntu \
	&& echo "\nsource /opt/ros/foxy/setup.bash" >> /home/ubuntu/.bashrc

USER ubuntu

# Melodic includes OpenCV 3.2 and the install seems to fail try Noetic at 4.2
#FROM ros:melodic
FROM ros:noetic
LABEL maintainer="dev@netdron.es"

# Use bash
SHELL ["/bin/bash", "-c"]

#ENV ROS_DISTRO melodic
ENV ROS_DISTRO noetic

# remember workdir will do a mkdir -p to create it.C
WORKDIR /workspace

# https://docs.docker.com/buildx/working-with-buildx/
ARG TARGETPLATFORM
ARG BUILDPLATFORM

# install ros-melodic-desktop-full
# so no way to pin with different versions
# linux/amd64 version is 1.5.0-1focal.20220512.132246
# linux/arm64 version is 1.5.0-1focal.20220512.135058
# hadolint ignore=DL3008
RUN apt-get update && \
    VERSION="1.5.0-1focal.20220512.13$([[ $TARGETPLATFORM == "linux/arm64" ]] \
        && echo 5058 || echo 2246)" && \
    apt-get install --no-install-recommends -y \
        "ros-${ROS_DISTRO}-desktop-full=$VERSION" \
    && rm -rf /var/lib/apt/lists/*

# install bootstrap tools
# Python 3 only supported
# https://docs.ros.org/en/dashing/Guides/Using-Python-Packages.html
        #python-rosdep \
        #python-rosinstall \
        #python-rosinstall-generator \
        #python-wstool
RUN apt-get update && apt-get install --no-install-recommends -y \
        build-essential=12.8ubuntu1.1 \
        python3-rosinstall=0.7.8-4 \
        python3-rosinstall-generator=0.1.22-1 \
        python3-wstool=0.1.18-2 \
        python3-pip=20.0.2-5ubuntu1.6 \
    && rm -rf /var/lib/apt/lists/*

# ORB pre-requisites: eigen, blas, lapack and opencv 4.5
# install Eigen
RUN apt-get install -y --no-install-recommends \
        libeigen3-dev=3.3.7-2 \
    && rm -rf /var/lib/apt/lists/*
# install BLAS, LAPACK
RUN apt-get install -y --no-install-recommends \
        libblas-dev=3.9.0-1build1 \
        liblapack-dev=3.9.0-1build1 \
    && rm -rf /var/lib/apt/lists/*

# install Pangolin old instructions for python 2.7 melodic
#RUN apt-get update && apt-get install -y \
#    libglew-dev \
#    cmake \
#    libboost-dev libboost-thread-dev libboost-filesystem-dev \
    #libpython2.7-dev
    #&& mkdir -p Pangolin/build && \
    #&& cd Pangolin/build \
    #&& cmake -DCPP11_NO_BOOST=1 .. \
    #&& make
# tools for Pangolin
# instructions from Pangolin as of June 2022 does not work with c11
RUN apt-get update && apt-get install --no-install-recommends -y \
        git=1:2.25.1-1ubuntu3.4 \
    && rm -rf /var/lib/apt/lists/*
#RUN git clone --branch rich-pang --recursive https://github.com/netdrones/Pangolin.git
RUN git clone --recursive --branch v0.8-rich https://github.com/netdrones/Pangolin.git
# instructions from Pangolin as of June 2022 uses the default c compiler in
# 20.04 and not the c11 compiler
# install_prerequisites.sh -u needs a -y
RUN ./Pangolin/scripts/install_prerequisites.sh -u && \
    ./Pangolin/scripts/install_prerequisites.sh recommended
WORKDIR /workspace/Pangolin
RUN cmake -B build && \
    cmake --build build && \
    cmake --build build -t pypangolin_pip_install

# this does not work opencv is only 4.2 and 4.4 is required
#RUN apt-get install --no-install-recommends -y \
#    libopencv-dev=4.2.0+dfsg-5 \
# this causes a break in docker cache so do as late as possible
# https://docs.opencv.org/4.x/d7/d9f/tutorial_linux_install.html
# build 4.5 from source
# use the C++11 version instead
# use curl instead of wget as this is more broadly used and hadolint just wants
# one of these
    #wget -nv -O opencv.zip https://github.com/opencv/opencv/archive/4.5.0.zip && \
        #wget=1.20.3-1ubuntu2 \
WORKDIR /workspace
RUN apt-get update && apt-get install -y --no-install-recommends \
        cmake=3.16.3-1ubuntu1 \
        curl=7.68.0-1ubuntu2.11 \
        g++=4:9.3.0-1ubuntu2 \
        unzip=6.0-25ubuntu1 \
    && rm -rf /var/lib/apt/lists/* && \
    curl -L -o opencv.zip https://github.com/opencv/opencv/archive/4.5.0.zip && \
    unzip opencv.zip

WORKDIR /workspace/build
RUN cmake ../opencv-4.5.0 && \
    cmake --build . && \
    make install

# opencv dows not compile with gcc-11 but orb_slam3 requires it
# https://lindevs.com/install-gcc-on-ubuntu/
# install dependencies for orbslam3 must be C++11 but the default
# c++-9 versions do not compile orb_slam3
        #gcc=4:9.3.0-1ubuntu2 \
        #g++=4:9.3.0-1ubuntu2 \
# arm64 0.99.9.8 software-properties-common
# amd64 0.98.9 software-properties-common does not work forced update
# https://gist.github.com/yunqu/0cc6347905f73b7448898f50484e77b3
# to set gcc-11 as the default and leave gcc-9 as backup
# https://askubuntu.com/questions/1023/how-to-set-gcc-as-the-default-compiler-for-c-and-c-plus-plus
# arm and amd64 use the same version
#RUN VERSION="$([[ $TARGETPLATFORM == "linux/arm64" ]] \
#        && echo 0.98.9 || echo 0.99.9.8)" && \
RUN VERSION="0.99.9.8" && \
    apt-get update && apt-get install --no-install-recommends -y \
        software-properties-common="$VERSION" \
    && \
    apt-add-repository -y ppa:ubuntu-toolchain-r/test && \
    apt-get install --no-install-recommends -y \
       gcc-11=11.1.0-1ubuntu1~20.04 \
       g++-11=11.1.0-1ubuntu1~20.04 \
    && rm -rf /var/lib/apt/lists/* && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 100 \
       --slave /usr/bin/g++ g++ /usr/bin/g++-11 \
       --slave /usr/bin/gcov gcov /usr/bin/gcov-11 && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 50 \
       --slave /usr/bin/g++ g++ /usr/bin/g++-9 \
       --slave /usr/bin/gcov gcov /usr/bin/gcov-9


# brew needs a regular user so here is the code to create one
# https://hiberstack.com/questions/question/how-to-provide-sudo-permission-to-a-user-in-dockerfile/
# Provide root privileges to this user
#RUN useradd -ms /bin/bash orb && \
#    usermod -aG sudo orb && \
#    set the password trivial for orb to orb
#    echo "orb:orb" | chpasswd && \
#    add user to the sudo group
#    usermod -aG sudo orb

# install homebrew https://brew.sh
#USER orb
#WORKDIR /home/orb
#RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && \
#    test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)" && \
#    test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" && \
#    test -r ~/.bash_profile && echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.bash_profile && \
#    echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.profile

WORKDIR /workspace
RUN git clone https://github.com/UZ-SLAMLab/ORB_SLAM3.git --branch v1.0-release
#RUN    ./build.sh

CMD ["/bin/bash"]

# Melodic includes OpenCV 3.2 and the install seems to fail try Noetic at 4.2
#FROM ros:melodic
FROM ros:noetic

#ENV ROS_DISTRO melodic
ENV ROS_DISTRO noetic

RUN mkdir workspace
WORKDIR /workspace

# install ros-melodic-desktop-full
RUN apt-get update && apt-get install --no-install-recommends -y \
        ros-${ROS_DISTRO}-desktop-full=1.5.0-1focal.20220512.135058 \
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

# install dependencies for orbslam3
RUN apt-get update && apt-get install --no-install-recommends -y \
        gcc=4:9.3.0-1ubuntu2 \
        g++=4:9.3.0-1ubuntu2 \
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
# instructions from Pangolin as of June 2022
RUN apt-get update && apt-get install --no-install-recommends -y \
        git=1:2.25.1-1ubuntu3.4 \
    && rm -rf /var/lib/apt/lists/*

#RUN git clone --branch rich-pang --recursive https://github.com/netdrones/Pangolin.git
RUN git clone --recursive https://github.com/netdrones/Pangolin.git

# instructions from Pangolin as of June 2022
# install_prerequisites.sh -u needs a -y
RUN ./Pangolin/scripts/install_prerequisites.sh -u && \
    ./Pangolin/scripts/install_prerequisites.sh recommended

WORKDIR /workspace/Pangolin
RUN cmake -B build && \
    cmake --build build && \
    cmake --build build -t pypangolin_pip_install

# install Opencv only for 4.2 so do not use and hand install
#RUN apt-get install --no-install-recommends -y \
#    libopencv-dev=4.2.0+dfsg-5 \

# https://docs.opencv.org/4.x/d7/d9f/tutorial_linux_install.html
# build 4.5 from source
WORKDIR /workspace
RUN apt-get update && apt-get install -y --no-install-recommends \
        cmake=3.16.3-1ubuntu1 \
        g++=4:9.3.0-1ubuntu2 \
        wget=1.20.3-1ubuntu2 \
        unzip=6.0-25ubuntu1 \
    && rm -rf /var/lib/apt/lists/* && \
    wget -nv -O opencv.zip https://github.com/opencv/opencv/archive/4.5.0.zip && \
    unzip opencv.zip && \
    mkdir -p build

WORKDIR /workspace/build
RUN cmake ../opencv-4.5.0 && \
    cmake --build . && \
    make install

# install Eigen
RUN apt-get install -y --no-install-recommends \
        libeigen3-dev=3.3.7-2 \
    && rm -rf /var/lib/apt/lists/*

# install BLAS, LAPACK
RUN apt-get install -y --no-install-recommends \
        libblas-dev=3.9.0-1build1 \
        liblapack-dev=3.9.0-1build1 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
RUN git clone https://github.com/UZ-SLAMLab/ORB_SLAM3.git

WORKDIR /workspace/ORB_SLAM3
RUN    ./build.sh

CMD ["/bin/bash"]

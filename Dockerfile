# Melodic includes OpenCV 3.2 and the install seems to fail try Noetic at 4.2
#FROM ros:melodic
FROM ros:noetic

#ENV ROS_DISTRO melodic
ENV ROS_DISTRO noetic

RUN mkdir workspace
WORKDIR /workspace

# install ros-melodic-desktop-full
RUN apt-get update && apt-get install -y \
    ros-${ROS_DISTRO}-desktop-full \
    && rm -rf /var/lib/apt/lists/*


# install bootstrap tools 
# Python 3 only supported 
# https://docs.ros.org/en/dashing/Guides/Using-Python-Packages.html
    #python-rosdep \
    #python-rosinstall \
    #python-rosinstall-generator \
    #python-wstool
RUN apt-get update && apt-get install --no-install-recommends -y \
    build-essential \
    python3-rosinstall \
    python3-rosinstall-generator \
    python3-wstool \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# install dependencies for orbslam3
RUN apt-get update && apt-get install gcc g++

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
RUN apt-get update && apt-get install -y \
    git \
    && rm -rf /var/lib/apt/lists/*
#RUN git clone --branch rich-pang --recursive https://github.com/netdrones/Pangolin.git
RUN git clone --recursive https://github.com/netdrones/Pangolin.git

# instructions from Pangolin as of June 2022
# install_prerequisites.sh -u needs a -y
RUN ./Pangolin/scripts/install_prerequisites.sh -u && \
    ./Pangolin/scripts/install_prerequisites.sh recommended

RUN cd Pangolin && \
    cmake -B build && \
    cmake --build build && \
    cmake --build build -t pypangolin_pip_install

# install Opencv only for 4.2
RUN apt-get install -y \
    libopencv-dev

# https://docs.opencv.org/4.x/d7/d9f/tutorial_linux_install.html
# build 4.5 from source
RUN apt-get update && apt-get install -y \
        cmake \
        g++ \
        wget \
        unzip && \
    wget -O opencv.zip https://github.com/opencv/opencv/archive/4.5.0.zip && \
    unzip opencv.zip && \
    mkdir -p build && \
    cd build && \
    cmake ../opencv-4.5.0 && \
    cmake --build . && \
    sudo make install



# install Eigen
RUN apt-get install -y \
    libeigen3-dev

# install BLAS, LAPACK
RUN apt-get install -y \
    libblas-dev \
    liblapack-dev

#RUN git clone https://github.com/UZ-SLAMLab/ORB_SLAM3.git && \
#    cd ORB_SLAM3  && \
#    sh ./build.sh

CMD ["/bin/bash"]

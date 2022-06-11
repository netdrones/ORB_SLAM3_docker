# ORB_SLAM3_docker

An error was encountered while building ORBSLAM3.

I was able to fix the error when ROS was installed before installing it and
somehow dependencies were accomplished this was original done for ORB-SLAM3
v0.3

[richtong](https://github.com/richtong) updated this to ORB-SLAM3 v1.0 shipped
in December 2021 bumping:

1. ROS Melodic to Noetic
1. OpenCV from 3.x to 4.5 with 4.4 the minimum required
1. Pangolin instructions changed as well
1. Removed the raw source code since this should really be a submodule if it is
   needed
1. Added link to Makefile helper functions at [NetDrones
   Lib](https://github.com/netdrones/lib)

Original Code from [https://github.com/UZ-SLAMLab/ORB_SLAM3](https://github.com/UZ-SLAMLab/ORB_SLAM3)

## Installation Pre-requirement

To install the system, you need either. The installation for ORB-SLAM3 v1 was tested on a MacBook
M1 only.

1. docker or equivalent. Not tested with limactl but it should work
1. nvidia docker. If you have a nVidia GPU

## Installation ORBSLAM3 with dockerfile

Run build_docker.sh or run `make build`

```bash
chmod +x build_docker.sh
./build_docker.sh
```

### Run container with the created image file

Make gui visibla from docker container

```bash
sudo apt-get install x11-xserver-utils
xhost +
```

Run container if you are on bare Linux and have a GPU

```bash
docker run --gpus all -it --ipc=host --net=host \
            --privileged -e DISPLAY=unix$DISPLAY \
            -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
            -e NVIDIA_DRIVER_CAPABILITIES=all \
            --name orbslam-test orbslam3:latest /bin/bash
```

## Run ORB_SLAM3

An example of monocular-inertial dataset

```bash
./Examples/Monocular-Inertial/mono_inertial_tum_vi Vocabulary/ORBvoc.txt \
    Examples/Monocular-Inertial/TUM_512.yaml \
    "$pathDatasetTUM_VI"/dataset-slides1_512_16/mav0/cam0/data \
    Examples/Monocular-Inertial/TUM_TimeStamps/dataset-slides1_512.txt \
    Examples/Monocular-Inertial/TUM_IMU/dataset-slides1_512.txt \
    dataset-slides1_512_monoi
```

## References

For ROS installation

[https://github.com/JaciBrunning/docker-ros/blob/master/melodic/Dockerfile](https://github.com/JaciBrunning/docker-ros/blob/master/melodic/Dockerfile)

For ORBSLAM3 installation

[https://github.com/proudh/docker-orb-slam2-build/blob/master/Dockerfile](https://github.com/proudh/docker-orb-slam2-build/blob/master/Dockerfile)

[https://blog.csdn.net/qq_38191370/article/details/107633218](https://blog.csdn.net/qq_38191370/article/details/107633218)

For creating a container with gui available

[https://hub.docker.com/r/celinachild/orbslam2](https://hub.docker.com/r/celinachild/orbslam2)

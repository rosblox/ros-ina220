ARG ROS_DISTRO

FROM ros:${ROS_DISTRO}-ros-core

RUN apt update && apt install -y --no-install-recommends python3-pip python3-colcon-common-extensions python3-smbus && rm -rf /var/lib/apt/lists/*

# RUN pip3 install adafruit-circuitpython-ina220


COPY ina220-python ina220-python
RUN cd ina220-python/library && python3 setup.py install

WORKDIR /colcon_ws/src
COPY ros_ina220 .

WORKDIR /colcon_ws

RUN . /opt/ros/${ROS_DISTRO}/setup.sh && colcon build --symlink-install

WORKDIR /

COPY ros_entrypoint.sh .

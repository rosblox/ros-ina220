ARG ROS_DISTRO=humble

FROM ros:${ROS_DISTRO}-ros-core

RUN apt update && apt install -y --no-install-recommends python3-pip python3-colcon-common-extensions python3-smbus && rm -rf /var/lib/apt/lists/*

# RUN pip3 install adafruit-circuitpython-ina220

COPY ros_entrypoint.sh .

COPY ina220-python ina220-python
RUN cd ina220-python/library && python3 setup.py install

WORKDIR /colcon_ws
COPY ros_ina220 src/ros_ina220

RUN . /opt/ros/${ROS_DISTRO}/setup.sh && \
    colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release --event-handlers console_direct+

ENV LAUNCH_COMMAND='ros2 run ros_ina220 ros_ina220_publisher'

# Create build and run aliases
RUN echo 'alias build="colcon build --symlink-install  --cmake-args -DCMAKE_BUILD_TYPE=Release --event-handlers console_direct+ "' >> /etc/bash.bashrc && \
    echo 'alias run="su - ros --whitelist-environment=\"ROS_DOMAIN_ID\" /run.sh"' >> /etc/bash.bashrc && \
    echo "source /colcon_ws/install/setup.bash; echo UID: $UID; echo ROS_DOMAIN_ID: $ROS_DOMAIN_ID; $LAUNCH_COMMAND" >> /run.sh && chmod +x /run.sh

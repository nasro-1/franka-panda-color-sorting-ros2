FROM osrf/ros:humble-desktop-full

ENV ROS_WS=/root/panda_ws
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /root

# ROS 2 / MoveIt 2 development dependencies
RUN apt update && apt install -y \
    git \
    python3-rosdep \
    python3-colcon-common-extensions \
    python3-pip \
    ros-humble-moveit \
    ros-humble-moveit-common \
    ros-humble-moveit-ros-move-group \
    ros-humble-moveit-ros-planning \
    ros-humble-moveit-ros-planning-interface \
    ros-humble-moveit-visual-tools \
    ros-humble-moveit-configs-utils \
    ros-humble-moveit-setup-assistant \
    && rm -rf /var/lib/apt/lists/*

# Python dependencies used by the supplied vision node
RUN pip3 install --no-cache-dir \
    opencv-python==4.10.0.84 \
    numpy==1.24.4 \
    transforms3d

RUN rosdep update --rosdistro=humble

# Build the repository that is being cloned/copied, not a hard-coded upstream fork.
RUN mkdir -p $ROS_WS/src
WORKDIR $ROS_WS/src
COPY . .

WORKDIR $ROS_WS
RUN rosdep install --from-paths src -y --ignore-src --skip-keys=opencv_python --rosdistro=humble
RUN . /opt/ros/humble/setup.sh && colcon build

RUN echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc && \
    echo "source $ROS_WS/install/setup.bash" >> ~/.bashrc

CMD ["/bin/bash"]

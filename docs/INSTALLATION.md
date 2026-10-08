# Installation Checklist

## Recommended environment

- Ubuntu 22.04
- ROS 2 Humble
- Gazebo / `ros_gz`
- MoveIt 2
- Python 3
- OpenCV
- NumPy
- transforms3d

## Native installation

```bash
mkdir -p ~/panda_ws/src
cd ~/panda_ws/src
git clone https://github.com/<YOUR_USERNAME>/<YOUR_REPOSITORY>.git Franka_Panda_Color_Sorting_Robot
cd ~/panda_ws
source /opt/ros/humble/setup.bash
rosdep update
rosdep install --from-paths src --ignore-src -r -y --skip-keys=opencv_python
python3 -m pip install --user opencv-python==4.10.0.84 numpy==1.24.4 transforms3d
colcon build --symlink-install
source install/setup.bash
```

## Run

Terminal 1:

```bash
source ~/panda_ws/install/setup.bash
ros2 launch panda_bringup pick_and_place.launch.py
```

Terminal 2:

```bash
source ~/panda_ws/install/setup.bash
ros2 run pymoveit2 pick_and_place.py --ros-args -p target_color:=R
```

Use `G` or `B` for the other colors.

## Docker

```bash
docker build -t franka-panda-color-sorting:humble .
xhost +local:docker
docker run -it --rm \
  --name franka_panda_color_sorter \
  --network host \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
  franka-panda-color-sorting:humble
```

# 🤖 Franka Panda Color Sorting Robot — ROS 2

A ROS 2 simulation of an autonomous **Franka Panda 7-DOF pick-and-place color-sorting system**. The supplied project combines:

- **Gazebo** for robot/environment simulation
- **URDF/Xacro** for the Panda robot model
- **ros2_control** for arm and gripper controllers
- **MoveIt 2** for inverse kinematics, motion planning and trajectory execution
- **OpenCV** for RGB color detection through HSV segmentation
- **TF2** for camera-frame → robot-base coordinate transformation
- **PyMoveIt2** for Python-based manipulation
- **RViz 2** for robot state and planning visualization
- **Docker** for a reproducible ROS 2 Humble environment

The accompanying project presentation describes the same architecture: ROS 2 workspace/package structure, URDF/DH modeling, Gazebo physics, controllers, MoveIt 2, camera calibration, HSV detection, pixel-to-3D projection and TF2 integration. fileciteturn0file0L6-L22

> **Important:** This repository is based on the supplied project archive. Before making the repository public, preserve the original attribution and verify the redistribution/licensing status of the source code and bundled robot/scene meshes. The supplied archive contains a BSD license inside `pymoveit2`, while the upstream project README states MIT licensing for the project as a whole; the archive itself does not contain a root `LICENSE` file. See `docs/LICENSING.md`.

---

## 🎯 What the project does

The system follows this pipeline:

```text
Gazebo camera
     │
     ▼
/camera/image_raw
     │
     ▼
OpenCV ColorDetector
     │  BGR → HSV → mask → morphology → contours → centroid
     ▼
Pixel coordinates (cx_pix, cy_pix)
     │
     ▼
Pinhole projection
     │
     ▼
3D point in camera frame
     │
     ▼
TF2: camera_link → panda_link0
     │
     ▼
/color_coordinates
     │
     ▼
PyMoveIt2 pick_and_place.py
     │
     ▼
MoveIt 2 → ros2_control → Panda arm + gripper
     │
     ▼
Pick → move → place → return
```

The presentation explicitly shows the final ROS 2 chain as camera → color detector → `/color_coordinates` → `pick_and_place.py`, and reports an example detected red target at `(0.600, 0.000, 1.100)`. fileciteturn0file0L279-L301

---

# 📦 Repository structure

```text
Franka_Panda_Color_Sorting_Robot/
│
├── panda_description/              # Panda URDF/Xacro, meshes, camera, Gazebo world
│   ├── urdf/
│   ├── meshes/
│   ├── models/
│   ├── worlds/
│   └── launch/
│
├── panda_controller/               # ros2_control configuration and launch files
│   ├── config/panda_controllers.yaml
│   └── launch/controller.launch.py
│
├── panda_moveit/                   # MoveIt 2 configuration
│   ├── config/
│   ├── launch/moveit.launch.py
│   └── rviz/moveit.rviz
│
├── panda_vision/                   # OpenCV + ROS 2 color detector
│   ├── panda_vision/color_detector.py
│   ├── setup.py
│   └── test/
│
├── panda_bringup/                  # Main system launch
│   └── launch/pick_and_place.launch.py
│
├── pymoveit2/                      # Bundled Python MoveIt 2 interface
│   ├── pymoveit2/
│   └── examples/pick_and_place.py
│
├── docs/                           # Project documentation and presentation
│   ├── ARCHITECTURE.md
│   ├── COLOR_DETECTION.md
│   ├── COORDINATE_FRAMES.md
│   ├── INSTALLATION.md
│   ├── LICENSING.md
│   └── project-presentation.pdf
│
├── Dockerfile
├── .dockerignore
├── .gitignore
└── README.md
```

The workspace/package organization is also shown in the supplied presentation: `panda_description`, `panda_controller`, `panda_moveit`, `panda_vision`, `panda_bringup`, and `pymoveit2`. fileciteturn0file0L25-L32

---

# 🧠 How each package works

## 1. `panda_description`

This package contains the robot and simulation description:

- Panda URDF/Xacro files
- link meshes and visual/collision geometry
- Gazebo configuration
- camera sensor description
- simulated table/scene models
- RViz display configuration

The presentation explains that the URDF describes links, visual meshes, collision geometry, masses and inertial parameters. fileciteturn0file0L36-L40

### Robot model

The Franka Panda is modeled as a **7-DOF arm** with a two-finger gripper. The presentation also introduces the Denavit–Hartenberg parameters and homogeneous transformations used to reason about the kinematics. fileciteturn0file0L49-L50

---

## 2. `panda_controller`

This package starts `ros2_control` and spawns:

- `joint_state_broadcaster`
- `arm_controller`
- `gripper_controller`

The arm controller commands the seven Panda joints using position interfaces. The gripper controller commands the two finger joints.

The supplied presentation describes the controller flow as:

```text
MoveIt 2 trajectory
       ↓
JointTrajectoryController
       ↓
Panda joints
```

and gives the PID control law conceptually as `τ = Kp e + Ki ∫e dt + Kd de/dt`. fileciteturn0file0L44-L49

---

## 3. `panda_moveit`

This package configures MoveIt 2.

It loads:

- Panda URDF
- Panda SRDF
- kinematics configuration
- joint limits
- controller configuration
- RViz configuration

`moveit.launch.py` uses `MoveItConfigsBuilder` and starts the central `move_group` node plus RViz.

The presentation identifies four major motion-planning components: inverse kinematics, motion planning, collision avoidance and trajectory parameterization. fileciteturn0file0L99-L117

---

## 4. `panda_vision`

This is the computer-vision component.

`color_detector.py`:

1. subscribes to `/camera/image_raw`
2. converts ROS Image → OpenCV BGR
3. converts BGR → HSV
4. creates masks for red/green/blue
5. erodes the masks twice
6. dilates the masks twice
7. extracts contours
8. computes the bounding-box centroid
9. converts the pixel position into a camera-frame point
10. looks up `camera_link → panda_link0` with TF2
11. transforms the point into the Panda base frame
12. publishes `COLOR,X,Y,Z` on `/color_coordinates`

The presentation documents the same seven core image-processing stages from raw image to centroid. fileciteturn0file0L229-L252

---

## 5. `pymoveit2`

The project includes a PyMoveIt2 package and a custom `examples/pick_and_place.py` node.

The pick-and-place node:

- waits for `/color_coordinates`
- filters by `target_color`
- locks the first matching target coordinates
- moves to a predefined start/home configuration
- approaches the object
- opens/closes the gripper
- moves to the drop configuration
- releases the object
- returns to the start configuration

Run it with:

```bash
ros2 run pymoveit2 pick_and_place.py --ros-args -p target_color:=R
```

or `G` / `B`.

---

# 🎨 Color detection details

The current detector uses these HSV ranges:

| Color | Hue | Saturation | Value |
|---|---:|---:|---:|
| Red | 0–10 | 120–255 | 70–255 |
| Green | 55–60 | 200–255 | 200–255 |
| Blue | 90–128 | 200–255 | 200–255 |

These ranges match the values shown in the project presentation. fileciteturn0file0L194-L223

HSV is used because hue separates color identity from brightness better than direct RGB thresholding. The binary mask is generated with `cv2.inRange()`.

For more detail, see [`docs/COLOR_DETECTION.md`](docs/COLOR_DETECTION.md).

---

# 📐 Pixel → 3D → robot coordinates

After detecting the object center `(cx_pix, cy_pix)`, the supplied implementation assumes a fixed depth `Z` and uses the camera intrinsics:

```text
fx = 585
fy = 588
cx = 320
cy = 160
```

The implementation then calculates a camera-frame point and applies a TF2 homogeneous transform:

```text
pt_base = T_camera_to_panda @ [X, Y, Z, 1]
```

The presentation explains the pinhole-camera idea and the subsequent 4×4 TF2 transform from the camera frame to `panda_link0`. fileciteturn0file0L257-L275

> **Calibration note:** the presentation describes the camera as approximately 1 m above the table, while the current Python implementation uses `Z = 0.1`. Treat `Z` as a calibration parameter and verify it against the actual simulated camera geometry before using the system for quantitative localization. This is intentionally documented rather than silently changed.

See [`docs/COORDINATE_FRAMES.md`](docs/COORDINATE_FRAMES.md).

---

# 🚀 Installation — Ubuntu 22.04 + ROS 2 Humble

The supplied Dockerfile and package manifests target **ROS 2 Humble**. The original project documentation also recommends Ubuntu 22.04 for Humble.

### 1. Create a ROS workspace

```bash
mkdir -p ~/panda_ws/src
cd ~/panda_ws/src
```

### 2. Clone your GitHub repository

Replace `<YOUR_USERNAME>` and `<YOUR_REPOSITORY>` with your GitHub account/repository:

```bash
git clone https://github.com/<YOUR_USERNAME>/<YOUR_REPOSITORY>.git Franka_Panda_Color_Sorting_Robot
cd Franka_Panda_Color_Sorting_Robot
```

### 3. Install ROS dependencies

```bash
cd ~/panda_ws
source /opt/ros/humble/setup.bash
rosdep update
rosdep install --from-paths src --ignore-src -r -y --skip-keys=opencv_python
```

### 4. Install the Python dependencies

```bash
python3 -m pip install --user \
  opencv-python==4.10.0.84 \
  numpy==1.24.4 \
  transforms3d
```

### 5. Build

```bash
cd ~/panda_ws
colcon build --symlink-install
source install/setup.bash
```

### 6. Verify packages

```bash
ros2 pkg list | grep -E 'panda|pymoveit2'
```

---

# 🐳 Docker

The repository includes a Dockerfile based on `osrf/ros:humble-desktop-full`.

Build it **from the repository root**:

```bash
docker build -t franka-panda-color-sorting:humble .
```

For GUI applications such as Gazebo and RViz on Linux:

```bash
xhost +local:docker
```

Run:

```bash
docker run -it --rm \
  --name franka_panda_color_sorter \
  --network host \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
  franka-panda-color-sorting:humble
```

The Dockerfile was made repository-local so it builds the code you cloned rather than silently cloning a different upstream repository.

---

# ▶️ Running the simulation

## Terminal 1 — launch Gazebo + controllers + MoveIt + vision

```bash
source ~/panda_ws/install/setup.bash
ros2 launch panda_bringup pick_and_place.launch.py
```

This starts the Gazebo simulation, robot state publisher/controllers, MoveIt 2/RViz and the color detector.

The current `pick_and_place.launch.py` intentionally leaves the pick-and-place node commented out. Start that node separately so the target color can be selected explicitly.

## Terminal 2 — start sorting

```bash
source ~/panda_ws/install/setup.bash
ros2 run pymoveit2 pick_and_place.py --ros-args -p target_color:=R
```

Available target colors:

```text
R = Red
G = Green
B = Blue
```

---

# 🔎 Useful ROS 2 diagnostics

```bash
# Nodes
ros2 node list

# Topics
ros2 topic list

# Camera image
ros2 topic echo /camera/image_raw

# Detected object coordinates
ros2 topic echo /color_coordinates

# Joint states
ros2 topic echo /joint_states

# Controllers
ros2 control list_controllers

# TF tree
ros2 run tf2_tools view_frames

# ROS graph
rqt_graph
```

The actual coordinate topic in the supplied code is `/color_coordinates`; the older upstream README contains references to `/detected_color`, which are not consistent with the current detector implementation.

---

# 🧩 ROS 2 topic architecture

| Topic | Publisher | Subscriber | Purpose |
|---|---|---|---|
| `/camera/image_raw` | Gazebo camera/image bridge | `panda_vision/color_detector` | Camera frames |
| `/color_coordinates` | `color_detector` | `pick_and_place` | `R/G/B,X,Y,Z` target coordinates |
| `/joint_states` | Joint state broadcaster | MoveIt/RViz | Robot state feedback |
| `/clock` | Gazebo | ROS 2 nodes | Simulation time |

The presentation's final architecture diagram also shows the vision-to-motion decoupling through ROS 2 topics. fileciteturn0file0L287-L301

---

# 🛠️ Main configuration files

| File | Role |
|---|---|
| `panda_description/urdf/panda.urdf.xacro` | Main Panda robot description |
| `panda_description/urdf/sensors.xacro` | Camera/sensor definition |
| `panda_description/launch/gazebo.launch.py` | Gazebo + camera/image bridge |
| `panda_controller/config/panda_controllers.yaml` | Arm/gripper controllers |
| `panda_controller/launch/controller.launch.py` | Starts controller manager and spawners |
| `panda_moveit/config/panda.srdf` | Semantic robot/planning groups |
| `panda_moveit/config/kinematics.yaml` | IK configuration |
| `panda_moveit/config/joint_limits.yaml` | Joint limits |
| `panda_moveit/config/moveit_controllers.yaml` | MoveIt → controller mapping |
| `panda_moveit/launch/moveit.launch.py` | MoveIt 2 + RViz |
| `panda_vision/panda_vision/color_detector.py` | Vision + 3D localization |
| `panda_bringup/launch/pick_and_place.launch.py` | Main bringup |
| `pymoveit2/examples/pick_and_place.py` | Manipulation sequence |

---

# 🔧 Customization

## Change HSV thresholds

Edit:

```text
panda_vision/panda_vision/color_detector.py
```

Change the `color_ranges` dictionary.

## Change camera calibration

Modify:

```python
self.fx = 585.0
self.fy = 588.0
self.cx = 320.0
self.cy = 160.0
```

and verify the assumed depth `Z`.

## Change target color

```bash
ros2 run pymoveit2 pick_and_place.py --ros-args -p target_color:=G
```

## Change motion speed

The current pick-and-place node uses:

```python
self.moveit2.max_velocity = 0.1
self.moveit2.max_acceleration = 0.1
```

These should be tuned carefully in simulation before any real robot deployment.

---

# ⚠️ Important limitations

1. **This is a simulation-oriented project.** Do not connect the motion commands to a real robot without validating safety, limits, frames, controller configuration and collision behavior.
2. The current detector assumes a fixed depth rather than estimating object depth from stereo/depth sensing.
3. HSV thresholds are fixed and may need tuning for different lighting/camera settings.
4. The supplied coordinate formulas contain empirical scaling/offset behavior; treat them as calibration-specific.
5. The current launch file starts the vision node but not the pick-and-place node; the latter is launched separately.
6. The project bundles a copy of PyMoveIt2. Its license must be preserved.

---

# 📚 Documentation

- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) — complete software architecture
- [`docs/COLOR_DETECTION.md`](docs/COLOR_DETECTION.md) — HSV and contour pipeline
- [`docs/COORDINATE_FRAMES.md`](docs/COORDINATE_FRAMES.md) — camera/robot coordinates and TF2
- [`docs/INSTALLATION.md`](docs/INSTALLATION.md) — installation checklist
- [`docs/LICENSING.md`](docs/LICENSING.md) — provenance and license notes
- [`docs/project-presentation.pdf`](docs/project-presentation.pdf) — supplied 19-page project presentation

---

# 👥 Project source / attribution

The supplied source archive corresponds to the public **MechaMind-Labs / Franka_Panda_Color_Sorting_Robot** project. The source project describes the system as ROS 2 + OpenCV + MoveIt 2 + Gazebo and credits Curious-Utkarsh as maintainer. citeturn0search0turn1search0

The uploaded presentation lists the following presenters: Abdessamad Britah, Sarah Hamdane, Yasmine Djellal, Amina Yahiaoui and Meryem MERHOUNI. fileciteturn0file0L11-L22

If you publish this repository, keep the appropriate upstream attribution and third-party license notices.

---

# ⭐ GitHub publishing checklist

Before pushing:

```bash
git status
git add .
git commit -m "Initial ROS 2 Franka Panda color sorting project"
git branch -M main
git remote add origin https://github.com/<YOUR_USERNAME>/<YOUR_REPOSITORY>.git
git push -u origin main
```

Recommended GitHub repository name:

```text
franka-panda-color-sorting-ros2
```

Recommended GitHub description:

```text
ROS 2 Humble Franka Panda color-sorting simulation using Gazebo, OpenCV, MoveIt 2, TF2 and PyMoveIt2.
```

Suggested topics:

```text
ros2
ros2-humble
franka-panda
robotics
moveit2
opencv
gazebo
computer-vision
pick-and-place
color-sorting
```

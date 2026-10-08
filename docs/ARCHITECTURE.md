# System Architecture

## 1. High-level architecture

```text
                 ┌─────────────────────┐
                 │   Gazebo / Camera   │
                 └──────────┬──────────┘
                            │ /camera/image_raw
                            ▼
                 ┌─────────────────────┐
                 │  panda_vision       │
                 │  OpenCV detector    │
                 └──────────┬──────────┘
                            │ /color_coordinates
                            ▼
                 ┌─────────────────────┐
                 │  pick_and_place.py  │
                 │  PyMoveIt2          │
                 └──────────┬──────────┘
                            │ MoveIt actions
                            ▼
                 ┌─────────────────────┐
                 │      MoveIt 2       │
                 │    move_group       │
                 └──────────┬──────────┘
                            │ trajectory
                            ▼
                 ┌─────────────────────┐
                 │    ros2_control     │
                 │ arm + gripper       │
                 └──────────┬──────────┘
                            ▼
                 ┌─────────────────────┐
                 │    Franka Panda     │
                 └─────────────────────┘
```

The supplied presentation describes MoveIt 2 as the central manipulation layer and shows `MoveItConfigsBuilder` assembling URDF, SRDF and controller information for `move_group`. See presentation pages 10–13.

## 2. Package responsibilities

### `panda_description`
Robot geometry, URDF/Xacro, sensor definitions, Gazebo world and models.

### `panda_controller`
Controller manager, joint-state broadcaster, arm trajectory controller and gripper controller.

### `panda_moveit`
MoveIt 2 semantic model, kinematics, joint limits, controller mapping and RViz configuration.

### `panda_vision`
Camera subscription, HSV segmentation, contour detection, pixel-to-3D conversion and TF2 transformation.

### `panda_bringup`
Top-level launch orchestration.

### `pymoveit2`
MoveIt 2 Python interface plus the custom pick-and-place example.

## 3. Runtime sequence

1. Gazebo starts the Panda and camera.
2. Robot state publisher publishes robot transforms.
3. `ros2_control` starts arm and gripper controllers.
4. MoveIt 2 starts `move_group`.
5. RViz connects to the MoveIt planning scene.
6. `color_detector` receives camera frames.
7. OpenCV finds red/green/blue objects.
8. TF2 converts the object point into `panda_link0`.
9. `/color_coordinates` publishes the target.
10. `pick_and_place.py` locks the requested color.
11. MoveIt plans the arm motion.
12. Controllers execute the trajectory.
13. The gripper closes around the object.
14. The arm moves to the predefined drop configuration.
15. The gripper releases the object.
16. The robot returns to the start configuration.

The final presentation page summarizes this exact decoupled vision → coordinates → manipulation architecture.

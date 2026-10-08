# Franka Panda Color Sorting Robot — ROS 2

## Design and Implementation of a ROS 2 Pick-and-Place Color Sorting System Using OpenCV and the Franka Panda Robot Arm

A ROS 2 simulation of an autonomous Franka Panda 7-DOF robotic arm capable of detecting colored objects using computer vision and performing pick-and-place operations based on their color.

The system integrates Gazebo, URDF/Xacro, ros2_control, MoveIt 2, OpenCV, TF2, PyMoveIt2, RViz 2, and ROS 2 communication.

---

## 👨‍🎓 Student Team

This project was developed and presented by:

- **Abdessamad Britah**
- **Sarah Hamdane**
- **Yasmine Djellal**
- **Amina Yahiaoui**
- **Meryem MERHOUNI**

---

## 👨‍🏫 Academic Supervisor

**Nasr-Eddine Mellah**

Academic Supervisor   
École Nationale Polytechnique d'Alger (ENP)  
Department of electronic 

---

## 📌 Project Overview

The objective of this project is to develop an autonomous robotic system capable of:

1. Detecting colored objects using an overhead camera.
2. Processing the camera image using OpenCV.
3. Identifying object colors using HSV color segmentation.
4. Computing the object's image centroid.
5. Converting image coordinates into 3D coordinates.
6. Transforming the coordinates into the Panda robot base frame using TF2.
7. Sending the target position to the motion-planning system.
8. Planning a collision-free trajectory using MoveIt 2.
9. Controlling the Franka Panda arm.
10. Picking the object and placing it according to its detected color.

---

## 🏗️ System Architecture

```text
                    ┌─────────────────────┐
                    │   Gazebo Simulation │
                    │                     │
                    │   Franka Panda     │
                    │   + Table + Objects│
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │   Gazebo Camera     │
                    │ /camera/image_raw   │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │   OpenCV Vision     │
                    │                     │
                    │ BGR → HSV           │
                    │ Color Mask          │
                    │ Morphology          │
                    │ Contours             │
                    │ Centroid             │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │ Pixel → 3D          │
                    │ Camera Coordinates  │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │       TF2           │
                    │ Camera → Panda Base │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │ /color_coordinates │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │     PyMoveIt2       │
                    │  Pick & Place Node  │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │      MoveIt 2       │
                    │ Motion Planning     │
                    │ Collision Avoidance│
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │   ros2_control      │
                    │                     │
                    │ Panda Controllers   │
                    └─────────────────────┘

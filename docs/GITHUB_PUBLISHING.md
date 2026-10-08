# Publish this project to GitHub

## Option A — GitHub website

1. Create a new empty repository on GitHub.
2. Do **not** initialize it with another README if you want to push this prepared repository directly.
3. Copy the repository URL.
4. From this project directory run:

```bash
git init
git branch -M main
git add .
git commit -m "Initial ROS 2 Franka Panda color sorting project"
git remote add origin https://github.com/<YOUR_USERNAME>/<YOUR_REPOSITORY>.git
git push -u origin main
```

## Option B — GitHub CLI

If `gh` is installed and authenticated:

```bash
gh auth login
gh repo create <YOUR_REPOSITORY> --public --source=. --remote=origin --push
```

## Before publishing

Check:

```bash
git status
find . -type f -name '*.pyc'
```

The second command should normally print nothing.

Also review `docs/LICENSING.md` before making the repository public because the project contains third-party robot/scene assets and a bundled PyMoveIt2 implementation.

## Recommended repository metadata

**Name**

```text
franka-panda-color-sorting-ros2
```

**Description**

```text
ROS 2 Humble Franka Panda color-sorting simulation using Gazebo, OpenCV, MoveIt 2, TF2 and PyMoveIt2.
```

**Topics**

```text
ros2, ros2-humble, robotics, franka-panda, moveit2, gazebo, opencv,
computer-vision, pick-and-place, color-sorting
```

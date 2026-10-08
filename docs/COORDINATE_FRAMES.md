# Coordinate Frames and 3D Projection

## 1. Camera model

The supplied detector uses:

```text
fx = 585.0
fy = 588.0
cx = 320.0
cy = 160.0
```

where `fx`, `fy` are focal lengths in pixels and `cx`, `cy` are the image principal point.

## 2. Pixel to camera point

The current implementation assumes:

```text
Z = 0.1
```

and calculates:

```text
Y = (cx_pix - cx) × Z / fx × (-10)
X = (cy_pix - cy) × Z / fy
```

These formulas are part of the supplied implementation and include an empirical `-10` scale factor in the camera-frame Y calculation.

## 3. TF2 transformation

The detector asks TF2 for:

```text
panda_link0 ← camera_link
```

It then builds a 4×4 homogeneous transform:

```text
T = [ R  t ]
    [ 0  1 ]
```

and applies:

```text
pt_cam  = [X, Y, Z, 1]^T
pt_base = T @ pt_cam
```

## 4. Color-specific offsets

The current code applies two empirical offsets after TF2:

```text
Blue:  pt_base[1] -= 0.0215
Green: pt_base[1] += 0.0200
```

No corresponding additional offset is applied for red.

## 5. Important calibration issue

The presentation describes the camera as approximately 1 m above the table, while the detector currently assumes `Z = 0.1`. This must be validated against the actual camera pose and scene geometry.

For a research-grade implementation, replace the fixed-depth assumption with a calibrated depth source or a plane-intersection method when appropriate.

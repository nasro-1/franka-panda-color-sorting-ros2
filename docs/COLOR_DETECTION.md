# Color Detection Pipeline

The detector is implemented in `panda_vision/panda_vision/color_detector.py`.

## Pipeline

```text
ROS Image
   ↓
BGR OpenCV image
   ↓
BGR → HSV
   ↓
HSV threshold
   ↓
Binary mask
   ↓
Erode × 2
   ↓
Dilate × 2
   ↓
Contours
   ↓
Bounding rectangle
   ↓
Centroid (cx_pix, cy_pix)
```

This matches the seven-stage pipeline shown in the supplied project presentation (page 16).

## Current thresholds

| Color | Lower HSV | Upper HSV |
|---|---|---|
| Red | `(0, 120, 70)` | `(10, 255, 255)` |
| Green | `(55, 200, 200)` | `(60, 255, 255)` |
| Blue | `(90, 200, 200)` | `(128, 255, 255)` |

## Why HSV?

HSV separates hue from saturation/value. This makes thresholding more interpretable when brightness changes.

## Morphological filtering

The implementation performs:

```python
mask = cv2.erode(mask, None, iterations=2)
mask = cv2.dilate(mask, None, iterations=2)
```

Erosion removes small isolated regions; dilation restores the main object region.

## Contour centroid

For every contour with area greater than 1 pixel:

```python
x, y, w, h = cv2.boundingRect(cnt)
cx_pix = x + w // 2
cy_pix = y + h // 2
```

The resulting pixel coordinate is passed to the projection stage.

## Output topic

The detector publishes a string:

```text
R,X,Y,Z
G,X,Y,Z
B,X,Y,Z
```

on:

```text
/color_coordinates
```

/// Represents a point prompt for SAM segmentation
class SamPoint {
  final double x;
  final double y;

  const SamPoint(this.x, this.y);
}

/// Represents a bounding box prompt for SAM segmentation
class SamBox {
  final double x1;
  final double y1;
  final double x2;
  final double y2;

  const SamBox(this.x1, this.y1, this.x2, this.y2);
}

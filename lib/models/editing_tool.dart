import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

enum EditingTool {
  zoomIn(
    tooltip: 'Zoom In',
    icon: Symbols.zoom_in_rounded,
    preferredCursor: SystemMouseCursors.zoomIn,
    allowsMarker: false,
  ),
  zoomOut(
    tooltip: 'Zoom Out',
    icon: Symbols.zoom_out_rounded,
    preferredCursor: SystemMouseCursors.zoomOut,
    allowsMarker: false,
  ),
  select(
    tooltip: 'Select',
    icon: Symbols.arrow_selector_tool_rounded,
    allowsMarker: false,
  ),
  pan(
    tooltip: 'Pan',
    icon: Symbols.drag_pan_rounded,
    preferredCursor: SystemMouseCursors.move,
    allowsMarker: false,
  ),
  line(
    tooltip: 'Line',
    icon: Symbols.diagonal_line_rounded,
  ),
  rectangle(tooltip: 'Rectangle', icon: Symbols.rectangle_rounded),
  circle(tooltip: 'Circle', icon: Symbols.circle_rounded),
  spline(tooltip: 'Spline', icon: Symbols.conversion_path_rounded),
  bezier(tooltip: 'Bezier', icon: Symbols.line_curve_rounded),
  symmetry(tooltip: 'Symmetry', icon: Symbols.details),
  autoNotch(tooltip: 'Auto Notch', icon: Symbols.shape_line_rounded);

  final String tooltip;
  final IconData icon;
  final MouseCursor preferredCursor;
  final bool allowsMarker;

  const EditingTool(
      {required this.tooltip,
      required this.icon,
      this.preferredCursor = SystemMouseCursors.basic,
      this.allowsMarker = true});
}

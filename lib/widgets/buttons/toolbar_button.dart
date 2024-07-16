import 'package:flutter/material.dart';

import '../../models/editing_tool.dart';

class ToolbarButton extends StatelessWidget {
  final bool? isToggled;
  final String? tooltip;
  final VoidCallback? onPressed;
  final IconData icon;
  final IconData? toggledIcon;
  final bool? filled;

  const ToolbarButton({
    super.key,
    this.isToggled,
    this.tooltip,
    this.onPressed,
    required this.icon,
    this.toggledIcon,
    this.filled,
  });

  ToolbarButton.fromEditingTool({
    super.key,
    this.isToggled,
    this.onPressed,
    required EditingTool editingTool,
    this.toggledIcon,
    this.filled,
  }) : icon = editingTool.icon, tooltip = editingTool.tooltip;


  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip ?? '',
      child: ToggleButtons(
        renderBorder: false,
        constraints: const BoxConstraints.tightFor(width: 40, height: 40),
        borderRadius: BorderRadius.circular(16),
        isSelected: [isToggled ?? false],
        onPressed: (int index) {
          onPressed?.call();
        },
        children: [
          Icon(
            isToggled ?? false ? toggledIcon ?? icon : icon,
            fill: filled ?? isToggled ?? false ? 1 : 0,
            color: colorScheme.onSurface
          )
        ]
      )
    );
  }
}

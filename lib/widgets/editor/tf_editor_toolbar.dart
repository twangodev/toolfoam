import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:toolfoam/models/editing_tool.dart';
import 'package:toolfoam/widgets/buttons/toolbar_button.dart';
import 'package:toolfoam/widgets/editor/tf_editor_config.dart';

class TFEditorToolbar extends StatefulWidget {

  final VoidCallback? attachImage;
  final VoidCallback? onOpen;
  final VoidCallback? onSave;
  final VoidCallback? onSaveAs;
  final VoidCallback? onExport;

  final VoidCallback? onUndo;
  final VoidCallback? onRedo;

  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;
  final VoidCallback? onFit;
  final void Function(bool)? onToggleGrid;

  final void Function(EditingTool)? setTool;

  const TFEditorToolbar(
      {super.key,
      this.attachImage,
      this.onOpen,
      this.onSave,
      this.onSaveAs,
      this.onExport,
      this.onUndo,
      this.onRedo,
      this.onZoomIn,
      this.onZoomOut,
      this.onFit,
      this.onToggleGrid,
      this.setTool,
  });

  @override
  State<TFEditorToolbar> createState() => _TFEditorToolbarState();
}

class _TFEditorToolbarState extends State<TFEditorToolbar> {

  bool gridToggleState = false;
  EditingTool activeEditingTool = TFEditorConfig.defaultTool;

  void toggleGrid() {
    setState(() {
      gridToggleState = !gridToggleState;
    });
    widget.onToggleGrid?.call(gridToggleState);
  }

  void setTool(EditingTool tool) {
    setState(() {
      activeEditingTool = tool;
    });
    widget.setTool?.call(tool);
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    Widget divider = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: VerticalDivider(width: 2, thickness: 2, color: colorScheme.onSurface.withOpacity(0.5)),
    );
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          PopupMenuButton<VoidCallback>(
            icon: SizedBox(
              height: 40,
              width: 40,
              child: Icon(Icons.menu_rounded, color: colorScheme.onSurface),
            ),
            tooltip: 'Menu',
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<VoidCallback>(
                value: widget.attachImage,
                child: const ListTile(
                  leading: Icon(Icons.add_photo_alternate_rounded),
                  title: Text('Add Image Reference'),
                ),
              ),
              PopupMenuItem<VoidCallback>(
                value: widget.onOpen,
                child: const ListTile(
                  leading: Icon(Icons.folder_open_rounded),
                  title: Text('Open'),
                ),
              ),
              PopupMenuItem<VoidCallback>(
                value: widget.onSave,
                child: const ListTile(
                  leading: Icon(Icons.save_rounded),
                  title: Text('Save'),
                ),
              ),
              PopupMenuItem<VoidCallback>(
                value: widget.onSaveAs,
                child: const ListTile(
                  leading: Icon(Icons.save_as_rounded),
                  title: Text('Save As'),
                ),
              ),
              PopupMenuItem<VoidCallback>(
                value: widget.onExport,
                child: const ListTile(
                  leading: Icon(Icons.file_download_rounded),
                  title: Text('Export'),
                ),
              ),
            ],
          ),
          ToolbarButton(
            icon: Icons.undo_rounded,
            onPressed: widget.onUndo,
            tooltip: 'Undo'
          ),
          ToolbarButton(
            icon: Icons.redo_rounded,
            onPressed: widget.onRedo,
            tooltip: 'Redo'
          ),
          divider,
          ToolbarButton.fromEditingTool(
            editingTool: EditingTool.zoomIn,
            isToggled: activeEditingTool == EditingTool.zoomIn,
            onPressed: () => setTool(EditingTool.zoomIn),
          ),
          ToolbarButton.fromEditingTool(
            editingTool: EditingTool.zoomOut,
            isToggled: activeEditingTool == EditingTool.zoomOut,
            onPressed: () => setTool(EditingTool.zoomOut),
          ),
          ToolbarButton(
              icon: Icons.zoom_out_map_rounded,
              onPressed: widget.onFit,
              tooltip: 'Zoom to Fit'
          ),
          ToolbarButton(
            icon: Icons.grid_off_rounded,
            toggledIcon: Icons.grid_on_rounded,
            isToggled: gridToggleState,
            onPressed: toggleGrid,
            tooltip: 'Toggle Grid'
          ),
          divider,
          ToolbarButton.fromEditingTool(
            editingTool: EditingTool.select,
            isToggled: activeEditingTool == EditingTool.select,
            onPressed: () => setTool(EditingTool.select),
          ),
          ToolbarButton.fromEditingTool(
            editingTool: EditingTool.pan,
            isToggled: activeEditingTool == EditingTool.pan,
            onPressed: () => setTool(EditingTool.pan),
          ),
          ToolbarButton.fromEditingTool(
            editingTool: EditingTool.line,
            isToggled: activeEditingTool == EditingTool.line,
            onPressed: () => setTool(EditingTool.line),
          ),
          ToolbarButton.fromEditingTool(
            editingTool: EditingTool.rectangle,
            isToggled: activeEditingTool == EditingTool.rectangle,
            onPressed: () => setTool(EditingTool.rectangle),
          ),
          ToolbarButton.fromEditingTool(
            editingTool: EditingTool.circle,
            isToggled: activeEditingTool == EditingTool.circle,
            onPressed: () => setTool(EditingTool.circle),
          ),
          ToolbarButton.fromEditingTool(
            editingTool: EditingTool.spline,
            isToggled: activeEditingTool == EditingTool.spline,
            onPressed: () => setTool(EditingTool.spline),
          ),
          ToolbarButton.fromEditingTool(
            editingTool: EditingTool.bezier,
            isToggled: activeEditingTool == EditingTool.bezier,
            onPressed: () => setTool(EditingTool.bezier),
          ),
          ToolbarButton.fromEditingTool(
            editingTool: EditingTool.symmetry,
            isToggled: activeEditingTool == EditingTool.symmetry,
            onPressed: () => setTool(EditingTool.symmetry),
          ),
          divider,
          ToolbarButton.fromEditingTool(
            editingTool: EditingTool.autoNotch,
            isToggled: activeEditingTool == EditingTool.autoNotch,
            onPressed: () => setTool(EditingTool.autoNotch),
          )
        ]
      ),
    );
  }
}

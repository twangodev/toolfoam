import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:toolfoam/models/tools/tf_tool.dart';
import 'package:toolfoam/widgets/editor/tf_editor_config.dart';
import 'package:toolfoam/widgets/editor/tf_editor_interactive_viewer.dart';
import 'package:toolfoam/widgets/editor/tf_editor_painter.dart';
import 'package:toolfoam/widgets/editor/tf_editor_painter_data.dart';
import 'package:toolfoam/widgets/editor/tf_editor_toolbar.dart';
import 'package:vector_math/vector_math_64.dart';

import '../../models/editing_tool.dart';

class TFEditor extends StatefulWidget {

  final TFTool tool;

  const TFEditor({super.key, required this.tool});

  @override
  State<TFEditor> createState() => _TFEditorState();

}

class _TFEditorState extends State<TFEditor> {

  final TransformationController transformationController = TransformationController();

  late final TFEditorData notifier = TFEditorData(data: widget.tool.data);

  Size viewerSize = Size.zero;
  bool allowPrimaryMouseButtonPan = false;
  bool initialMove = false;

  bool gridToggleState = false;
  EditingTool activeEditingTool = TFEditorConfig.defaultTool;

  void toggleGrid(bool newState) {
    setState(() {
      gridToggleState = newState;
    });
  }

  void setTool(EditingTool tool) {
    setState(() {
      activeEditingTool = tool;
      allowPrimaryMouseButtonPan = tool == EditingTool.pan;
    });
  }

  @override
  void initState() {
    super.initState();

    transformationController.addListener(() {
      notifier.scale = transformationController.value.getMaxScaleOnAxis();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (initialMove) return;
      transformationController.value = Matrix4.identity()..translate(viewerSize.width / 2, viewerSize.height / 2);
      initialMove = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(8),
      child: Card(
        color: colorScheme.surfaceContainerLow,
        child: Column(
          children: [
            TFEditorToolbar(
              onToggleGrid: toggleGrid,
              setTool: setTool,
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  viewerSize = Size(constraints.maxWidth, constraints.maxHeight);
                  return Listener(
                    onPointerDown: (PointerDownEvent event) {
                      print('down $event');
                    },
                    onPointerMove: (PointerMoveEvent event) {
                      notifier.activePointer = transformationController.toScene(event.localPosition);
                    },
                    onPointerHover: (PointerHoverEvent event) {
                      notifier.activePointer = transformationController.toScene(event.localPosition);
                    },
                    child: MouseRegion(
                      onExit: (PointerExitEvent event) {
                        notifier.activePointer = null;
                      },
                      cursor: activeEditingTool.preferredCursor,
                      child: TFEditorInteractiveViewer.builder(
                        boundaryMargin: const EdgeInsets.all(double.infinity),
                        minScale: TFEditorConfig.minScale,
                        maxScale: TFEditorConfig.maxScale,
                        transformationController: transformationController,
                        illegalMousePanSet: const {kPrimaryMouseButton},
                        ignoreIllegalMousePan: allowPrimaryMouseButtonPan,
                        interactionEndFrictionCoefficient: TFEditorConfig.frictionCoefficient,
                        builder: (BuildContext context, Quad viewport) {
                          return ListenableBuilder(
                            listenable: notifier,
                            builder: (BuildContext context, Widget? child) {
                              return CustomPaint(
                                painter: TFEditorPainter(
                                  viewport: viewport,
                                  data: notifier,
                                  toggleGrid: gridToggleState,
                                  editingTool: activeEditingTool,
                                ),
                                size: Size(constraints.maxWidth, constraints.maxHeight),
                              );
                            }
                          );
                        }
                      )
                    )
                  );
                }
              )
            )
          ],
        )
      )
    );
  }

}
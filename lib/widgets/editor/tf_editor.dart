import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:toolfoam/models/tools/tf_tool.dart';
import 'package:toolfoam/extensions/list_extensions.dart';
import 'package:toolfoam/widgets/editor/tf_editor_config.dart';
import 'package:toolfoam/widgets/editor/tf_editor_interactive_viewer.dart';
import 'package:toolfoam/widgets/editor/tf_editor_painter.dart';
import 'package:toolfoam/widgets/editor/tf_editor_painter_data.dart';
import 'package:toolfoam/widgets/editor/tf_editor_toolbar.dart';
import 'package:vector_math/vector_math_64.dart';

import '../../models/editing_tool.dart';
import '../../models/line.dart';
import '../../models/tools/tf_path_data.dart';

class TfEditor extends StatefulWidget {
  final TfTool tool;

  const TfEditor({super.key, required this.tool});

  @override
  State<TfEditor> createState() => _TfEditorState();
}

class _TfEditorState extends State<TfEditor> {
  static final logger = Logger('TFEditorState');

  final TransformationController transformationController =
      TransformationController();

  late final TfEditorData notifier = TfEditorData(toolData: widget.tool.data);

  Size viewerSize = Size.zero;
  bool allowPrimaryMouseButtonPan = false;
  bool initialMove = false;

  bool gridToggleState = false;
  EditingTool activeEditingTool = TfEditorConfig.defaultTool;
  List<String> actionPointBuffer = [];

  void toggleGrid(bool newState) {
    setState(() {
      gridToggleState = newState;
    });
  }

  void setTool(EditingTool tool) {
    notifier.actionPointerStack.clear();
    setState(() {
      activeEditingTool = tool;
      allowPrimaryMouseButtonPan = tool == EditingTool.pan;
    });
  }

  void onPointerDown(PointerDownEvent event) {
    logger.finer('Pointer down event: $event');
    if (activeEditingTool == EditingTool.pan) return;
    Offset scenePointer = transformationController.toScene(event.localPosition);
    Offset effectivePointer =
        notifier.effectivePointerCoordinates(scenePointer);

    if (activeEditingTool == EditingTool.line) {
      if (notifier.shouldConfirm(scenePointer)) {
        logger.finer('Confirming line, clearing action stack');
        notifier.actionPointerStack.clear();
        notifier.redraw();
        return;
      }

      TfToolData toolData = notifier.toolData;
      String pointUuid = toolData.addPoint(effectivePointer);
      notifier.actionPointerStack.add(pointUuid);

      if (notifier.actionPointerStack.length >= 2) {
        String startUuid = notifier.actionPointerStack.secondLast;
        String endUuid = notifier.actionPointerStack.last;

        Line line = Line(startUuid, endUuid);
        toolData.addLine(line);
      }

      return;
    }
  }

  void updatePointer(PointerEvent event) {
    notifier.activePointer =
        transformationController.toScene(event.localPosition);
  }

  @override
  void initState() {
    super.initState();

    transformationController.addListener(() {
      notifier.scale = transformationController.value.getMaxScaleOnAxis();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (initialMove) return;
      transformationController.value = Matrix4.identity()
        ..translate(viewerSize.width / 2, viewerSize.height / 2);
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
                TfEditorToolbar(
                  onToggleGrid: toggleGrid,
                  setTool: setTool,
                ),
                Expanded(child: LayoutBuilder(builder:
                    (BuildContext context, BoxConstraints constraints) {
                  viewerSize =
                      Size(constraints.maxWidth, constraints.maxHeight);
                  return Listener(
                      onPointerDown: onPointerDown,
                      onPointerMove: updatePointer,
                      onPointerHover: updatePointer,
                      onPointerPanZoomStart: updatePointer,
                      onPointerPanZoomUpdate: updatePointer,
                      onPointerPanZoomEnd: updatePointer,
                      child: MouseRegion(
                          onExit: (PointerExitEvent event) {
                            notifier.activePointer = null;
                          },
                          cursor: activeEditingTool.preferredCursor,
                          child: TfEditorInteractiveViewer.builder(
                              boundaryMargin:
                                  const EdgeInsets.all(double.infinity),
                              minScale: TfEditorConfig.minScale,
                              maxScale: TfEditorConfig.maxScale,
                              transformationController:
                                  transformationController,
                              illegalMousePanSet: const {kPrimaryMouseButton},
                              ignoreIllegalMousePan: allowPrimaryMouseButtonPan,
                              interactionEndFrictionCoefficient:
                                  TfEditorConfig.frictionCoefficient,
                              builder: (BuildContext context, Quad viewport) {
                                return ListenableBuilder(
                                    listenable: notifier,
                                    builder:
                                        (BuildContext context, Widget? child) {
                                      return CustomPaint(
                                        painter: TfEditorPainter(
                                          viewport: viewport,
                                          editorData: notifier,
                                          toggleGrid: gridToggleState,
                                          editingTool: activeEditingTool,
                                        ),
                                        size: Size(constraints.maxWidth,
                                            constraints.maxHeight),
                                      );
                                    });
                              })));
                }))
              ],
            )));
  }
}

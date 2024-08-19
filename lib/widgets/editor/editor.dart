import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:toolfoam/extensions/list_extension.dart';
import 'package:toolfoam/geometry/point.dart';
import 'package:toolfoam/models/tf_id.dart';
import 'package:toolfoam/models/tf_tool.dart';
import 'package:toolfoam/widgets/editor/editor_config.dart';
import 'package:toolfoam/widgets/editor/editor_interactive_viewer.dart';
import 'package:toolfoam/widgets/editor/editor_painter.dart';
import 'package:toolfoam/widgets/editor/editor_data.dart';
import 'package:toolfoam/widgets/editor/editor_toolbar.dart';
import 'package:vector_math/vector_math_64.dart';

import '../../geometry/segment.dart';
import '../../models/editing_tool.dart';
import '../../models/tf_tool_data.dart';

class Editor extends StatefulWidget {
  final TfTool tool;

  const Editor({super.key, required this.tool});

  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  static final logger = Logger('toolfoam.widgets.editor');

  final transformationController = TransformationController();

  Size viewerSize = Size.zero;
  bool allowPrimaryMouseButtonPan = false;
  bool initialMove = false;

  bool gridToggleState = false;
  EditingTool activeEditingTool = EditorConfig.defaultTool;
  List<String> actionPointBuffer = [];

  late final data = EditorData(
      toolData: widget.tool.data, gridToggleState: () => gridToggleState);

  void toggleGrid(bool newState) {
    logger.finer('Toggling grid to $newState');
    setState(() {
      gridToggleState = newState;
    });
  }

  void setTool(EditingTool tool) {
    logger.finer('Setting tool to ${tool.tooltip}');
    logger.finer(
        'Clearing current contents of action stack: ${data.pointStack}');
    data.pointStack.clear();
    setState(() {
      activeEditingTool = tool;
      allowPrimaryMouseButtonPan = tool == EditingTool.pan;
    });
  }

  void updatePointer(PointerEvent event) {
    Offset scenePointer = transformationController.toScene(event.localPosition);
    data.activePointer = scenePointer;

    if (data.dragPointUuid != null) {
      TfId dragPoint = data.dragPointUuid!;

      Set<TfId> ignore = {dragPoint};
      ignore.addAll(data.toolData.segments.dependsOn(dragPoint));
      Offset effectivePointer = data.nearestSnap(scenePointer, ignore)?.point ??
          scenePointer; // TODO fix this madness

      TfId? existingPoint = data.toolData.fixedPoints
          .getId(FixedPoint.fromOffset(effectivePointer));
      if (existingPoint != null && existingPoint != dragPoint) {
        // TODO temporary point deletion (snaps to existing point)
        return;
      } else if (existingPoint == null) {
        // TODO point reinsertion
      }

      data.toolData.fixedPoints[dragPoint] =
          FixedPoint.fromOffset(effectivePointer);
    }
  }

  void onPointerDown(PointerDownEvent event) {
    updatePointer(event);

    if (activeEditingTool == EditingTool.pan) return;
    Offset scenePointer = transformationController.toScene(event.localPosition);
    Offset effectivePointer = data.snap?.point ?? scenePointer;

    logger.finer('Pointer down at: $effectivePointer');

    if (activeEditingTool == EditingTool.select) {
      TfId? pointUuid = data.toolData.fixedPoints
          .getId(FixedPoint.fromOffset(effectivePointer));
      if (pointUuid != null) {
        data.dragPointUuid = pointUuid;
      }
      return;
    }

    if (activeEditingTool == EditingTool.line) {
      if (data.shouldConfirm(scenePointer)) {
        logger.finer('Confirming line, clearing action stack');
        data.pointStack.clear();
        data.redraw();
        return;
      }

      TfToolData toolData = data.toolData;
      TfId pointId =
          toolData.fixedPoints.add(FixedPoint.fromOffset(effectivePointer));
      data.pointStack.add(pointId);

      if (data.pointStack.length >= 2) {
        TfId start = data.pointStack.secondLast;
        TfId end = data.pointStack.last;

        Segment line = Segment(start, end);
        toolData.segments.add(line);
      }

      data.redraw();
      return;
    }

    if (activeEditingTool == EditingTool.line) {}
  }

  void onPointerUp(PointerUpEvent event) {
    updatePointer(event);

    data.dragPointUuid = null;
  }

  @override
  void initState() {
    super.initState();

    transformationController.addListener(() {
      data.scale = transformationController.value.getMaxScaleOnAxis();
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
                EditorToolbar(
                  onToggleGrid: toggleGrid,
                  setTool: setTool,
                ),
                Expanded(child: LayoutBuilder(builder:
                    (BuildContext context, BoxConstraints constraints) {
                  viewerSize =
                      Size(constraints.maxWidth, constraints.maxHeight);
                  return Listener(
                      onPointerDown: onPointerDown,
                      onPointerUp: onPointerUp,
                      onPointerMove: updatePointer,
                      onPointerHover: updatePointer,
                      onPointerPanZoomStart: updatePointer,
                      onPointerPanZoomUpdate: updatePointer,
                      onPointerPanZoomEnd: updatePointer,
                      child: MouseRegion(
                          onExit: (PointerExitEvent event) {
                            data.activePointer = null;
                          },
                          cursor: activeEditingTool.preferredCursor,
                          child: EditorInteractiveViewer.builder(
                              boundaryMargin:
                                  const EdgeInsets.all(double.infinity),
                              minScale: EditorConfig.minScale,
                              maxScale: EditorConfig.maxScale,
                              transformationController:
                                  transformationController,
                              illegalMousePanSet: const {kPrimaryMouseButton},
                              ignoreIllegalMousePan: allowPrimaryMouseButtonPan,
                              interactionEndFrictionCoefficient:
                                  EditorConfig.frictionCoefficient,
                              builder: (BuildContext context, Quad viewport) {
                                return ListenableBuilder(
                                    listenable: data,
                                    builder:
                                        (BuildContext context, Widget? child) {
                                      return CustomPaint(
                                        painter: EditorPainter(
                                          viewport: viewport,
                                          editorData: data,
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

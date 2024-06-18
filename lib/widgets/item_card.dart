import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:toolfoam/widgets/renameable_title.dart';

import 'animation_timings.dart';

class ItemCard extends StatefulWidget {

  Widget? preview;
  VoidCallback onTap;

  ItemCard({super.key, required this.preview, required this.onTap});

  @override
  State<ItemCard> createState() => _ItemCardState();

}

class _ItemCardState extends State<ItemCard> {

  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    BorderRadius bottomBorderRadius = const BorderRadius.only(
      bottomLeft: Radius.circular(12),
      bottomRight: Radius.circular(12)
    );
    Widget previewContents = widget.preview ?? const Center(child: Text('No preview available'));
    return Card(
      elevation: 1,
      color: colorScheme.surfaceContainerHigh,
      child: Column(
        children: [
          Container(
            height: 38,
            padding: const EdgeInsets.only(left: 4),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: RenameableTitle(
                      title: 'Tool Name',
                      onRename: (String text) {  },
                    )
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert), onPressed: () {  },
                )
              ]
            )
          ),
          Expanded(
            flex: 16,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: bottomBorderRadius,
                color: colorScheme.surfaceContainer,
              ),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                onEnter: (event) {
                  setState(() {
                    hovering = true;
                  });
                },
                onExit: (event) {
                  setState(() {
                    hovering = false;
                  });
                },
                child: GestureDetector(
                  onTap: () {  },
                  child: Stack(
                    children: [
                      previewContents,
                      Positioned.fill(
                        child: AnimatedOpacity(
                          duration: AnimationDurations.fast,
                          opacity: hovering ? 1 : 0,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: bottomBorderRadius,
                              color: Colors.black.withOpacity(0.5),
                            ),
                            child: const Center(
                              child: Icon(Icons.edit_rounded, color: Colors.white, size: 36),
                            )
                          )
                        )
                      )
                    ],
                  )
                ),
              )
            )
          )
        ]
      )
    );
  }

}
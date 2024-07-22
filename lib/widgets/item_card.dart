import 'package:flutter/material.dart';
import 'package:toolfoam/widgets/text/renameable_title.dart';

import 'animation_timings.dart';

class ItemCard extends StatefulWidget {
  final String name;
  final Widget? preview;
  final VoidCallback onTap;
  final void Function(String text) onRename;
  final VoidCallback onDetails;
  final VoidCallback onDelete;

  const ItemCard({
    super.key,
    required this.name,
    required this.preview,
    required this.onTap,
    required this.onRename,
    required this.onDetails,
    required this.onDelete,
  });

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  String name = '';
  bool hovering = false;

  void onRename(String newName) {
    widget.onRename(newName);

    setState(() {
      name = newName;
    });
  }

  MenuItemButton generateMenuItemButton(
      BuildContext context, Icon icon, String text, VoidCallback onPressed) {
    return generateFullMenuItemButton(context, icon, text, false, onPressed);
  }

  MenuItemButton generateFullMenuItemButton(BuildContext context, Icon icon,
      String text, bool isError, VoidCallback onPressed) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return MenuItemButton(
      leadingIcon: icon,
      onPressed: onPressed,
      style: isError
          ? ElevatedButton.styleFrom(
              overlayColor: colorScheme.error,
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
        child: Text(text, style: const TextStyle(fontSize: 14)),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    name = widget.name;
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    BorderRadius bottomBorderRadius = const BorderRadius.only(
        bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12));
    Widget previewContents =
        widget.preview ?? const Center(child: Text('No preview available'));
    return Card(
        elevation: 1,
        color: colorScheme.surfaceContainerHigh,
        child: Column(children: [
          Container(
              height: 38,
              padding: const EdgeInsets.only(left: 4),
              child: Row(children: [
                Expanded(
                  flex: 5,
                  child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: RenameableTitle(
                        title: name,
                        onRename: onRename,
                      )),
                ),
                MenuAnchor(
                  builder: (BuildContext context, MenuController controller,
                      Widget? child) {
                    return IconButton(
                        icon: const Icon(Icons.more_vert_rounded),
                        onPressed: () {
                          if (controller.isOpen) {
                            controller.close();
                          } else {
                            controller.open();
                          }
                        });
                  },
                  menuChildren: [
                    generateMenuItemButton(
                        context,
                        const Icon(Icons.info_outline_rounded),
                        'Details',
                        widget.onDetails),
                    generateFullMenuItemButton(
                        context,
                        const Icon(Icons.delete_outline_rounded),
                        'Delete',
                        true,
                        widget.onDelete),
                  ],
                )
              ])),
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
                        onTap: widget.onTap,
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
                                          child: Icon(Icons.edit_rounded,
                                              color: Colors.white, size: 36),
                                        ))))
                          ],
                        )),
                  )))
        ]));
  }
}

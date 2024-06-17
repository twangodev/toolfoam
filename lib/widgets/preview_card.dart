import 'package:flutter/material.dart';
import 'package:toolfoam/widgets/renameable_title.dart';

class PreviewCard extends StatefulWidget {

  const PreviewCard({super.key});

  @override
  State<PreviewCard> createState() => _PreviewCardState();

}

class _PreviewCardState extends State<PreviewCard> {

  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
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
                  icon: Icon(Icons.star), onPressed: () {  },
                ),
                IconButton(
                  icon: Icon(Icons.more_vert), onPressed: () {  },
                )
              ]
            )
          ),
          Expanded(
            flex: 16,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12)
                ),
                color: colorScheme.surfaceContainer,
              ),
            )
          )
        ]
      )
    );
  }

}
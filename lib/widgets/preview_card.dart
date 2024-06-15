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
      color: colorScheme.surfaceContainerHigh,
      child: const Column(
        children: [
          Row(
            children: [
              Text("womp womp")
            ]
          ),
        ]
      ),
    );
  }

}
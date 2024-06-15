import 'dart:io';

import 'package:flutter/material.dart';
import 'package:toolfoam/widgets/containers/required_active_collection_container.dart';
import 'package:toolfoam/widgets/preview_card.dart';
import 'package:toolfoam/widgets/toolbars/organizer.dart';

import '../data/tf_collection.dart';

class ToolsPage extends StatefulWidget {

  final TFCollection? selectedCollection;
  final Function(TFCollection?) onCollectionSelected;

  const ToolsPage({super.key, required this.selectedCollection, required this.onCollectionSelected});

  @override
  State<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage> {

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return RequiredActiveCollectionContainerWidget(
      selectedCollection: widget.selectedCollection,
      onCollectionSelected: widget.onCollectionSelected,
      child: Card(
        color: colorScheme.surfaceContainerLow,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Organizer(title: 'Tools', addItemTooltip: 'Add a new tool', onAddFolder: () {}, onAddItem: () {}),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 4,
                      childAspectRatio: 1.35,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        for (int i = 0; i < 20; i++) PreviewCard()
                      ],
                    )
                  ]
              ),
              )
            ]
          ),
        )
      )
    );
  }

}
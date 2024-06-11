import 'dart:io';

import 'package:flutter/material.dart';
import 'package:toolfoam/widgets/containers/required_active_collection_container.dart';
import 'package:toolfoam/widgets/toolbars/organization_toolbar.dart';

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
        child: Column(
          children: [
            OrganizationToolbar(title: 'Tools', addItemTooltip: 'Add a new tool', onAddFolder: () {}, onAddItem: () {}),
            Image.asset('assets/images/pattern.png')
          ]
        ),
      )
    );
  }

}
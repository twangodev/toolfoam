import 'package:flutter/material.dart';
import 'package:toolfoam/widgets/containers/required_active_collection_container.dart';
import 'package:toolfoam/widgets/item_card.dart';
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
        elevation: 0,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              Organizer(
                title: 'Tools',
                addItemTooltip: 'Add a new tool',
                onAddFolder: () {
                  throw UnimplementedError();
                },
                onAddItem: () {
                  throw UnimplementedError();
                }
              ),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 4,
                      childAspectRatio: 16/9,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        for (int i = 0; i < 20; i++) ItemCard(
                          preview: null,
                          onTap: () {

                          }
                        )
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
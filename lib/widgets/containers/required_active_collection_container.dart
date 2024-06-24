import 'package:flutter/material.dart';
import 'package:toolfoam/widgets/buttons/collection_manager_button.dart';

import '../../models/tf_collection.dart';

class RequiredActiveCollectionContainerWidget extends StatelessWidget {

  final TFCollection? selectedCollection;
  final Function(TFCollection?) onCollectionSelected;
  final Widget child;

  const RequiredActiveCollectionContainerWidget({super.key, required this.selectedCollection, required this.onCollectionSelected, required this.child});

  @override
  Widget build(BuildContext context) {
    if (selectedCollection == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'No active collection selected',
              style: TextStyle(fontSize: 24),
            ),
            Container(
              margin: const EdgeInsets.only(top: 16),
              child: CollectionManagerButton(
                selectedCollection: selectedCollection,
                onCollectionSelected: onCollectionSelected,
              )
            )
          ]
        )
      );
    }

    return Container(
      padding: const EdgeInsets.all(8.0),
      child: child,
    );
  }

}
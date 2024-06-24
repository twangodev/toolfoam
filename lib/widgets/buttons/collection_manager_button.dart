import 'package:flutter/material.dart';

import '../../models/tf_collection.dart';
import '../dialogs/collection_manager_dialog.dart';

class CollectionManagerButton extends StatelessWidget {

  final TFCollection? selectedCollection;
  final Function(TFCollection?) onCollectionSelected;

  const CollectionManagerButton({super.key, required this.selectedCollection, required this.onCollectionSelected});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => CollectionManagerDialog(
            selectedCollection: () => selectedCollection,
            onCollectionSelected: onCollectionSelected,
          )
        );
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: colorScheme.onPrimaryContainer,
        backgroundColor: colorScheme.primaryContainer,
      ),
      child: Text(selectedCollection == null ? 'Manage Collections' : 'Switch Collections'),
    );
  }
}
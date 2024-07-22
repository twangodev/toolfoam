import 'package:flutter/material.dart';
import 'package:toolfoam/widgets/containers/required_active_collection_container.dart';

import '../models/tf_collection.dart';

class LayoutsPage extends StatefulWidget {
  final TfCollection? selectedCollection;
  final Function(TfCollection?) onCollectionSelected;

  const LayoutsPage(
      {super.key,
      required this.selectedCollection,
      required this.onCollectionSelected});

  @override
  State<LayoutsPage> createState() => _LayoutsPageState();
}

class _LayoutsPageState extends State<LayoutsPage> {
  @override
  Widget build(BuildContext context) {
    return RequiredActiveCollectionContainerWidget(
        selectedCollection: widget.selectedCollection,
        onCollectionSelected: widget.onCollectionSelected,
        child: const Center(
          child: Text('Layouts Page'),
        ));
  }
}

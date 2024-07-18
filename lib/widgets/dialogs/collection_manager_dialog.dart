import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:toolfoam/widgets/text/tooltip_date/tooltip_relative_date_text.dart';

import '../../models/entity.dart';
import '../../models/metadata.dart';
import '../../models/tf_collection.dart';

class CollectionManagerDialog extends StatefulWidget {

  const CollectionManagerDialog({super.key, required this.selectedCollection, required this.onCollectionSelected});
  final TfCollection? Function() selectedCollection;
  final ValueChanged<TfCollection?> onCollectionSelected;

  @override
  State<CollectionManagerDialog> createState() => _CollectionManagerDialogState();

}

class _CollectionManagerDialogState extends State<CollectionManagerDialog> {

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  List<TfCollection> collections = [];

  void _dismiss() {
    Navigator.of(context, rootNavigator: true).pop(context);
  }

  void _createCollection() async {
    TfCollection tfc = TfCollection(uuid: Entity.uuidGenerator.v4());
    await tfc.create(_searchController.text);

    _searchController.clear();
    _searchFocus.requestFocus();
    _refreshCollections();
  }

  void _refreshCollections() async {
    List<TfCollection> updatedCollections = await TfCollection.list();
    setState(() {
      collections = updatedCollections;
    });
  }

  @override
  void initState() {
    super.initState();

    _refreshCollections();
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Collection Manager', style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w400
                ),)
              ),
            ),
            Container(
              margin: const EdgeInsets.all(8),
              child: SearchBar(
                focusNode: _searchFocus,
                controller: _searchController,
                hintText: 'Search or create a new collection',
                autoFocus: true,
                onSubmitted: (value) {
                  _createCollection();
                },
                trailing: [
                  IconButton(
                    icon: const Icon(Icons.add_rounded),
                    onPressed: () {
                      _createCollection();
                    },
                  )
                ],
              ),
            ),
            Container(
              constraints: BoxConstraints(maxHeight: mediaQuery.size.height * 0.5),
              padding: const EdgeInsets.only(bottom: 10),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: collections.length,
                prototypeItem: CollectionCard(
                    collection: null,
                    shouldNullifySelectedUponDelete: () => false,
                    onCollectionSelected: (TfCollection? collection) {},
                    onDelete: () {}
                ),
                itemBuilder: (context, index) {
                  TfCollection collection = collections[index];
                  return CollectionCard(
                    key: ObjectKey(collection),
                    collection: collection,
                    shouldNullifySelectedUponDelete: () => widget.selectedCollection() == collection,
                    onCollectionSelected: (TfCollection? collection) {
                      widget.onCollectionSelected(collection);
                      _dismiss();
                    },
                    onDelete: () {
                      collection.delete();
                      setState(() {
                        collections = collections.where((element) => element != collection).toList();
                      });
                    }
                  );
                }
              )
            )
          ]
        )
      )
    );
  }

}

class CollectionCard extends StatefulWidget {

  final TfCollection? collection;
  final bool Function() shouldNullifySelectedUponDelete;
  final Function(TfCollection?) onCollectionSelected;
  final Function() onDelete;

  const CollectionCard({
    super.key,
    required this.collection,
    required this.shouldNullifySelectedUponDelete,
    required this.onCollectionSelected,
    required this.onDelete
  });

  @override
  State<CollectionCard> createState() => _CollectionCardState();

}

class _CollectionCardState extends State<CollectionCard> {

  Logger log = Logger('CollectionCard');
  String? name;
  bool hasSynced = false;
  bool starred = false;
  int toolCount = 0;
  int layoutCount = 0;
  DateTime createdAt = DateTime.now();
  DateTime lastUpdate = DateTime.now();

  @override
  void initState() {
    super.initState();

    syncMetadata();
  }

  void syncMetadata() async {
    Metadata metadata = await widget.collection?.getMetadata() ?? Metadata.empty();

    setState(() {
      name = metadata.name;
      createdAt = metadata.createdAt;
      lastUpdate = metadata.lastModified;

      hasSynced = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!hasSynced) {
      return const Card(
        margin: EdgeInsets.all(8),
        child: ListTile(
          title: Text('Loading...'),
          subtitle: Text('Please wait while we load the collection data'),
        )
      );
    }

    String lastChangedDescriptor = (lastUpdate.isAfter(createdAt)) ? 'Last Updated ' : 'Created ';
    TextStyle subtitleStyle = const TextStyle(fontSize: 12);

    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        onTap: () {
          widget.onCollectionSelected(widget.collection);
        },
        title: Text(name ?? 'Placeholder Name', style: const TextStyle(fontSize: 18)), // TODO null name condition
        subtitle: Row(
          children: [
            Text('Tools: $toolCount, Layouts: $layoutCount - ', style: subtitleStyle),
            TooltipRelativeDateText(
              prefix: lastChangedDescriptor,
              date: lastUpdate,
              style: subtitleStyle,
            )
          ]
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.delete_rounded),
              onPressed: () {
                if (widget.shouldNullifySelectedUponDelete()) {
                  widget.onCollectionSelected(null);
                }
                widget.onDelete();
              },
            )
          ]
        )
      )
    );
  }

}

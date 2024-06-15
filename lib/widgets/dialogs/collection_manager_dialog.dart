import 'package:flutter/material.dart';
import 'package:toolfoam/data/tf_collection.dart';
import 'package:logging/logging.dart';
import 'package:relative_time/relative_time.dart';

import '../../data/metadata.dart';

class CollectionManagerDialog extends StatefulWidget {

  const CollectionManagerDialog({super.key, required this.selectedCollection, required this.onCollectionSelected});
  final TFCollection? Function() selectedCollection;
  final ValueChanged<TFCollection?> onCollectionSelected;

  @override
  State<CollectionManagerDialog> createState() => _CollectionManagerDialogState();

}

class _CollectionManagerDialogState extends State<CollectionManagerDialog> {

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  List<TFCollection> collections = [];

  void _dismiss() {
    Navigator.of(context, rootNavigator: true).pop(context);
  }

  void _createCollection() async {
    TFCollection tfc = TFCollection(_searchController.text);
    await tfc.create();

    _searchController.clear();
    _searchFocus.requestFocus();
    _refreshCollections();
  }

  void _refreshCollections() {
    TFCollection.list().then((value) {
      setState(() {
        collections = value;
      });
    });
  }

  @override
  void initState() {
    super.initState();

    _refreshCollections();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
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
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      _createCollection();
                    },
                  )
                ],
              ),
            ),
            Column(
              children: collections.map((collection) => CollectionCard(
                collection: collection,
                shouldNullifySelectedUponDelete: () => widget.selectedCollection() == collection,
                onCollectionSelected: (TFCollection? collection) {
                widget.onCollectionSelected(collection);
                _dismiss();
              }, onDelete: () {
                collection.delete();
                setState(() {
                  collections = collections.where((element) => element != collection).toList();
                });
              })).toList()
            )
          ]
        )
      )
    );
  }

}

class CollectionCard extends StatefulWidget {

  final TFCollection collection;
  final bool Function() shouldNullifySelectedUponDelete;
  final Function(TFCollection?) onCollectionSelected;
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
    bool syncStarred = await widget.collection.isStarred();
    Metadata metadata = await widget.collection.getMetadata();

    setState(() {
      starred = syncStarred;
      createdAt = metadata.createdAt;
      lastUpdate = metadata.lastUpdate;

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

    String lastChangedDescriptor = (lastUpdate.isAfter(createdAt)) ? 'Last updated' : 'Created';

    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        onTap: () {
          widget.onCollectionSelected(widget.collection);
        },
        title: Text(widget.collection.name, style: const TextStyle(fontSize: 18)),
        subtitle: Text('Tools: $toolCount, Layouts: $layoutCount - $lastChangedDescriptor ${lastUpdate.relativeTime(context)}', style: const TextStyle(fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(onPressed: () {
              setState(() {
                if (starred) {
                  widget.collection.unstar();
                } else {
                  widget.collection.star();
                }
                starred = !starred;
              });
            }, icon: Icon((starred) ? Icons.star : Icons.star_border)),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                log.info("Deleting collection ${widget.collection.name}");
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

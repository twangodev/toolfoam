import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:toolfoam/pages/tool_editor_page.dart';
import 'package:toolfoam/widgets/containers/required_active_collection_container.dart';
import 'package:toolfoam/widgets/item_card.dart';
import 'package:toolfoam/widgets/toolbars/item_management_toolbar.dart';

import '../models/entity.dart';
import '../models/tf_collection.dart';
import '../models/tools/tf_tool.dart';
import '../widgets/breadcrumb.dart';
import '../widgets/dialogs/tool_details_dialog.dart';

class ToolsPage extends StatefulWidget {
  final List<BreadcrumbItem> breadcrumbItems;

  final TfCollection? selectedCollection;
  final Function(TfCollection?) onCollectionSelected;

  const ToolsPage(
      {super.key,
      required this.selectedCollection,
      required this.onCollectionSelected,
      required this.breadcrumbItems});

  @override
  State<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage> {
  static final Logger logger = Logger('ToolsPage');

  final GlobalKey _gridKey = GlobalKey();

  List<TfTool> tools = [];

  Future<void> refreshTools() async {
    logger.fine('Refreshing tools');
    List<TfTool>? updatedTools = await widget.selectedCollection?.listTools();

    setState(() {
      tools = updatedTools ?? [];
    });
  }

  void onAddTool() async {
    TfTool(uuid: Entity.uuidGenerator.v4(), owner: widget.selectedCollection!)
        .create('New Tool');
    await refreshTools();
  }

  void onTap(BuildContext context, TfTool tool) async {
    logger.info('Opening tool ${tool.uuid} (${tool.metadata.name})');
    await Navigator.push(context,
        MaterialPageRoute(builder: (context) => ToolEditorPage(tool: tool)));
    logger.info('Tool ${tool.uuid} (${tool.metadata.name}) closed');
    await refreshTools();
  }

  void renameTool(TfTool tool, String name) async {
    logger.fine('Renaming tool ${tool.uuid} to $name');
    tool.rename(name);
    await tool.push();
  }

  void onDelete(TfTool tool) async {
    logger.fine('Deleting tool ${tool.uuid} (${tool.metadata.name})');
    tool.delete();
    await refreshTools();
  }

  void onDetails(BuildContext context, TfTool tool) {
    showDialog(
        context: context, builder: (context) => ToolDetailsDialog(tool: tool));
  }

  @override
  void initState() {
    super.initState();
    refreshTools();
  }

  @override
  void didUpdateWidget(ToolsPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.selectedCollection != oldWidget.selectedCollection) {
      logger.fine('Selected collection changed, refreshing tools');
      refreshTools();
    }
  }

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
              child: Column(children: [
                ItemManagementToolbar(
                  title: 'Tools',
                  addItemTooltip: 'Add a new tool',
                  onAddFolder: () {
                    throw UnimplementedError(); // TODO
                  },
                  onAddItem: onAddTool,
                ),
                Expanded(
                    child: ListView(shrinkWrap: true, children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tools.length,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 500,
                      childAspectRatio: 16 / 9,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      TfTool tool = tools[index];
                      return ItemCard(
                        key: ObjectKey(tool),
                        name: tool.metadata.name ?? 'Unnamed Tool',
                        preview: null,
                        onTap: () {
                          onTap(context, tool);
                        },
                        onRename: (String name) {
                          renameTool(tool, name);
                        },
                        onDetails: () {
                          onDetails(context, tool);
                        },
                        onDelete: () {
                          onDelete(tool);
                        },
                      );
                    },
                  )
                ]))
              ]),
            )));
  }
}

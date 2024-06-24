import 'package:flutter/material.dart';
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

  final TFCollection? selectedCollection;
  final Function(TFCollection?) onCollectionSelected;

  const ToolsPage({super.key, required this.selectedCollection, required this.onCollectionSelected, required this.breadcrumbItems});

  @override
  State<ToolsPage> createState() => _ToolsPageState();

}

class _ToolsPageState extends State<ToolsPage> {

  List<TFTool> tools = [];

  void refreshTools() async {
    List<TFTool>? updatedTools = await widget.selectedCollection?.listTools();

    setState(() {
      tools = updatedTools ?? [];
    });
  }

  void onAddTool() {
    TFTool(uuid: Entity.uuidGenerator.v4(), owner: widget.selectedCollection!).create('New Tool');
    refreshTools();
  }

  void onTap(BuildContext context, TFTool tool) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ToolEditorPage(breadcrumbItems: widget.breadcrumbItems,))
    );
  }

  void renameTool(BuildContext context, TFTool tool, String name) {
    tool.rename(name);
    tool.push();
  }

  void onDelete(TFTool tool) {
    tool.delete();
    refreshTools();
  }

  void onDetails(BuildContext context, TFTool tool) {
    showDialog(context: context, builder: (context) => ToolDetailsDialog(tool: tool));
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
          child: Column(
            children: [
              ItemManagementToolbar(
                title: 'Tools',
                addItemTooltip: 'Add a new tool',
                onAddFolder: () {
                  throw UnimplementedError();
                },
                onAddItem: onAddTool,
              ),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: tools.length,
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 500,
                        childAspectRatio: 16/9,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        TFTool tool = tools[index];
                        return ItemCard(
                          name: tool.metadata.name ?? 'Unnamed Tool',
                          preview: null,
                          onTap: () { onTap(context, tool); },
                          onRename: (String name) { renameTool(context, tool, name); },
                          onDetails: () { onDetails(context, tool); },
                          onDelete: () { onDelete(tool); },
                        );
                      },
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
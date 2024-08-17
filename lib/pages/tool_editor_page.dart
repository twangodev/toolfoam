import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:toolfoam/models/tf_tool.dart';
import 'package:toolfoam/widgets/breadcrumb.dart';
import 'package:toolfoam/widgets/editor/editor.dart';

class ToolEditorPage extends StatefulWidget {
  final TfTool tool;

  const ToolEditorPage({super.key, required this.tool});

  @override
  State<ToolEditorPage> createState() => _ToolEditorPageState();
}

class _ToolEditorPageState extends State<ToolEditorPage> {
  final Logger logger = Logger('toolfoam.pages.tool_editor_page');

  String? name;

  void onRename(String newName) {
    logger.fine('Renaming tool to $newName');
    setState(() {
      name = newName;
    });

    widget.tool.rename(newName);
    widget.tool.push();
  }

  @override
  void initState() {
    super.initState();

    name = widget.tool.metadata.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Breadcrumb(items: [
        RenameableBreadcrumbItem(text: name, onRename: onRename)
      ])),
      body: Center(
        child: Editor(tool: widget.tool),
      ),
    );
  }
}

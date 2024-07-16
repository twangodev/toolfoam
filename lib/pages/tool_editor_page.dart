import 'package:flutter/material.dart';
import 'package:toolfoam/models/tools/tf_tool.dart';
import 'package:toolfoam/widgets/breadcrumb.dart';
import 'package:toolfoam/widgets/editor/tf_editor.dart';

class ToolEditorPage extends StatefulWidget {

  final TFTool tool;

  const ToolEditorPage({super.key, required this.tool});

  @override
  State<ToolEditorPage> createState() => _ToolEditorPageState();

}

class _ToolEditorPageState extends State<ToolEditorPage> {

  String? name;

  void onRename(String newName) {
    setState(() {
      name = newName;
    });

    widget.tool.rename(newName);
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
        title: Breadcrumb(items: [RenameableBreadcrumbItem(text: name, onRename: onRename)])
      ),
      body: Center(
        child: TFEditor(tool: widget.tool),
      ),
    );
  }

}

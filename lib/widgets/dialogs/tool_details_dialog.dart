import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:relative_time/relative_time.dart';
import 'package:toolfoam/models/tools/tf_tool.dart';
import 'package:toolfoam/widgets/text/tooltip_date/tooltip_relative_date_text.dart';

class ToolDetailsDialog extends StatelessWidget {

  final TFTool tool;

  const ToolDetailsDialog({super.key, required this.tool});

  void dismiss(BuildContext context) {
    Navigator.of(context).pop();
  }

  void save(BuildContext context) {
    dismiss(context);
  }

  @override
  Widget build(BuildContext context) {

    TextStyle timingMetadataTextStyle = TextStyle(
      color: Theme.of(context).colorScheme.secondary,
      fontSize: 12,
    );

    return AlertDialog(
      title: const Text('Tool Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Row(
              children: [
                TooltipRelativeDateText(
                  prefix: 'Created: ',
                  date: tool.metadata.createdAt,
                  style: timingMetadataTextStyle
                ),
                const SizedBox(width: 8),
                TooltipRelativeDateText(
                  prefix: 'Updated: ',
                  date: tool.metadata.lastModified,
                  style: timingMetadataTextStyle
                ),
              ],
            )
          )
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () { dismiss(context); },
          child: const Text('Close'),
        ),
      ],
    );
  }

}
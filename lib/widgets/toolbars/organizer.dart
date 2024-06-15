import 'package:flutter/material.dart';

class Organizer extends StatelessWidget {

  final String title;
  final String addItemTooltip;
  final Function() onAddFolder;
  final Function() onAddItem;

  const Organizer({
    super.key,
    required this.title,
    required this.addItemTooltip,
    required this.onAddFolder,
    required this.onAddItem
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Text(title, style: const TextStyle(fontSize: 24)),
              Expanded(child: Container()),
              Tooltip(
                message: 'Add a new folder',
                child: IconButton(
                  icon: const Icon(Icons.create_new_folder_rounded),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: colorScheme.onSecondary, backgroundColor: colorScheme.secondary
                  ),
                  onPressed: onAddFolder,
                )
              ),
              const SizedBox(width: 8),
              Tooltip(
                message: addItemTooltip,
                child: IconButton(
                  icon: const Icon(Icons.add_rounded),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: colorScheme.onPrimary, backgroundColor: colorScheme.primary
                  ),
                  onPressed: onAddItem,
                )
              )
            ]
          ),
          const Divider()
        ],
      )
    );

  }
}
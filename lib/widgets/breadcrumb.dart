import 'package:flutter/material.dart';
import 'package:toolfoam/widgets/renameable_title.dart';

class Breadcrumb extends StatelessWidget {

  final List<BreadcrumbItem> items;

  const Breadcrumb({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    for (int i = 0; i < items.length; i++) {
      children.add(items[i].build(i));
      if (i < items.length - 1) {
        children.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.chevron_right)
          )
        );
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }

}

abstract class BreadcrumbItem {

  static TextStyle textStyle = const TextStyle(fontSize: 20);

  final String text;
  Widget build(int position);

  const BreadcrumbItem({required this.text});

}

class TextBreadcrumbItem extends BreadcrumbItem {
  final VoidCallback? onTap;

  const TextBreadcrumbItem({required super.text, this.onTap});

  @override
  Widget build(int position) {
    FontWeight weight;
    if (position == 0) {
      weight = FontWeight.w500;
    } else {
      weight = FontWeight.w400;
    }

    return GestureDetector(
      onTap: onTap,
      child: Text(text, style: TextStyle(fontSize: 20, fontWeight: weight)),
    );
  }

}

class RenameableBreadcrumbItem extends BreadcrumbItem {

  final void Function(String text) onRename;

  const RenameableBreadcrumbItem({required super.text, required this.onRename});

  @override
  Widget build(int position) {
    return RenameableTitle(
      title: text,
      onRename: onRename,
      style: BreadcrumbItem.textStyle,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

}

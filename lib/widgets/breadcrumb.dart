import 'package:flutter/material.dart';

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
      crossAxisAlignment: CrossAxisAlignment.end,
      children: children,
    );
  }

}

class BreadcrumbItem {
  final String text;
  final Function() onTap;

  const BreadcrumbItem({required this.text, required this.onTap});

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


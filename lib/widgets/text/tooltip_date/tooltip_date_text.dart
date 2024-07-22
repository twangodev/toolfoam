import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TooltipDateText extends StatelessWidget {
  final DateTime date;
  final Text? child;

  static DateFormat dateFormat = DateFormat('EEEE, MMMM d, y h:mm a');

  const TooltipDateText({super.key, required this.date, this.child});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: dateFormat.format(date),
      child: child,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:relative_time/relative_time.dart';
import 'package:toolfoam/widgets/text/tooltip_date/tooltip_date_text.dart';

class TooltipRelativeDateText extends StatelessWidget {

  final DateTime date;
  final TextStyle? style;
  final String? prefix;
  final String? suffix;

  const TooltipRelativeDateText({super.key, required this.date, this.style, this.prefix, this.suffix});

  @override
  Widget build(BuildContext context) {
    String prefix = this.prefix ?? '';
    String suffix = this.suffix ?? '';
    return TooltipDateText(
      date: date,
      child: Text(prefix + date.relativeTime(context) + suffix, style: style)
    );
  }

}
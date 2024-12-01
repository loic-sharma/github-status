import 'package:flutter/widgets.dart';

class IssueLabel extends StatelessWidget {
  const IssueLabel({
    super.key,
    required this.name,
    required this.color,
  });

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final hsl = HSLColor.fromColor(color);
    final lighterColor = hsl
      .withLightness((hsl.lightness * 3.0).clamp(0.0, 1.0))
      .toColor();
    final darkerColor = hsl
      .withLightness((hsl.lightness * 0.5).clamp(0.0, 1.0))
      .toColor();

    return Container(
      decoration: BoxDecoration(
        color: darkerColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: color,
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 2.0,
        horizontal: 8.0,
      ),
      child: Text(
        name,
        style: TextStyle(color: lighterColor),
      ),
    );
  }
}

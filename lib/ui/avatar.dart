import 'package:flutter/widgets.dart';

import 'link.dart';

class AvatarIcon extends StatelessWidget {
  const AvatarIcon({
    super.key,
    required this.iconUri,
    required this.userUri,
    double? size,
  }) : size = size ?? 12.0;

  final Uri iconUri;
  final Uri userUri;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Link(
      uri: userUri,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox.fromSize(
          size: const Size.fromRadius(12),
          child: Image.network(
            iconUri.toString(),
            fit: BoxFit.cover,
            width: size,
            height: size,
          ),
        ),
      ),
    );
  }
}

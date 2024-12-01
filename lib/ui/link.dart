
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

GestureRecognizer linkRecognizer({required Uri url}) {
  return TapGestureRecognizer()..onTap = () {
    launchUrl(url);
  };
}

class Link extends StatelessWidget {
  const Link({
    super.key,
    required this.uri,
    required this.child,
  });

  final Uri uri;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => launchUrl(uri),
        child: child,
      ),
    );
  }
}

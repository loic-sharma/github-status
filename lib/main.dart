
import 'package:context_watch/context_watch.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'foundation/timeago.dart';
import 'screens/home/home.dart';

void main() async {
  registerTimeago();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ContextWatch.root(
      child: ShadApp(
        theme: ShadThemeData(
          brightness: Brightness.light,
          colorScheme: const ShadZincColorScheme.light(),
          // Example with google fonts
          // textTheme: ShadTextTheme.fromGoogleFont(GoogleFonts.poppins),

          // Example of custom font family
          // textTheme: ShadTextTheme(family: 'UbuntuMono'),

          // Example to disable the secondary border
          // disableSecondaryBorder: true,
        ),
        darkTheme: ShadThemeData(
          brightness: Brightness.dark,
          colorScheme: const ShadZincColorScheme.dark(),
          // Example of custom font family
          // textTheme: ShadTextTheme(family: 'UbuntuMono'),
        ),

        home: const Home(),
      ),
    );
  }
}


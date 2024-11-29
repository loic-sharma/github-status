
import 'package:context_watch/context_watch.dart';
import 'package:flutter/material.dart';
import 'package:gh_status/github.dart' as github;
import 'package:gh_status/src/screens/inbox.dart';
import 'package:gh_status/src/screens/login.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'src/config.dart';
import 'src/foundation/timeago.dart';
import 'src/screens/login/device_flow.dart';

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

        home: MyAppHome(),
      ),
    );
  }
}

class MyAppHome extends StatefulWidget {
  const MyAppHome({super.key});

  @override
  State<MyAppHome> createState() => _MyAppHomeState();
}

class _MyAppHomeState extends State<MyAppHome> {
  late PageModel model;

  @override
  void initState() {
    super.initState();

    model = LoginPageModel(
      DeviceFlowModel.run(
        Config.githubClientId,
        Config.githubClientSecret,
        onCompleted: _onLogin,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return switch (model) {
      LoginPageModel(: final deviceFlowModel) => Login(model: deviceFlowModel),

      InboxPageModel(: final yoursModel, : final followingModel) => Inbox(
        yours: yoursModel,
        following: followingModel,
      ),
    };
  }

  void _onLogin(String accessToken) {
    if (!mounted) return;

    setState(() {
      final client = github.GitHub(token: accessToken);
      model = InboxPageModel(
        client: client,
        yoursModel: createYoursModel(client),
        followingModel: createFollowingModel(client),
      );
    });
  }
}

sealed class PageModel {
  const PageModel();
}

class LoginPageModel extends PageModel {
  const LoginPageModel(this.deviceFlowModel);

  final DeviceFlowModel deviceFlowModel;
}

class InboxPageModel extends PageModel {
  const InboxPageModel({
    required this.client,
    required this.yoursModel,
    required this.followingModel,
  });

  final github.GitHub client;
  final YoursTab yoursModel;
  final FollowingTab followingModel;
}

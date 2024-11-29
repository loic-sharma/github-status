import 'package:flutter/widgets.dart';
import 'package:gh_status/github.dart' as github;

import '../../config.dart';
import '../inbox/logic.dart';
import '../inbox/models.dart';
import '../inbox/ui/inbox.dart';
import '../login/device_flow.dart';
import '../login/ui/login.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
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

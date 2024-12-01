import 'package:flutter/widgets.dart';
import 'package:gh_status/github/github.dart' as github;

import '../inbox/logic.dart';
import '../inbox/models.dart';
import '../inbox/ui/inbox.dart';
import '../login/login.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  _PageModel model = const _LoginPageModel();

  @override
  Widget build(BuildContext context) {
    return switch (model) {
      _LoginPageModel _ => Login(onLogin: _onLogin),

      _InboxPageModel model => Inbox(
        client: model.client,
        yours: model.yoursModel,
        following: model.followingModel,
      ),
    };
  }

  void _onLogin(String accessToken) {
    if (!mounted) return;

    setState(() {
      final client = github.GitHub(token: accessToken);
      model = _InboxPageModel(
        client: client,
        yoursModel: createYoursModel(client),
        followingModel: createFollowingModel(client),
      );
    });
  }
}

sealed class _PageModel {
  const _PageModel();
}

class _LoginPageModel extends _PageModel {
  const _LoginPageModel();
}

class _InboxPageModel extends _PageModel {
  const _InboxPageModel({
    required this.client,
    required this.yoursModel,
    required this.followingModel,
  });

  final github.GitHub client;
  final YoursTab yoursModel;
  final FollowingTab followingModel;
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:gh_status/foundation.dart';

class SettingsModel {

  SettingsModel()
    : profile = ValueNotifier(
        AsyncValue.data(
          ProfileModel(
            name: 'Loïc Sharma',
            login: 'loic-sharma',
            avatar: Uri.parse('https://avatars.githubusercontent.com/u/737941?v=4'),
            uri: Uri.parse('https://github.com/loic-sharma'),
          ),
        ),
      ),
      following = [
        GitHubUser('loic-sharma'),
        GitHubUser('loic-sharma'),
        GitHubUser('loic-sharma'),
      ]
  {}

  final AsyncValueListenable<ProfileModel> profile;

  final List<GitHubUser> following;


  void logout() {}

  void follow(String githubLogin) {
    following.add(GitHubUser(githubLogin));
  }
}

class ProfileModel with ChangeNotifier {
  ProfileModel({
    required this.name,
    required this.login,
    required this.avatar,
    required this.uri,
  });

  final String name;
  final String login;
  final Uri avatar;
  final Uri uri;
}

class GitHubUser with ChangeNotifier {
  GitHubUser(String login)
    : _login = login,
      _uri = Uri.parse('https://github.com/$login'),
      _avatar = AsyncValue.loading() {
    unawaited(_loadAvatar());
  }

  String get login => _login;
  String _login;

  Uri get uri => _uri;
  Uri _uri;

  AsyncValue<Uri> get avatar => _avatar;
  AsyncValue<Uri> _avatar;

  Future<void> update(String login) async {
    if (login == _login) {
      return;
    }

    _login = login;
    _uri = Uri.parse('https://github.com/$login');
    _avatar = AsyncValue.loading();
    notifyListeners();

    await _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    await Future.delayed(const Duration(seconds: 3));
    _avatar = AsyncValue.data(Uri.parse('https://avatars.githubusercontent.com/u/737941?v=4'));
    notifyListeners();
  }
}

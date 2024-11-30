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
      following = FollowingModel();

  final AsyncValueListenable<ProfileModel> profile;

  final FollowingModel following;

  void logout() {}
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

class FollowingModel with ChangeNotifier {
  FollowingModel() {
    _users[0] = ViewUser(model: this, id: 0, login: 'loic-sharma');
    _users[1] = ViewUser(model: this, id: 1, login: 'loic-sharma');
    _users[2] = ViewUser(model: this, id: 2, login: 'loic-sharma');
    _nextId = 3;
  }

  int _nextId = 0;

  Iterable<FollowedUser> get users => _users.values;
  final Map<int, FollowedUser> _users = {};

  void addUser() {
    final model = AddUser(model: this, id: _nextId);
    _users[_nextId] = model;
    _nextId += 1;
    notifyListeners();
  }

  void _edit(int id) {
    assert(_users.containsKey(id));

    if (_users[id] case ViewUser(: final login)) {
      _users[id] = EditUser(model: this, id: id, initialLogin: login);
      notifyListeners();
      return;
    }

    assert(false);
  }

  void _delete(int id) {
    assert(_users.containsKey(id));
    assert(_users[id] is ViewUser);

    _users.remove(id);
    notifyListeners();
  }

  void _save(int id, String login) {
    assert(_users.containsKey(id));
    assert(_users[id] is AddUser || _users[id] is EditUser);

    _users[id] = ViewUser(model: this, id: id, login: login);
    notifyListeners();
  }

  void _cancel(int id) {
    assert(_users.containsKey(id));

    if (_users[id] is AddUser) {
      _users.remove(id);
      notifyListeners();
      return;
    }

    if (_users[id] case EditUser(: final initialLogin)) {
      _users[id] = ViewUser(model: this, id: id, login: initialLogin);
      notifyListeners();
      return;
    }

    assert(false);
  }
}

typedef SaveUserCallback = void Function(String login);

sealed class FollowedUser {
  const FollowedUser();
}

class AddUser extends FollowedUser {
  const AddUser({
    required FollowingModel model,
    required int id,
  }) : _model = model,
       _id = id;

  final FollowingModel _model;
  final int _id;

  void save(String login) => _model._save(_id, login);
  void cancel() => _model._cancel(_id);
}

class EditUser extends FollowedUser {
  EditUser({
    required FollowingModel model,
    required int id,
    required this.initialLogin,
  }) : _model = model,
      _id = id;

  final FollowingModel _model;
  final int _id;

  final String initialLogin;

  void save(String login) => _model._save(_id, login);
  void cancel() => _model._cancel(_id);
}

class ViewUser extends FollowedUser {
  ViewUser({
    required FollowingModel model,
    required int id,
    required this.login,
  }) : _model = model,
       _id = id,
       profileUri = Uri.parse('https://github.com/$login'),
       avatarUri = Uri.parse('https://avatars.githubusercontent.com/u/737941?v=4');

  final FollowingModel _model;
  final int _id;

  final String login;
  final Uri profileUri;
  final Uri avatarUri;

  void edit() => _model._edit(_id);
  void delete() => _model._delete(_id);
}

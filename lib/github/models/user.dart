class User {
  const User({
    required this.login,
    required this.name,
    required this.avatarUrl,
    required this.url
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      login: json['login'],
      name: json['name'],
      avatarUrl: Uri.parse(json['avatar_url']),
      url: Uri.parse(json['html_url']),
    );
  }

  final String login;
  final String name;
  final Uri avatarUrl;
  final Uri url;
}

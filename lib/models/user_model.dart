class User {
  final String id;
  final String username;
  final String email;
  final String password;
  final String? githubUsername;
  final String? githubAvatarUrl; // NOVO CAMPO

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    this.githubUsername,
    this.githubAvatarUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'github_username': githubUsername,
      'github_avatar_url': githubAvatarUrl, // Mapeia para o banco
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      password: map['password'],
      githubUsername: map['github_username'],
      githubAvatarUrl: map['github_avatar_url'],
    );
  }
  
  User copyWith({String? githubUsername, String? githubAvatarUrl}) {
    return User(
      id: id,
      username: username,
      email: email,
      password: password,
      githubUsername: githubUsername ?? this.githubUsername,
      githubAvatarUrl: githubAvatarUrl ?? this.githubAvatarUrl,
    );
  }
}
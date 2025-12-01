class User {
  final String id;
  final String username;
  final String email;
  final String password;
  final String? githubUsername; // Novo campo opcional

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    this.githubUsername,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'github_username': githubUsername, // Mapeando para o banco
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      password: map['password'],
      githubUsername: map['github_username'],
    );
  }
  
  // Método auxiliar para criar uma cópia do usuário com dados novos
  User copyWith({String? githubUsername}) {
    return User(
      id: id,
      username: username,
      email: email,
      password: password,
      githubUsername: githubUsername ?? this.githubUsername,
    );
  }
}
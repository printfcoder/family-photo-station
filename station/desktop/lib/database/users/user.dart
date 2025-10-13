class User {
  final int? id;
  final String username;
  final String? displayName;
  final bool isAdmin;
  final String? passwordHash;
  final int createdAt; // unix ms

  User({
    this.id,
    required this.username,
    this.displayName,
    required this.isAdmin,
    this.passwordHash,
    required this.createdAt,
  });

  factory User.fromRow(Map<String, Object?> row) {
    return User(
      id: row['id'] as int?,
      username: row['username'] as String,
      displayName: row['display_name'] as String?,
      isAdmin: (row['is_admin'] as int) == 1,
      passwordHash: row['password_hash'] as String?,
      createdAt: row['created_at'] as int,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'username': username,
        'display_name': displayName,
        'is_admin': isAdmin ? 1 : 0,
        'password_hash': passwordHash,
        'created_at': createdAt,
      };
}
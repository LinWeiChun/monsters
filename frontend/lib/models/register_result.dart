class RegisterResult {
  const RegisterResult({
    required this.userId,
    required this.email,
    required this.userName,
  });

  factory RegisterResult.fromJson(Map<String, dynamic> json) {
    return RegisterResult(
      userId: json['userId'] as int,
      email: json['email'] as String,
      userName: json['userName'] as String,
    );
  }

  final int userId;
  final String email;
  final String userName;
}

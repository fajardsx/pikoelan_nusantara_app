class LoginPayload {
  final String email;
  final String password;

  LoginPayload({required this.email, required this.password});

  factory LoginPayload.fromJson(Map<String, dynamic> json) {
    return LoginPayload(email: json['email'] ?? '', password: json['password'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {"email": email, "password": password};
  }
}

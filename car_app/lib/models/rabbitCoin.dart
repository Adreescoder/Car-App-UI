class RabbitCoin {
  String name;
  String email;
  String password;
  DateTime createdAt;

  // Constructor
  RabbitCoin({
    required this.name,
    required this.email,
    required this.password,
    required this.createdAt,
  });

  // Convert RabbitCoin object to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create RabbitCoin object from JSON
  factory RabbitCoin.fromJson(Map<String, dynamic> json) {
    return RabbitCoin(
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class Employee {
  final String id;
  String name;
  String role;
  String department;
  String email;
  String password;

  Employee({
    required this.id,
    required this.name,
    required this.role,
    required this.department,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'department': department,
      'email': email,
      'password': password,
    };
  }

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'],
      name: map['name'],
      role: map['role'],
      department: map['department'],
      email: map['email'],
      password: map['password'] ?? '',
    );
  }
}

class Member {
  final int id;
  final String firstName;
  final String lastName;
  final String phone1;
  final String? phone2;

  Member({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone1,
    this.phone2,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phone1: json['phone1'],
      phone2: json['phone2'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'phone1': phone1,
      'phone2': phone2,
    };
  }
}

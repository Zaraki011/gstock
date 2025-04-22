class Borrow {
  final int id;
  final int componentId;       // Store the ID
  final String componentName;  // Store the name
  final int memberId;          // Store the ID
  final String memberName;     // Store the name
  final int quantity;
  final String borrowDate;
  final String? returnDate;
  final String? returnCondition;

  Borrow({
    required this.id,
    required this.componentId,
    required this.componentName,
    required this.memberId,
    required this.memberName,
    required this.quantity,
    required this.borrowDate,
    this.returnDate,
    this.returnCondition,
  });

  factory Borrow.fromJson(Map<String, dynamic> json) {
    return Borrow(
      id: json['id'],
      componentId: json['component'],
      componentName: json['component_name'] ?? '',
      memberId: json['member'],
      memberName: json['member_name'] ?? '',
      quantity: json['quantity'],
      borrowDate: json['borrow_date'],
      returnDate: json['return_date'],
      returnCondition: json['return_condition'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'component': componentId,
      'member': memberId,
      'quantity': quantity,
      'borrow_date': borrowDate,
      'return_date': returnDate,
      'return_condition': returnCondition,
    };
  }

  // Add this for compatibility with existing code
  bool get isReturned => returnDate != null;
}
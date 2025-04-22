class Component {
  final int id;
  final String name;
  final int quantity;
  final String acquisitionDate;
  final String categoryName;

  Component({required this.id, required this.name, required this.quantity, required this.acquisitionDate, required this.categoryName});

  factory Component.fromJson(Map<String, dynamic> json) {
    return Component(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'],
      acquisitionDate: json['acquisition_date'],
      categoryName: json['category_name'],
    );
  }
}

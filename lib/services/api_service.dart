import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/component.dart';
import '../models/category.dart';
import '../models/member.dart';
import '../models/borrow.dart';

class ApiService {
  static const baseUrl = "http://127.0.0.1:8000/api/";

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Components
  Future<List<Component>> getComponents() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${baseUrl}components/'),
      headers: headers,
    );

    print("Components response: ${response.statusCode}");

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Component.fromJson(json)).toList();
    } else {
      print("Failed to load components: ${response.body}");
      throw Exception('Failed to load components');
    }
  }

  Future<Component> createComponent(Map<String, dynamic> data) async {
    // Make sure to send category_id, not category_name
    final headers = await _getHeaders();
    print("Creating component with data: $data");

    final response = await http.post(
      Uri.parse('${baseUrl}components/'),
      headers: headers,
      body: json.encode(data),
    );

    print(
      "Create component response: ${response.statusCode}, ${response.body}",
    );

    if (response.statusCode == 201) {
      return Component.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create component: ${response.body}');
    }
  }

  Future<void> deleteComponent(int id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('${baseUrl}components/$id/'),
      headers: headers,
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete component: ${response.body}');
    }
  }

  Future<Component> updateComponent(int id, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('${baseUrl}components/$id/'),
      headers: headers,
      body: json.encode(data),
    );
    if (response.statusCode == 200) {
      return Component.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update component: ${response.body}');
    }
  }

  // Categories
  Future<List<Category>> getCategories() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${baseUrl}categories/'),
      headers: headers,
    );

    print("Categories response: ${response.statusCode}");

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Category.fromJson(json)).toList();
    } else {
      print("Failed to load categories: ${response.body}");
      throw Exception('Failed to load categories');
    }
  }

  Future<Category> createCategory(Map<String, dynamic> data) async {
    // Only send name, not description
    final headers = await _getHeaders();
    final Map<String, dynamic> categoryData = {'name': data['name']};

    print("Creating category with data: $categoryData");

    final response = await http.post(
      Uri.parse('${baseUrl}categories/'),
      headers: headers,
      body: json.encode(categoryData),
    );

    print("Create category response: ${response.statusCode}, ${response.body}");

    if (response.statusCode == 201) {
      return Category.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create category: ${response.body}');
    }
  }

  Future<void> deleteCategory(int id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('${baseUrl}categories/$id/'),
      headers: headers,
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete component: ${response.body}');
    }
  }

  // Members
  Future<List<Member>> getMembers() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${baseUrl}members/'),
      headers: headers,
    );

    print("Members response: ${response.statusCode}");

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Member.fromJson(json)).toList();
    } else {
      print("Failed to load members: ${response.body}");
      throw Exception('Failed to load members');
    }
  }

  Future<Member> createMember(Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    
    print("Creating member with data: $data");
    
    final response = await http.post(
      Uri.parse('${baseUrl}members/'),
      headers: headers,
      body: json.encode({
        'first_name': data['firstName'],
        'last_name': data['lastName'],
        'phone1': data['phone1'],
        'phone2': data['phone2'] ?? '',
      }),
    );

    print("Create member response: ${response.statusCode}, ${response.body}");
    
    if (response.statusCode == 201) {
      return Member.fromJson(json.decode(response.body));
    } else {
        throw Exception('Failed to create member: ${response.body}');
    }
  }

  // Borrows
  Future<List<Borrow>> getBorrows() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${baseUrl}borrows/'),
      headers: headers,
    );

    print("Borrows response: ${response.statusCode}");

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Borrow.fromJson(json)).toList();
    } else {
      print("Failed to load borrows: ${response.body}");
      throw Exception('Failed to load borrows');
    }
  }

  Future<Borrow> createBorrow(Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    print("Creating borrow with data: $data");

    final response = await http.post(
      Uri.parse('${baseUrl}borrows/'),
      headers: headers,
      body: json.encode(data),
    );

    print("Create borrow response: ${response.statusCode}, ${response.body}");

    if (response.statusCode == 201) {
      return Borrow.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create borrow: ${response.body}');
    }
  }

  Future<Borrow> returnBorrow(
    int id,
    String returnDate, {
    String? condition = 'intact',
  }) async {
    final headers = await _getHeaders();

    final returnData = {
      'return_date': returnDate,
      'return_condition': condition ?? 'intact', // Include return condition now
    };

    print("Returning borrow with data: $returnData");

    final response = await http.patch(
      Uri.parse('${baseUrl}borrows/$id/'),
      headers: headers,
      body: json.encode(returnData),
    );

    print("Return borrow response: ${response.statusCode}, ${response.body}");

    if (response.statusCode == 200) {
      return Borrow.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to return borrow: ${response.body}');
    }
  }
}

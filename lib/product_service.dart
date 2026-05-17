import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ProductService {
  static String get baseUrl => AuthService.baseUrl;

  // Get all products
  static Future<List<Map<String, dynamic>>> getProducts() async {
    final url = Uri.parse('$baseUrl/api/products');
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to backend: $e');
    }
  }

  // Get single product details
  static Future<Map<String, dynamic>?> getProductById(String id) async {
    final url = Uri.parse('$baseUrl/api/products/$id');
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(response.body));
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Failed to get product details: $e');
    }
  }

  // Create a new product
  static Future<Map<String, dynamic>> createProduct({
    required String name,
    required double price,
    required String description,
    required String category,
    required String image,
    required List<String> colors,
    required bool inStock,
  }) async {
    final url = Uri.parse('$baseUrl/api/products');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'price': price,
          'description': description,
          'category': category,
          'image': image,
          'colors': colors,
          'inStock': inStock,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Product created successfully!',
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? responseData['error'] ?? 'Failed to create product',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to connect to backend: $e',
      };
    }
  }
}

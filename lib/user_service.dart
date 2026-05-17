import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class UserService {
  static String get baseUrl => AuthService.baseUrl;

  // Get authorization headers
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // --- FAVORITES APIs ---

  // Get favorites list
  static Future<List<Map<String, dynamic>>> getFavorites() async {
    final url = Uri.parse('$baseUrl/api/user/favorites');
    final headers = await _getHeaders();
    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // Toggle favorite status on a product
  static Future<List<dynamic>> toggleFavorite(String productId) async {
    final url = Uri.parse('$baseUrl/api/user/favorites/$productId');
    final headers = await _getHeaders();
    try {
      final response = await http.post(url, headers: headers);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data;
        } else if (data is Map && data['favorites'] != null) {
          return data['favorites'] as List;
        }
      }
    } catch (_) {}
    return [];
  }

  // --- CART APIs ---

  // Get shopping cart
  static Future<List<Map<String, dynamic>>> getCart() async {
    final url = Uri.parse('$baseUrl/api/user/cart');
    final headers = await _getHeaders();
    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // Add or update cart item
  static Future<List<Map<String, dynamic>>> addToCart(String productId, int quantity) async {
    final url = Uri.parse('$baseUrl/api/user/cart');
    final headers = await _getHeaders();
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          'productId': productId,
          'quantity': quantity,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      }
    } catch (_) {}
    return [];
  }

  // Update quantity of an item in cart
  static Future<List<Map<String, dynamic>>> updateCartQuantity(String productId, int quantity) async {
    return addToCart(productId, quantity);
  }

  // Remove item from cart
  static Future<List<Map<String, dynamic>>> removeFromCart(String productId) async {
    final url = Uri.parse('$baseUrl/api/user/cart/$productId');
    final headers = await _getHeaders();
    try {
      final response = await http.delete(url, headers: headers);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      }
    } catch (_) {}
    return [];
  }
}

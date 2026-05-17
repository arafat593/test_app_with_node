import 'package:flutter/material.dart';
import 'product_service.dart';
import 'user_service.dart';
import 'auth_service.dart';

class AppData extends ChangeNotifier {
  // Singleton pattern
  static final AppData _instance = AppData._internal();
  factory AppData() => _instance;
  AppData._internal() {
    fetchProducts(showLoader: true);
    loadUserProfile();
  }

  bool isLoading = false;
  String? errorMessage;
  Map<String, dynamic>? userProfile;

  Future<void> loadUserProfile() async {
    try {
      // 1. Load cached user from SharedPreferences first for instant UI response
      final cached = await AuthService.getCurrentUser();
      if (cached != null) {
        userProfile = cached;
        notifyListeners();
      }
      
      // 2. Fetch fresh live profile from backend asynchronously
      final fresh = await AuthService.getUserProfile();
      if (fresh['success'] == true && fresh['data'] != null) {
        userProfile = fresh['data'];
        notifyListeners();
      }
    } catch (_) {}
  }
  
  // Keep standard mock colors to map dynamic products to background color accents
  static const List<Color> curatedColors = [
    Color(0xFF667EEA),
    Color(0xFF764BA2),
    Color(0xFFF093FB),
    Color(0xFF5EE7DF),
    Color(0xFFB490CA),
    Color(0xFF4A00E0),
  ];

  List<Map<String, dynamic>> products = [];
  final List<Map<String, dynamic>> cartItems = [];

  Future<void> fetchProducts({bool showLoader = false}) async {
    if (products.isEmpty || showLoader) {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
    }

    try {
      final fetched = await ProductService.getProducts();
      
      // Map and assign the fetched database products directly
      products = fetched.asMap().entries.map((entry) {
        final index = entry.key;
        final p = Map<String, dynamic>.from(entry.value);
        
        p['color'] = curatedColors[index % curatedColors.length];
        p['icon'] = _getIconForCategory(p['category']);
        
        final existing = products.firstWhere(
          (e) => e['_id'] == p['_id'] || e['name'] == p['name'], 
          orElse: () => <String, dynamic>{}
        );
        p['isFavorite'] = existing['isFavorite'] ?? false;
        
        return p;
      }).toList();
      
      // Stop the visual loader immediately so products render instantly!
      isLoading = false;
      notifyListeners();

      // Synchronize backend states (favorites, cart) in parallel in the background
      Future.wait([
        syncFavoritesWithBackend(),
        syncCartWithBackend(),
      ]).catchError((_) => []);
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  // Sync favorites state from backend
  Future<void> syncFavoritesWithBackend() async {
    try {
      final backendFavorites = await UserService.getFavorites();
      final Set<String> favoriteIds = {};
      
      for (final fav in backendFavorites) {
        final id = fav['_id']?.toString();
        if (id != null) {
          favoriteIds.add(id);
        }
      }
      
      for (var i = 0; i < products.length; i++) {
        final pid = products[i]['_id'];
        if (pid != null && favoriteIds.contains(pid.toString())) {
          products[i]['isFavorite'] = true;
        } else {
          products[i]['isFavorite'] = false;
        }
      }
      notifyListeners();
    } catch (_) {}
  }

  // Sync cart items from backend
  Future<void> syncCartWithBackend() async {
    try {
      final backendCart = await UserService.getCart();
      final List<Map<String, dynamic>> syncedCart = [];
      
      for (final item in backendCart) {
        Map<String, dynamic>? matchingProduct;
        final prodData = item['product'];
        
        if (prodData is Map) {
          matchingProduct = Map<String, dynamic>.from(prodData);
        } else if (prodData is String) {
          matchingProduct = products.firstWhere(
            (p) => p['_id'] == prodData,
            orElse: () => <String, dynamic>{}
          );
        }
        
        if (matchingProduct != null && matchingProduct.isNotEmpty) {
          // Dynamic UI mappings
          final pIdx = products.indexWhere((p) => p['_id'] == matchingProduct!['_id']);
          if (pIdx != -1) {
            matchingProduct['color'] = products[pIdx]['color'];
            matchingProduct['icon'] = products[pIdx]['icon'];
            matchingProduct['image'] = products[pIdx]['image'];
          } else {
            matchingProduct['color'] = curatedColors[0];
            matchingProduct['icon'] = Icons.shopping_bag_rounded;
            matchingProduct['image'] = matchingProduct['image'] ?? '';
          }
          
          syncedCart.add({
            ...matchingProduct,
            'quantity': item['quantity'] ?? 1,
            'cartItemId': item['_id'],
          });
        }
      }
      
      cartItems.clear();
      cartItems.addAll(syncedCart);
      notifyListeners();
    } catch (_) {}
  }

  IconData _getIconForCategory(String? category) {
    if (category == null) return Icons.shopping_bag_rounded;
    switch (category.toLowerCase()) {
      case 'wearables':
      case 'watches':
        return Icons.watch_rounded;
      case 'electronics':
      case 'gadgets':
        return Icons.settings_input_component_rounded;
      case 'smartphones':
        return Icons.phone_android_rounded;
      case 'computers':
      case 'laptops':
        return Icons.laptop_chromebook_rounded;
      case 'cameras':
        return Icons.camera_alt_rounded;
      case 'audio':
        return Icons.headphones_rounded;
      case 'gaming':
        return Icons.sports_esports_rounded;
      default:
        return Icons.shopping_bag_rounded;
    }
  }

  // Toggle Favorite
  Future<void> toggleFavorite(Map<String, dynamic> product) async {
    final productId = product['_id'];
    
    // Find the product inside the main products list to ensure state updates globally!
    final mainProductIndex = products.indexWhere((p) => p['_id'] == productId || p['name'] == product['name']);
    
    if (mainProductIndex != -1) {
      // Toggle the flag in the main list
      products[mainProductIndex]['isFavorite'] = !(products[mainProductIndex]['isFavorite'] ?? false);
      // Also update the local map passed from the details screen so the visual icon updates immediately!
      product['isFavorite'] = products[mainProductIndex]['isFavorite'];
    } else {
      product['isFavorite'] = !(product['isFavorite'] ?? false);
    }
    notifyListeners();

    if (productId != null && !productId.toString().startsWith('mock')) {
      try {
        await UserService.toggleFavorite(productId);
        await syncFavoritesWithBackend();
      } catch (_) {
        // Rollback
        if (mainProductIndex != -1) {
          products[mainProductIndex]['isFavorite'] = !(products[mainProductIndex]['isFavorite'] ?? false);
          product['isFavorite'] = products[mainProductIndex]['isFavorite'];
        } else {
          product['isFavorite'] = !(product['isFavorite'] ?? false);
        }
        notifyListeners();
      }
    }
  }

  // Add item to Cart
  Future<void> addToCart(Map<String, dynamic> product) async {
    final productId = product['_id'];
    
    // Optimistic Update
    final index = cartItems.indexWhere((item) => item['_id'] == productId || item['name'] == product['name']);
    int newQty = 1;
    
    if (index != -1) {
      cartItems[index]['quantity']++;
      newQty = cartItems[index]['quantity'];
    } else {
      cartItems.add({
        ...product,
        'quantity': 1,
      });
    }
    notifyListeners();

    if (productId != null && !productId.toString().startsWith('mock')) {
      try {
        await UserService.addToCart(productId.toString(), newQty);
        await syncCartWithBackend();
      } catch (_) {}
    }
  }

  // Remove item from Cart
  void removeFromCart(Map<String, dynamic> item) {
    cartItems.remove(item);
    notifyListeners();
    
    final productId = item['_id'];
    if (productId != null && !productId.toString().startsWith('mock')) {
      UserService.removeFromCart(productId).then((_) => syncCartWithBackend());
    }
  }

  // Increment / Decrement quantity
  Future<void> updateQuantity(Map<String, dynamic> item, int delta) async {
    final oldQty = item['quantity'];
    final newQty = oldQty + delta;
    final productId = item['_id'];
    
    // Optimistic Update
    if (newQty <= 0) {
      cartItems.remove(item);
    } else {
      item['quantity'] = newQty;
    }
    notifyListeners();

    if (productId != null && !productId.toString().startsWith('mock')) {
      try {
        if (newQty <= 0) {
          await UserService.removeFromCart(productId);
        } else {
          await UserService.updateCartQuantity(productId, newQty);
        }
        await syncCartWithBackend();
      } catch (_) {
        // Rollback
        if (newQty <= 0) {
          cartItems.add(item);
        } else {
          item['quantity'] = oldQty;
        }
        notifyListeners();
      }
    }
  }

  List<Map<String, dynamic>> get favorites => products.where((p) => p['isFavorite'] == true).toList();

  double get subtotal => cartItems.fold(0.0, (sum, item) => sum + (double.tryParse(item['price'].toString()) ?? 0.0) * item['quantity']);
  double get shipping => cartItems.isEmpty ? 0 : 10.0;
  double get total => subtotal + shipping;
}

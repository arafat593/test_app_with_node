import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'profile_screen.dart';
import 'product_details_screen.dart';
import 'favorites_screen.dart';
import 'cart_screen.dart';
import 'app_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final AppData appData = AppData();
  String _searchQuery = "";
  String _selectedCategory = "All";

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appData,
      builder: (context, _) {
        final List<Widget> pages = [
          _buildHomeBody(),
          const FavoritesScreen(),
          const CartScreen(),
          const ProfileScreen(),
        ];

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FD),
          appBar: _currentIndex == 3
               ? null
               : AppBar(
                   backgroundColor: Colors.white,
                   elevation: 0,
                   centerTitle: false,
                   title: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text(
                         "Hello, ${appData.userProfile?['fullName'] ?? 'User'}!",
                         style: GoogleFonts.poppins(
                           fontSize: 14,
                           color: Colors.grey[600],
                         ),
                       ),
                       Text(
                         "Explore Marketplace",
                         style: GoogleFonts.poppins(
                           fontSize: 20,
                           fontWeight: FontWeight.bold,
                           color: const Color(0xFF1A1A1A),
                         ),
                       ),
                     ],
                   ),
                   actions: [
                     Padding(
                       padding: const EdgeInsets.only(right: 20),
                       child: GestureDetector(
                         onTap: () {
                           setState(() {
                             _currentIndex = 3;
                           });
                         },
                         child: Container(
                           width: 40,
                           height: 40,
                           decoration: BoxDecoration(
                             shape: BoxShape.circle,
                             color: Colors.deepPurple.withValues(alpha: 0.1),
                           ),
                           child: const Center(
                             child: Icon(
                               Icons.person_rounded,
                               color: Colors.deepPurple,
                               size: 22,
                             ),
                           ),
                         ),
                       ),
                     ),
                   ],
                 ),
          body: IndexedStack(
            index: _currentIndex,
            children: pages,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              selectedItemColor: Colors.deepPurple,
              unselectedItemColor: Colors.grey,
              showSelectedLabels: true,
              showUnselectedLabels: false,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              items: [
                const BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
                const BottomNavigationBarItem(icon: Icon(Icons.favorite_rounded), label: "Fav"),
                BottomNavigationBarItem(
                  icon: Badge(
                    label: Text("${appData.cartItems.length}"),
                    isLabelVisible: appData.cartItems.isNotEmpty,
                    child: const Icon(Icons.shopping_bag_rounded),
                  ),
                  label: "Cart",
                ),
                const BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "Profile"),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHomeBody() {
    // Dynamic categories extracted from products
    final dynamicCategories = {
      "All",
      ...appData.products
          .map((p) => p['category']?.toString())
          .whereType<String>()
          .where((cat) => cat.isNotEmpty)
    }.toList();

    // Filter products dynamically
    final filteredProducts = appData.products.where((product) {
      final matchesSearch = product['name']
          .toString()
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      
      final matchesCategory = _selectedCategory == "All" ||
          product['category']?.toString().toLowerCase() == _selectedCategory.toLowerCase();
          
      return matchesSearch && matchesCategory;
    }).toList();

    return RefreshIndicator(
      color: Colors.deepPurple,
      onRefresh: () => appData.fetchProducts(showLoader: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  icon: const Icon(Icons.search, color: Colors.grey),
                  hintText: "Search products...",
                  hintStyle: GoogleFonts.poppins(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Categories
            Text(
              "Categories",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: dynamicCategories.length,
                itemBuilder: (context, index) {
                  final cat = dynamicCategories[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                    child: _buildCategoryChip(cat, _selectedCategory == cat),
                  );
                },
              ),
            ),
            const SizedBox(height: 25),

            // Products Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _selectedCategory == "All" ? "Popular Products" : "$_selectedCategory Products",
                    style: GoogleFonts.poppins( 
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                if (appData.isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.deepPurple),
                  )
                else
                  Text(
                    "See All",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 15),
            
            // Empty State
            if (filteredProducts.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Icon(Icons.shopping_bag_outlined, size: 60, color: Colors.grey[400]),
                      const SizedBox(height: 15),
                      Text(
                        "No products found",
                        style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 16),
                      ),
                    ],
                  ),
                ),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
                  double spacing = 15.0;
                  double childAspectRatio = constraints.maxWidth > 600 ? 0.8 : 0.7;

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: spacing,
                      mainAxisSpacing: spacing,
                      childAspectRatio: childAspectRatio,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailsScreen(product: product),
                            ),
                          );
                        },
                        child: Hero(
                          tag: product['_id']?.toString() ?? product['name']?.toString() ?? 'product_hero_${product.hashCode}',
                          child: _buildGridProductCard(product),
                        ),
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isSelected ? Colors.deepPurple : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? Colors.deepPurple : Colors.grey[200]!),
      ),
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildGridProductCard(Map<String, dynamic> product) {
    final hasImage = product['image'] != null && product['image'].toString().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: product['color'].withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: hasImage
                    ? Image.network(
                        product['image'].toString(),
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Icon(
                            product['icon'],
                            size: 50,
                            color: product['color'],
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(
                          product['icon'],
                          size: 50,
                          color: product['color'],
                        ),
                      ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'].toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "\$${product['price']}",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

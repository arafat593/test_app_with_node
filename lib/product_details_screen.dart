import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_data.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _selectedColorIndex = 0;

  Color _mapColorStringToColor(String colorName) {
    switch (colorName.toLowerCase().replaceAll(' ', '')) {
      case 'black':
      case 'titaniumblack':
        return Colors.black87;
      case 'midnight':
        return const Color(0xFF1E1E2C);
      case 'silver':
      case 'titaniumgray':
        return const Color(0xFFC0C0C0);
      case 'gray':
      case 'grey':
        return Colors.grey;
      case 'white':
        return Colors.white;
      case 'starlight':
        return const Color(0xFFF2EFE9);
      case 'red':
        return Colors.red;
      case 'violet':
      case 'purple':
        return Colors.deepPurple;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      default:
        final hash = colorName.hashCode;
        return Color(hash | 0xFF000000);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appData = AppData();
    final product = widget.product;
    final hasImage = product['image'] != null && product['image'].toString().isNotEmpty;
    
    // Highly safe themeColor extraction with dynamic fallback to prevent any null crashes
    final Color themeColor = product['color'] is Color ? product['color'] as Color : Colors.deepPurple;

    return ListenableBuilder(
      listenable: appData,
      builder: (context, _) {
        final isFavorite = product['isFavorite'] ?? false;

        return Scaffold(
          backgroundColor: Colors.white,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).size.height * 0.4,
                pinned: true,
                backgroundColor: themeColor.withValues(alpha: 0.1),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: themeColor.withValues(alpha: 0.1),
                    child: Hero(
                      tag: product['_id']?.toString() ?? product['name']?.toString() ?? 'product_hero_${product.hashCode}',
                      child: hasImage
                          ? Image.network(
                              product['image'].toString(),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Center(
                                child: Icon(
                                  product['icon'] is IconData ? product['icon'] as IconData : Icons.shopping_bag_rounded,
                                  size: MediaQuery.of(context).size.width > 600 ? 200 : 150,
                                  color: themeColor,
                                ),
                              ),
                            )
                          : Center(
                              child: Icon(
                                product['icon'] is IconData ? product['icon'] as IconData : Icons.shopping_bag_rounded,
                                size: MediaQuery.of(context).size.width > 600 ? 200 : 150,
                                color: themeColor,
                              ),
                            ),
                    ),
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: isFavorite ? Colors.red : Colors.black,
                    ),
                    onPressed: () => appData.toggleFavorite(product),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              product['category']?.toString() ?? "Product Details",
                              style: GoogleFonts.poppins(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.orange, size: 20),
                              const SizedBox(width: 5),
                              Text(
                                "${product['rating'] ?? 4.8} (${product['reviewsCount'] ?? 120} reviews)",
                                style: GoogleFonts.poppins(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              product['name']?.toString() ?? "Tech Product",
                              style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1A1A1A),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: (product['inStock'] ?? true) 
                                    ? Colors.green.withValues(alpha: 0.1) 
                                    : Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                (product['inStock'] ?? true) ? "In Stock" : "Out of Stock",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: (product['inStock'] ?? true) ? Colors.green : Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "\$${product['price']}",
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 25),
                        Text(
                          "Description",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          product['description'] ?? product['desc'] ?? "No description available.",
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: Colors.grey[600],
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 30),
                        
                        // Safe color selection using type check instead of cast
                        if (product['colors'] is List && (product['colors'] as List).isNotEmpty) ...[
                          Text(
                            "Available Colors",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            height: 50,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: (product['colors'] as List).length,
                              itemBuilder: (context, index) {
                                final colorName = (product['colors'] as List)[index].toString();
                                final displayColor = _mapColorStringToColor(colorName);
                                final isSelected = _selectedColorIndex == index;

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedColorIndex = index;
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 15),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.deepPurple : Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: isSelected ? Colors.deepPurple : Colors.grey[300]!,
                                        width: 2,
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: Colors.deepPurple.withValues(alpha: 0.2),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 16,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color: displayColor,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white, width: 1.5),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          colorName,
                                          style: GoogleFonts.poppins(
                                            color: isSelected ? Colors.white : const Color(0xFF1A1A1A),
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            bottomSheet: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.deepPurple),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      appData.addToCart(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("${product['name']} added to cart!"),
                          backgroundColor: Colors.deepPurple,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "Add to Cart",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

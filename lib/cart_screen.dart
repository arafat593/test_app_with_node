import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_data.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appData = AppData();

    return ListenableBuilder(
      listenable: appData,
      builder: (context, _) {
        final cartItems = appData.cartItems;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FD),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              "Shopping Cart",
              style: GoogleFonts.poppins(
                color: const Color(0xFF1A1A1A),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: cartItems.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return _buildCartItem(item, appData);
                        },
                      ),
                    ),
                    _buildOrderSummary(appData.subtotal, appData.shipping, appData.total),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text(
            "Your cart is empty",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Add some products to get started",
            style: GoogleFonts.poppins(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item, AppData appData) {
    final hasImage = item['image'] != null && item['image'].toString().isNotEmpty;
    
    // Safely extract theme color and icon with fallbacks
    final Color themeColor = item['color'] is Color ? item['color'] as Color : Colors.deepPurple;
    final IconData themeIcon = item['icon'] is IconData ? item['icon'] as IconData : Icons.shopping_bag_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: themeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: hasImage
                  ? Image.network(
                      item['image'].toString(),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        themeIcon,
                        color: themeColor,
                        size: 30,
                      ),
                    )
                  : Icon(
                      themeIcon,
                      color: themeColor,
                      size: 30,
                    ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'].toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "\$${item['price']}",
                  style: GoogleFonts.poppins(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _buildQuantityBtn(Icons.remove, () => appData.updateQuantity(item, -1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  "${item['quantity']}",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
              ),
              _buildQuantityBtn(Icons.add, () => appData.updateQuantity(item, 1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: Colors.black54),
      ),
    );
  }

  Widget _buildOrderSummary(double subtotal, double shipping, double total) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSummaryRow("Subtotal", "\$${subtotal.toStringAsFixed(2)}"),
          const SizedBox(height: 10),
          _buildSummaryRow("Shipping", "\$${shipping.toStringAsFixed(2)}"),
          const Divider(height: 30),
          _buildSummaryRow("Total", "\$${total.toStringAsFixed(2)}", isTotal: true),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              child: Text(
                "Checkout Now",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.black : Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 20 : 16,
            fontWeight: FontWeight.bold,
            color: isTotal ? Colors.deepPurple : Colors.black,
          ),
        ),
      ],
    );
  }
}

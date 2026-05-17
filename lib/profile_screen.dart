import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';
import 'auth_service.dart';
import 'app_data.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // 1. Load cached user data from SharedPreferences first for immediate response
    final cachedData = await AuthService.getCurrentUser();
    if (mounted) {
      setState(() {
        _user = cachedData;
        _isLoading = false;
      });
    }

    // 2. Fetch live data from backend for accuracy and update cache
    final response = await AuthService.getUserProfile();
    if (mounted && response['success'] == true) {
      setState(() {
        _user = response['data'];
      });
      AppData().loadUserProfile();
    }
  }

  Future<void> _handleLogout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _user?['fullName'] ?? _user?['name'] ?? "");
    final phoneController = TextEditingController(text: _user?['phoneNumber'] ?? _user?['phone'] ?? "");
    final addressController = TextEditingController(text: _user?['address'] ?? "");
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              title: Text(
                "Edit Profile",
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF1A1A1A)),
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        style: GoogleFonts.poppins(),
                        decoration: InputDecoration(
                          labelText: "Full Name",
                          labelStyle: GoogleFonts.poppins(),
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        validator: (v) => v!.trim().isEmpty ? "Name cannot be empty" : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: phoneController,
                        style: GoogleFonts.poppins(),
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: "Phone Number",
                          labelStyle: GoogleFonts.poppins(),
                          prefixIcon: const Icon(Icons.phone_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        validator: (v) => v!.trim().length < 10 ? "Enter valid phone number" : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: addressController,
                        style: GoogleFonts.poppins(),
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: "Address",
                          labelStyle: GoogleFonts.poppins(),
                          prefixIcon: const Icon(Icons.location_on_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        validator: (v) => v!.trim().isEmpty ? "Address cannot be empty" : null,
                      ),
                    ],
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
                  child: Text(
                    "Cancel",
                    style: GoogleFonts.poppins(color: Colors.grey[600], fontWeight: FontWeight.w600),
                  ),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          
                          setDialogState(() {
                            isSaving = true;
                          });

                          final navigator = Navigator.of(context);
                          final messenger = ScaffoldMessenger.of(context);

                          final res = await AuthService.updateUserProfile(
                            fullName: nameController.text.trim(),
                            phoneNumber: phoneController.text.trim(),
                            address: addressController.text.trim(),
                          );

                          if (mounted) {
                            setDialogState(() {
                              isSaving = false;
                            });
                            
                            if (res['success'] == true) {
                              setState(() {
                                _user = res['data'];
                              });
                              AppData().loadUserProfile();
                              navigator.pop();
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(res['message']),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            } else {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(res['message']),
                                  backgroundColor: Colors.redAccent,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text("Save", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final fullName = _user?['fullName'] ?? _user?['name'] ?? "User Name";
    final email = _user?['email'] ?? "user@gmail.com";
    final phone = _user?['phoneNumber'] ?? _user?['phone'] ?? "+880 1234 567890";
    final address = _user?['address'] ?? "Dhaka, Bangladesh";

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "My Profile",
          style: GoogleFonts.poppins(
            color: const Color(0xFF1A1A1A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
          : RefreshIndicator(
              color: Colors.deepPurple,
              onRefresh: _loadUserData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    // Profile Header
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const CircleAvatar(
                              radius: 70,
                              backgroundColor: Colors.deepPurple,
                              child: Icon(Icons.person, size: 80, color: Colors.white),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _showEditProfileDialog,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Colors.deepPurple,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.edit, color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    Text(
                      fullName,
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    Text(
                      email,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Profile Info List
                    _buildProfileItem(Icons.person_outline, "Name", fullName),
                    _buildProfileItem(Icons.email_outlined, "Email", email),
                    _buildProfileItem(Icons.phone_outlined, "Phone", phone),
                    _buildProfileItem(Icons.location_on_outlined, "Address", address),
                    
                    const SizedBox(height: 40),
                    
                    // Logout Button
                    Container(
                      width: double.infinity,
                      height: 55,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _handleLogout,
                          borderRadius: BorderRadius.circular(15),
                          child: Center(
                            child: Text(
                              "Logout",
                              style: GoogleFonts.poppins(
                                color: Colors.red,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple, size: 28),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import 'auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  void _showCustomSnackBar({required String message, required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.redAccent.withValues(alpha: 0.9) : Colors.green.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.all(15),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final response = await AuthService.register(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      password: _passwordController.text,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (response['success'] == true) {
        _showCustomSnackBar(message: 'Registration successful! Logging in...', isError: false);
        
        final loginResponse = await AuthService.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (mounted) {
          if (loginResponse['success'] == true) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else {
            _showCustomSnackBar(message: 'Registration successful! Please login.', isError: false);
            Navigator.pop(context);
          }
        }
      } else {
        _showCustomSnackBar(message: response['message'], isError: true);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.8, curve: Curves.easeOutQuart)),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF667EEA),
                  Color(0xFF764BA2),
                ],
              ),
            ),
          ),
          
          // Decorative Circles
          Positioned(
            top: -100,
            right: -50,
            child: _buildCircle(300, Colors.white.withValues(alpha: 0.1)),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: _buildCircle(200, Colors.white.withValues(alpha: 0.05)),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Back Button
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 10),
                        
                        Text(
                          "Create Account",
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "Join us to start your journey",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // SignUp Card
                        Container(
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                _buildTextField(
                                  controller: _nameController,
                                  hint: "Full Name",
                                  icon: Icons.person_outline,
                                  validator: (v) => v!.isEmpty ? "Enter your name" : null,
                                ),
                                const SizedBox(height: 20),
                                _buildTextField(
                                  controller: _emailController,
                                  hint: "Gmail Address",
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) => !v!.contains('@') ? "Enter valid email" : null,
                                ),
                                const SizedBox(height: 20),
                                _buildTextField(
                                  controller: _phoneController,
                                  hint: "Phone Number",
                                  icon: Icons.phone_outlined,
                                  keyboardType: TextInputType.phone,
                                  validator: (v) => v!.length < 10 ? "Enter valid phone" : null,
                                ),
                                const SizedBox(height: 20),
                                _buildTextField(
                                  controller: _passwordController,
                                  hint: "Password",
                                  icon: Icons.lock_outline,
                                  isPassword: true,
                                  isPasswordVisible: _isPasswordVisible,
                                  onToggleVisibility: () {
                                    setState(() => _isPasswordVisible = !_isPasswordVisible);
                                  },
                                  validator: (v) => v!.length < 6 ? "Min 6 characters" : null,
                                ),
                                const SizedBox(height: 20),
                                _buildTextField(
                                  controller: _confirmPasswordController,
                                  hint: "Confirm Password",
                                  icon: Icons.lock_reset_outlined,
                                  isPassword: true,
                                  isPasswordVisible: _isConfirmPasswordVisible,
                                  onToggleVisibility: () {
                                    setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
                                  },
                                  validator: (v) {
                                    if (v != _passwordController.text) return "Passwords do not match";
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 30),
                                
                                // Sign Up Button
                                _buildGradientButton(
                                  text: "Sign Up",
                                  isLoading: _isLoading,
                                  onTap: _isLoading ? () {} : _handleSignUp,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Login Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account? ",
                              style: GoogleFonts.poppins(color: Colors.white70),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Text(
                                "Sign In",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onToggleVisibility,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !isPasswordVisible,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
        prefixIcon: Icon(icon, color: Colors.white70),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white70,
                ),
                onPressed: onToggleVisibility,
              )
            : null,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.1),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.white70),
        ),
      ),
    );
  }

  Widget _buildGradientButton({required String text, required VoidCallback onTap, bool isLoading = false}) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: isLoading 
              ? [const Color(0xFF8E2DE2).withValues(alpha: 0.6), const Color(0xFF4A00E0).withValues(alpha: 0.6)]
              : [const Color(0xFF8E2DE2), const Color(0xFF4A00E0)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A00E0).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(15),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    text,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:wandermood/features/auth/application/auth_service.dart';
import 'package:wandermood/features/auth/domain/providers/auth_provider.dart';
import 'package:wandermood/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:wandermood/features/auth/presentation/screens/register_screen.dart';
import 'package:wandermood/features/home/presentation/screens/home_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  
  String? _emailError;
  String? _passwordError;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _validateInputs() {
    setState(() {
      // Email validation
      if (_emailController.text.isEmpty) {
        _emailError = 'Please enter your email address';
      } else if (!_isValidEmail(_emailController.text)) {
        _emailError = 'Please enter a valid email address';
      } else {
        _emailError = null;
      }

      // Password validation
      if (_passwordController.text.isEmpty) {
        _passwordError = 'Please enter your password';
      } else {
        _passwordError = null;
      }
    });
  }

  void _handleLogin() {
    _validateInputs();
    
    // Only proceed if there are no errors
    if (_emailError == null && _passwordError == null) {
      setState(() {
        _isLoading = true;
      });
      
      // Implementatie van login met Supabase
      ref.read(authStateProvider.notifier).signIn(
        email: _emailController.text,
        password: _passwordController.text,
        onError: (errorMessage) {
          setState(() {
            _isLoading = false;
          });
          
          // Toon foutmelding aan gebruiker
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red.shade400,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        onSuccess: () {
          setState(() {
            _isLoading = false;
          });
          
          // Navigate using GoRouter
          context.go('/home');
        },
      );
    }
  }

  void _handleDemoLogin() {
    setState(() {
      _isLoading = true;
    });
    
    // Inloggen met demo account
    ref.read(authStateProvider.notifier).signIn(
      email: AuthService.demoEmail,
      password: AuthService.demoPassword,
      onError: (errorMessage) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      onSuccess: () {
        setState(() {
          _isLoading = false;
        });
        
        context.go('/home');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Remove the body's background to ensure full gradient
      backgroundColor: Colors.transparent,
      body: Container(
        // Extend the decoration to the full screen
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFAFF4), // Pink at the top
              Color(0xFFFFF5AF), // Yellow at the bottom
            ],
            // This ensures the gradient fills the entire container
            stops: [0.0, 1.0],
          ),
        ),
        // Make sure the container fills the entire screen
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  
                  // App naam
                  Center(
                    child: Text(
                      'WanderMood.',
                      style: GoogleFonts.museoModerno(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4CAF50),
                      ),
                    ),
                  ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
                  
                  const SizedBox(height: 24),
                  
                  // Zwevend formulier card
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    color: Colors.white.withOpacity(0.9),
                    shadowColor: Colors.black.withOpacity(0.3),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Sign in text
                            Center(
                              child: Text(
                                'Sign in to your account',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Email field
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(color: _emailError != null ? Colors.red.shade400 : Colors.grey.shade300),
                              ),
                              child: TextField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  hintText: 'username@example.com',
                                  prefixIcon: Icon(Icons.mail_outline, color: Colors.grey),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(vertical: 16),
                                ),
                                onChanged: (value) {
                                  if (_emailError != null) {
                                    setState(() {
                                      _emailError = null;
                                    });
                                  }
                                },
                              ),
                            ),
                            
                            if (_emailError != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 6.0, left: 12.0),
                                child: Text(
                                  _emailError!,
                                  style: TextStyle(
                                    color: Colors.red.shade400,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            
                            const SizedBox(height: 16),
                            
                            // Password field
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(color: _passwordError != null ? Colors.red.shade400 : Colors.grey.shade300),
                              ),
                              child: TextField(
                                controller: _passwordController,
                                obscureText: !_isPasswordVisible,
                                decoration: InputDecoration(
                                  hintText: '••••••••',
                                  prefixIcon: Icon(Icons.lock_outline, color: Colors.grey),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible 
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: _isPasswordVisible 
                                          ? Color(0xFF4CAF50)
                                          : Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible = !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(vertical: 16),
                                ),
                                onChanged: (value) {
                                  if (_passwordError != null) {
                                    setState(() {
                                      _passwordError = null;
                                    });
                                  }
                                },
                              ),
                            ),
                            
                            if (_passwordError != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 6.0, left: 12.0),
                                child: Text(
                                  _passwordError!,
                                  style: TextStyle(
                                    color: Colors.red.shade400,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            
                            const SizedBox(height: 16),
                            
                            // Remember me & Forgot password
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Remember me checkbox
                                Row(
                                  children: [
                                    SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: Checkbox(
                                        value: _rememberMe,
                                        activeColor: Color(0xFF4CAF50),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            _rememberMe = value ?? false;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Remember me',
                                      style: TextStyle(
                                        color: Color(0xFF4CAF50),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                
                                // Forgot password
                                TextButton(
                                  onPressed: () {
                                    context.push('/forgot-password');
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size(0, 0),
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Forget Password?',
                                    style: TextStyle(
                                      color: Color(0xFF4CAF50),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Sign in button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF4CAF50),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 0,
                                ),
                                child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Sign In',
                                      style: GoogleFonts.museoModerno(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0, duration: 500.ms),
                  
                  const SizedBox(height: 24),
                  
                  // Or continue with
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.grey.withOpacity(0.5),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Or Continue With',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.grey.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Social login options
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Apple
                      _buildSocialButton(
                        onPressed: () {
                          // TODO: Implement Apple login
                        },
                        icon: Icons.apple,
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Google
                      _buildSocialButton(
                        onPressed: () {
                          // TODO: Implement Google login
                        },
                        isGoogle: true,
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Facebook
                      _buildSocialButton(
                        onPressed: () {
                          // TODO: Implement Facebook login
                        },
                        isFacebook: true,
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 30),
                  
                  // Registreren link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Nog geen account? ',
                        style: TextStyle(color: Colors.black54),
                      ),
                      TextButton(
                        onPressed: () {
                          context.push('/register');
                        },
                        child: const Text(
                          'Registreren',
                          style: TextStyle(
                            color: Color(0xFF4CAF50),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Demo knop voor navigatie naar home screen (tijdelijk)
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton(
                      onPressed: _handleDemoLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'DEMO: Bekijk App zonder Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSocialButton({
    required VoidCallback onPressed,
    IconData? icon,
    bool isGoogle = false,
    bool isFacebook = false,
  }) {
    Widget buttonContent;
    Color backgroundColor = Colors.white;
    Color borderColor = Colors.grey.shade300;
    
    if (icon != null) {
      // Apple login button
      buttonContent = Icon(Icons.apple, size: 24, color: Colors.black);
    } else if (isGoogle) {
      // Google login button
      buttonContent = Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          Icons.g_mobiledata,
          size: 28,
          color: Colors.red,
        ),
      );
    } else if (isFacebook) {
      // Facebook login button
      buttonContent = Icon(Icons.facebook, size: 28, color: Colors.blue[700]);
      backgroundColor = Colors.white;
    } else {
      buttonContent = Container();
    }
    
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: borderColor),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Center(child: buttonContent),
        ),
      ),
    ).animate()
     .fadeIn(delay: 800.ms, duration: 400.ms)
     .slideY(begin: 0.2, end: 0, delay: 800.ms, duration: 400.ms);
  }
} 
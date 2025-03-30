import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wandermood/features/auth/domain/providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _acceptTerms = false;
  
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateInputs() {
    setState(() {
      // Name validation
      if (_nameController.text.isEmpty) {
        _nameError = 'Please enter your name';
      } else {
        _nameError = null;
      }

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
        _passwordError = 'Please enter a password';
      } else if (_passwordController.text.length < 6) {
        _passwordError = 'Password must be at least 6 characters';
      } else {
        _passwordError = null;
      }

      // Confirm password validation
      if (_confirmPasswordController.text.isEmpty) {
        _confirmPasswordError = 'Please confirm your password';
      } else if (_confirmPasswordController.text != _passwordController.text) {
        _confirmPasswordError = 'Passwords do not match';
      } else {
        _confirmPasswordError = null;
      }
    });
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _handleRegister() {
    _validateInputs();
    
    // Check if all validations pass and terms are accepted
    if (_nameError == null && 
        _emailError == null && 
        _passwordError == null && 
        _confirmPasswordError == null &&
        _acceptTerms) {
      
      setState(() {
        _isLoading = true;
      });
      
      // Implementatie van registratie met Supabase
      ref.read(authStateProvider.notifier).signUp(
        email: _emailController.text,
        password: _passwordController.text,
        name: _nameController.text,
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
          
          // Toon succesmelding aan gebruiker
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registratie succesvol! Controleer je email om je account te verifiëren.'),
              backgroundColor: Color(0xFF4CAF50),
              behavior: SnackBarBehavior.floating,
            ),
          );
          
          // Navigeer terug naar het inlogscherm
          Navigator.of(context).pop();
        },
      );
    } else if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Je moet akkoord gaan met de voorwaarden'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFAFF4), // Pink at the top
              Color(0xFFFFF5AF), // Yellow at the bottom
            ],
            stops: [0.0, 1.0],
          ),
        ),
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          child: Column(
            children: [
              // Back button
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 16),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Color(0xFF4CAF50)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Logo
              Text(
                'WanderMood.',
                style: GoogleFonts.museoModerno(
                  color: const Color(0xFF4CAF50),
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
              
              const SizedBox(height: 20),
              
              // Main content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Registration Card
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        color: Colors.white.withOpacity(0.9),
                        shadowColor: Colors.black.withOpacity(0.3),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              // Registration title
                              Text(
                                'Create your account',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                              
                              const SizedBox(height: 20),
                              
                              // Name field
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(color: _nameError != null ? Colors.red.shade400 : Colors.grey.shade300),
                                ),
                                child: TextField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    hintText: 'Name',
                                    prefixIcon: const Icon(Icons.person, color: Colors.grey),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  onChanged: (value) {
                                    if (_nameError != null) {
                                      setState(() {
                                        _nameError = null;
                                      });
                                    }
                                  },
                                ),
                              ),
                              
                              if (_nameError != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6.0, left: 12.0),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      _nameError!,
                                      style: TextStyle(
                                        color: Colors.red.shade400,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              
                              const SizedBox(height: 10),
                              
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
                                    hintText: 'Email address',
                                    prefixIcon: const Icon(Icons.email, color: Colors.grey),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
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
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      _emailError!,
                                      style: TextStyle(
                                        color: Colors.red.shade400,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              
                              const SizedBox(height: 10),
                              
                              // Password field
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(color: _passwordError != null ? Colors.red.shade400 : Colors.grey.shade300),
                                ),
                                child: TextField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    hintText: 'Password',
                                    prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                                    suffixIcon: const Icon(Icons.visibility, color: Colors.grey),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
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
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      _passwordError!,
                                      style: TextStyle(
                                        color: Colors.red.shade400,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              
                              const SizedBox(height: 10),
                              
                              // Confirm password field
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(color: _confirmPasswordError != null ? Colors.red.shade400 : Colors.grey.shade300),
                                ),
                                child: TextField(
                                  controller: _confirmPasswordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    hintText: 'Confirm password',
                                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                                    suffixIcon: const Icon(Icons.visibility, color: Colors.grey),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  onChanged: (value) {
                                    if (_confirmPasswordError != null) {
                                      setState(() {
                                        _confirmPasswordError = null;
                                      });
                                    }
                                  },
                                ),
                              ),
                              
                              if (_confirmPasswordError != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6.0, left: 12.0),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      _confirmPasswordError!,
                                      style: TextStyle(
                                        color: Colors.red.shade400,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              
                              const SizedBox(height: 10),
                              
                              // Terms checkbox
                              Row(
                                children: [
                                  SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: Checkbox(
                                      value: _acceptTerms,
                                      activeColor: const Color(0xFF4CAF50),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          _acceptTerms = value ?? false;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'I agree to the terms and conditions and privacy policy',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Register button
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleRegister,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4CAF50),
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
                                        'Register',
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
                      ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0, duration: 500.ms),
                      
                      const SizedBox(height: 10),
                      
                      // Login link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account?',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF4CAF50),
                              padding: EdgeInsets.zero,
                              minimumSize: Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF4CAF50),
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 900.ms, duration: 400.ms),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
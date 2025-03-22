import 'package:flutter/material.dart';
import 'package:path_finder/services/api_services/auth_api.dart';
import 'package:path_finder/widgets/auth_button.dart';
import 'package:path_finder/widgets/input_field.dart';
import '../widgets/custom_snackbar.dart';

class ClubLeaderSignin extends StatefulWidget {
  const ClubLeaderSignin({super.key});

  @override
  State<ClubLeaderSignin> createState() => _ClubLeaderSigninState();
}

class _ClubLeaderSigninState extends State<ClubLeaderSignin>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  ApiService apiService = ApiService();

  bool _obscurePassword = true;
  bool _rememberMe = false;

  //authentication
  Future<void> loginClubLeader() async {
    final result = await apiService.clubLeaderLogin(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
        _rememberMe,
        context // Pass context to the API service
        );

    if (result['success']) {
      ScaffoldMessenger.of(context)
          .showSnackBar(CustomSnackbar(text: "Login Successful").build());

      // Navigate to home screen or club leader dashboard
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackbar(text: result['message'], color: Colors.red).build());
    }
  }

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Set up animations
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.1, 0.7, curve: Curves.easeOut),
    ));

    // Start the animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _handleSignin() {
    if (_formKey.currentState!.validate()) {
      // Call login method
      loginClubLeader();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image covering the top part
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.35, // Top third
            child: Image.asset(
              "assets/start-img.png",
              fit: BoxFit.cover,
            ),
          ),

          // Gradient overlay on top of image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.35,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withAlpha(102), // 0.4 opacity = 102 alpha
                    Colors.black.withAlpha(0),
                  ],
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Top space for image
                  SizedBox(height: MediaQuery.of(context).size.height * 0.18),

                  // Main content card that overlaps the image
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(26),
                          blurRadius: 10,
                          offset: Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // App Logo with Hero animation
                              Center(
                                child: Hero(
                                  tag: 'appLogo',
                                  child: Material(
                                    color: Colors.transparent,
                                    child: Text(
                                      "PathFinder",
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                "Club Leader Login",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                              SizedBox(height: 40),

                              // Form
                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    // Username Field
                                    InputField(
                                      controller: _usernameController,
                                      label: "Username",
                                      icon: Icons.person_outline,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your username';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 20),

                                    // Password Field
                                    InputField(
                                      controller: _passwordController,
                                      label: "Password",
                                      icon: Icons.lock_outline,
                                      obscureText: _obscurePassword,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: Colors.grey[600],
                                        ),
                                        onPressed: _togglePasswordVisibility,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your password';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 24),

                                    // Remember me and forgot password
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Remember me checkbox
                                        Row(
                                          children: [
                                            SizedBox(
                                              height: 24,
                                              width: 24,
                                              child: Checkbox(
                                                value: _rememberMe,
                                                activeColor: Colors.blue[700],
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                onChanged: (value) {
                                                  setState(() {
                                                    _rememberMe =
                                                        value ?? false;
                                                  });
                                                },
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'Remember me',
                                              style: TextStyle(
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),

                                        // Forgot password
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pushNamedAndRemoveUntil(
                                              context,
                                              '/home',
                                              (route) => false,
                                            );
                                            // Navigate to forgot password
                                          },
                                          child: Text(
                                            'Forgot Password?',
                                            style: TextStyle(
                                              color: Colors.blue[700],
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 32),

                                    // Signin Button
                                    AuthButton(handleSignin: _handleSignin),
                                  ],
                                ),
                              ),
                              SizedBox(height: 40),

                              // Back to student login
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Not a club leader? ",
                                    style: TextStyle(
                                      color: Colors.black87,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(context, "/signin");
                                    },
                                    child: Text(
                                      "Student Login",
                                      style: TextStyle(
                                        color: Colors.blue[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

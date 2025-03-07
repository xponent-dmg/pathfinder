import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/global.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _logoAnimationController; // Controls logo animation
  late AnimationController
      _loadingLineController; // Controls the loading line progress
  late AnimationController
      _dotsAnimationController; // Controls the animated dots
  late Animation<double> _logoSizeAnimation; // Logo size pulsating animation
  late Animation<double> _logoOpacityAnimation; // Logo fade-in animation
  late Animation<double> _loadingAnimation; // Loading line progress animation

  @override
  void initState() {
    super.initState();

    // LOGO ANIMATION: Set up the logo animation controller
    // This creates a pulsating effect with fade-in for the logo
    _logoAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    );

    _logoSizeAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // LOADING LINE ANIMATION: Set up the loading animation controller
    // This will animate just once to show progress and completion
    _loadingLineController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2), // Line completes in 4 seconds
    );

    _loadingAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_loadingLineController);

    // DOTS ANIMATION: Set up the dots animation controller
    // This will continuously animate until page transition
    _dotsAnimationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2), // Faster animation for dots
    )..repeat(); // Repeat indefinitely

    // Start the animations
    _logoAnimationController.forward();
    _loadingLineController.forward(); // Only run once (will not repeat)

    // Navigate to login page after delay
    Timer(Duration(seconds: 3), () {
      // Ensure we dispose controllers properly when navigating
      _dotsAnimationController.stop();

      Navigator.pushReplacementNamed(
          context, (token != null) ? '/home' : '/signin');
    });
  }

  @override
  void dispose() {
    // Important: dispose all animation controllers to prevent memory leaks
    _logoAnimationController.dispose();
    _loadingLineController.dispose();
    _dotsAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set status bar to transparent with light icons (for better visibility against dark background)
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Using a background image with a dark overlay for better text contrast
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/start-img.png"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withAlpha(60), // Slightly darken the image
              BlendMode.darken,
            ),
          ),
        ),
        child: Column(
          children: [
            // Top space with logo
            Expanded(
              flex: 5,
              child: Center(
                child: FadeTransition(
                  opacity: _logoOpacityAnimation,
                  child: ScaleTransition(
                    scale: _logoSizeAnimation,
                    child: Hero(
                      tag:
                          'appLogo', // Hero tag for smooth transition to next screen
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          "PathFinder",
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                            // Add shadow for better readability against image background
                            shadows: [
                              Shadow(
                                offset: Offset(1, 1),
                                blurRadius: 4,
                                color: Colors.black.withAlpha(100),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom card with loading indicators
            Container(
              padding: EdgeInsets.all(30),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(30),
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Discover your journey",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 30),

                  // Loading line animation - runs once to completion
                  AnimatedBuilder(
                    animation: _loadingAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 150,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: _loadingAnimation.value,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue[300]!,
                                    Colors.blue[700]!,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 24),

                  // Animated dots - continue animating until page transition
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return AnimatedBuilder(
                        animation: _dotsAnimationController,
                        builder: (context, child) {
                          final delay = index * 0.2;
                          // Calculate animation value with delay for each dot
                          final animationValue =
                              (_dotsAnimationController.value + delay) % 1.0;
                          // Dots grow and shrink based on animation value
                          final size = 4.0 + 4.0 * animationValue;
                          // Dots fade in and out based on animation value
                          final opacity = 0.3 + 0.7 * animationValue;

                          return Container(
                            width: size,
                            height: size,
                            margin: EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue[700]!
                                  .withAlpha((opacity * 255).toInt()),
                              shape: BoxShape.circle,
                            ),
                          );
                        },
                      );
                    }),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

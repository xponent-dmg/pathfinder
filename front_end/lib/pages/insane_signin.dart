import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class InsaneSignInPage extends StatefulWidget {
  const InsaneSignInPage({super.key});

  @override
  State<InsaneSignInPage> createState() => _InsaneSignInPageState();
}

class _InsaneSignInPageState extends State<InsaneSignInPage>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  bool _isObscured = true;
  bool _isSigningIn = false;
  double _dragValue = 0.0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _rotationAnimation =
        Tween<double>(begin: 0, end: 2 * math.pi).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Animated background
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: BackgroundPainter(
                  animation: _controller.value,
                  dragValue: _dragValue,
                ),
                child: Container(),
              );
            },
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),

                  // Title with rotating elements
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _rotationAnimation,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _rotationAnimation.value,
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(70),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.purple.withAlpha(76),
                                      Colors.blue.withAlpha(76),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        Text(
                          "PathFinder",
                          style: GoogleFonts.orbitron(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 2
                              ..shader = const LinearGradient(
                                colors: [
                                  Colors.purple,
                                  Colors.blue,
                                  Colors.cyan
                                ],
                              ).createShader(
                                  const Rect.fromLTWH(0, 0, 200, 70)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 80),

                  // Email field with effects
                  TiltableFormField(
                    controller: _emailController,
                    hintText: "Email",
                    prefixIcon: const Icon(Icons.email_outlined,
                        color: Colors.cyanAccent),
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 20),

                  // Password field with effects
                  TiltableFormField(
                    controller: _passwordController,
                    hintText: "Password",
                    obscureText: _isObscured,
                    prefixIcon: const Icon(Icons.lock_outline,
                        color: Colors.purpleAccent),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscured ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white70,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscured = !_isObscured;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        'Forgot Password?',
                        style: GoogleFonts.rajdhani(
                          color: Colors.cyanAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Custom slider button for sign in
                  _buildSlideToSignInButton(),

                  const Spacer(),

                  // Sign up option
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.rajdhani(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                        children: [
                          const TextSpan(text: "Don't have an account? "),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushReplacementNamed(
                                    context, '/signup');
                              },
                              child: Text(
                                "SIGN UP",
                                style: GoogleFonts.orbitron(
                                  color: Colors.cyanAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Loading overlay
          if (_isSigningIn)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Container(
                  color: Colors.black.withAlpha(179), // 0.7 * 255 ≈ 179
                  child: Center(
                    child: Transform.rotate(
                      angle: _controller.value * 4 * math.pi,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: const SweepGradient(
                            colors: [
                              Colors.transparent,
                              Colors.purpleAccent,
                              Colors.blueAccent,
                              Colors.cyanAccent,
                              Colors.transparent
                            ],
                          ),
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSlideToSignInButton() {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          _dragValue += details.delta.dx / 250;
          _dragValue = _dragValue.clamp(0.0, 1.0);
        });
      },
      onHorizontalDragEnd: (details) {
        if (_dragValue > 0.9) {
          setState(() {
            _isSigningIn = true;
            _dragValue = 1.0;
          });

          // Simulate sign in process
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                _isSigningIn = false;
                _dragValue = 0.0;
              });
            }
          });
        } else {
          setState(() {
            _dragValue = 0.0;
          });
        }
      },
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.purpleAccent, width: 2),
          gradient: const LinearGradient(
            colors: [Colors.black, Colors.purple, Colors.deepPurple],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Stack(
          children: [
            // Progress indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: MediaQuery.of(context).size.width * _dragValue,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  colors: [
                    Colors.purpleAccent,
                    Colors.blueAccent,
                    Colors.cyanAccent
                  ],
                ),
              ),
            ),

            // Sliding thumb
            Positioned(
              left: (_dragValue * (MediaQuery.of(context).size.width - 100))
                  .clamp(0.0, double.infinity),
              top: 5,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withAlpha(127),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                ),
              ),
            ),

            // Text
            Center(
              child: Text(
                _dragValue > 0.9 ? "SIGNING IN..." : "SLIDE TO SIGN IN",
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BackgroundPainter extends CustomPainter {
  final double animation;
  final double dragValue;

  BackgroundPainter({required this.animation, required this.dragValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Draw the dark background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.black,
    );

    // Draw animated circles
    for (int i = 0; i < 10; i++) {
      final radius = (30 + i * 20) * (1 + dragValue * 0.5);
      final offset = i * (2 * math.pi / 10);
      final x =
          size.width / 2 + math.cos(animation * 2 * math.pi + offset) * radius;
      final y =
          size.height / 3 + math.sin(animation * 2 * math.pi + offset) * radius;

      paint.color = Color.lerp(
        Colors.purple.withAlpha(25),
        Colors.cyan.withAlpha(25),
        i / 10,
      )!;

      canvas.drawCircle(Offset(x, y), 10 + i * 2.0, paint);
    }

    // Draw grid lines
    paint.color = Colors.cyanAccent.withAlpha(25);
    paint.strokeWidth = 1;

    for (int i = 0; i < 20; i++) {
      final offset = i * (size.width / 20);
      canvas.drawLine(
        Offset(offset, 0),
        Offset(offset, size.height),
        paint,
      );
    }

    for (int i = 0; i < 40; i++) {
      final offset = i * (size.height / 40);
      canvas.drawLine(
        Offset(0, offset),
        Offset(size.width, offset),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(BackgroundPainter oldDelegate) {
    return animation != oldDelegate.animation ||
        dragValue != oldDelegate.dragValue;
  }
}

class TiltableFormField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;

  const TiltableFormField({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
  });

  @override
  State<TiltableFormField> createState() => _TiltableFormFieldState();
}

class _TiltableFormFieldState extends State<TiltableFormField> {
  double _rotationX = 0;
  double _rotationY = 0;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(_rotationX)
        ..rotateY(_rotationY),
      alignment: FractionalOffset.center,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _rotationY = (_rotationY + details.delta.dx / 100).clamp(-0.1, 0.1);
            _rotationX = (_rotationX - details.delta.dy / 100).clamp(-0.1, 0.1);
          });
        },
        onPanEnd: (_) {
          setState(() {
            _rotationX = 0;
            _rotationY = 0;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  _isFocused ? Colors.cyanAccent : Colors.purple.withAlpha(127),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: (_isFocused ? Colors.cyanAccent : Colors.purple)
                    .withAlpha(76),
                blurRadius: 15,
                spreadRadius: 1,
              ),
            ],
          ),
          child: TextField(
            controller: widget.controller,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            onTap: () {
              setState(() {
                _isFocused = true;
              });
            },
            onSubmitted: (_) {
              setState(() {
                _isFocused = false;
              });
            },
            style: GoogleFonts.rajdhani(
              color: Colors.white,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: GoogleFonts.rajdhani(
                color: Colors.white54,
              ),
              prefixIcon: widget.prefixIcon,
              suffixIcon: widget.suffixIcon,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        ),
      ),
    );
  }
}

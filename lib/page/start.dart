import 'package:flutter/material.dart';
import 'login_register_forget/login_with_firebase.dart';
import '../page/intro.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({Key? key}) : super(key: key);

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _contentController;
  late Animation<double> _logoAnimation;
  late Animation<double> _contentAnimation;

  @override
  void initState() {
    super.initState();

    // Animation cho logo (di chuyển từ giữa lên trên)
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Animation cho nội dung (fade in)
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    _contentAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeInOut),
    );

    // Bắt đầu animation
    _startAnimation();

    // Chuyển sang LoginScreen sau 4 giây
    /*
    Future.delayed(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }); */

    Future.delayed(const Duration(seconds: 4), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) => IntroScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    });
  }

  void _startAnimation() async {
    // Đợi 500ms rồi bắt đầu đẩy logo lên
    await Future.delayed(const Duration(milliseconds: 1000));
    _logoController.forward();

    // Đợi logo animation hoàn thành một phần rồi hiển thị nội dung
    await Future.delayed(const Duration(milliseconds: 600));
    _contentController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFB382), // Màu cam nhạt
              Color(0xFFFF8C42), // Màu cam đậm
            ],
          ),
        ),
        child: AnimatedBuilder(
          animation: Listenable.merge([_logoController, _contentController]),
          builder: (context, child) {
            return Column(
              children: [
                // Spacer để đẩy content xuống giữa
                Expanded(flex: 1, child: Container()),

                // Logo và shopname group
                AnimatedBuilder(
                  animation: _logoAnimation,
                  builder: (context, child) {
                    // Animation di chuyển toàn bộ group lên trên
                    double translateY = -(_logoAnimation.value * 50);

                    return Transform.translate(
                      offset: Offset(0, translateY),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo
                          Image.asset(
                            'assets/images/logo.png',
                            width: 120,
                            height: 120,
                            fit: BoxFit.contain,
                          ),

                          const SizedBox(
                            height: 20,
                          ), // Khoảng cách giữa logo và shopname
                          // Shopname với fade in animation
                          AnimatedBuilder(
                            animation: _contentAnimation,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _contentAnimation.value,
                                child: Image.asset(
                                  'assets/images/shopname.png',
                                  width: 280,
                                  height: 80,
                                  fit: BoxFit.contain,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // Loading section
                AnimatedBuilder(
                  animation: _contentAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _contentAnimation.value,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 30),

                          // Loading indicator
                          const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF8B4513),
                            ),
                            strokeWidth: 3,
                          ),

                          const SizedBox(height: 20),

                          // Text "Đang tải..."
                          const Text(
                            'Đang tải...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF8B4513),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // Spacer để cân bằng layout
                Expanded(flex: 1, child: Container()),
              ],
            );
          },
        ),
      ),
    );
  }
}

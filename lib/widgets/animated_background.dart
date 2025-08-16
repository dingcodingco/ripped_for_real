import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  
  const AnimatedBackground({
    super.key,
    required this.child,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _particleController;
  late Animation<double> _animation1;
  late Animation<double> _animation2;
  
  final List<Particle> particles = [];
  final math.Random random = math.Random();

  @override
  void initState() {
    super.initState();
    
    // Gradient animation controllers
    _controller1 = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);
    
    _controller2 = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat(reverse: true);
    
    // Particle animation controller
    _particleController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
    
    _animation1 = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller1,
      curve: Curves.easeInOut,
    ));
    
    _animation2 = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller2,
      curve: Curves.easeInOut,
    ));
    
    // Initialize particles
    for (int i = 0; i < 50; i++) {
      particles.add(Particle(
        position: Offset(
          random.nextDouble(),
          random.nextDouble(),
        ),
        speed: random.nextDouble() * 0.5 + 0.1,
        size: random.nextDouble() * 3 + 1,
        opacity: random.nextDouble() * 0.3 + 0.1,
      ));
    }
    
    _particleController.addListener(() {
      setState(() {
        for (var particle in particles) {
          particle.update();
        }
      });
    });
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Animated gradient background
        AnimatedBuilder(
          animation: Listenable.merge([_animation1, _animation2]),
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(
                    -1 + 2 * _animation1.value,
                    -1 + 2 * _animation1.value,
                  ),
                  end: Alignment(
                    1 - 2 * _animation2.value,
                    1 - 2 * _animation2.value,
                  ),
                  colors: [
                    Colors.black,
                    Colors.grey[900]!,
                    Colors.grey[850]!,
                    Colors.black87,
                  ],
                  stops: const [0.0, 0.3, 0.7, 1.0],
                ),
              ),
            );
          },
        ),
        
        // Particle effects
        CustomPaint(
          painter: ParticlePainter(particles: particles),
          size: Size.infinite,
        ),
        
        // Glowing orbs
        ...List.generate(3, (index) {
          final delay = index * 0.33;
          return AnimatedBuilder(
            animation: _animation1,
            builder: (context, child) {
              final progress = (_animation1.value + delay) % 1.0;
              return Positioned(
                left: MediaQuery.of(context).size.width * 
                    (0.2 + index * 0.3) * 
                    (0.8 + 0.2 * math.sin(progress * math.pi * 2)),
                top: MediaQuery.of(context).size.height * 
                    (0.1 + progress * 0.8),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.orange.withValues(alpha: 0.3),
                        Colors.orange.withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }),
        
        // Main content
        widget.child,
      ],
    );
  }
}

class Particle {
  Offset position;
  final double speed;
  final double size;
  final double opacity;
  
  Particle({
    required this.position,
    required this.speed,
    required this.size,
    required this.opacity,
  });
  
  void update() {
    position = Offset(
      position.dx,
      (position.dy - speed * 0.01) % 1.0,
    );
    
    if (position.dy < 0) {
      position = Offset(position.dx, 1.0);
    }
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  
  ParticlePainter({required this.particles});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    for (final particle in particles) {
      paint.color = Colors.white.withValues(alpha: particle.opacity);
      canvas.drawCircle(
        Offset(
          particle.position.dx * size.width,
          particle.position.dy * size.height,
        ),
        particle.size,
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
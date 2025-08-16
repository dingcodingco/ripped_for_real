import 'package:flutter/material.dart';

class LevelProgressWidget extends StatefulWidget {
  final int level;
  final int currentXP;
  final int maxXP;
  final String levelTitle;
  
  const LevelProgressWidget({
    super.key,
    required this.level,
    required this.currentXP,
    required this.maxXP,
    required this.levelTitle,
  });

  @override
  State<LevelProgressWidget> createState() => _LevelProgressWidgetState();
}

class _LevelProgressWidgetState extends State<LevelProgressWidget>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _glowController;
  late AnimationController _levelUpController;
  late Animation<double> _progressAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _levelUpAnimation;
  
  int _previousLevel = 0;

  @override
  void initState() {
    super.initState();
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _levelUpController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.currentXP / widget.maxXP,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
    
    _levelUpAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _levelUpController,
      curve: Curves.elasticOut,
    ));
    
    _progressController.forward();
    _previousLevel = widget.level;
  }
  
  @override
  void didUpdateWidget(LevelProgressWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.currentXP != widget.currentXP) {
      _progressAnimation = Tween<double>(
        begin: oldWidget.currentXP / widget.maxXP,
        end: widget.currentXP / widget.maxXP,
      ).animate(CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeOutCubic,
      ));
      _progressController.forward(from: 0);
    }
    
    if (oldWidget.level != widget.level && widget.level > _previousLevel) {
      _levelUpController.forward(from: 0);
      _previousLevel = widget.level;
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _glowController.dispose();
    _levelUpController.dispose();
    super.dispose();
  }

  Color _getLevelColor() {
    if (widget.level >= 30) return Colors.amber;
    if (widget.level >= 20) return Colors.purple;
    if (widget.level >= 10) return Colors.blue;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final levelColor = _getLevelColor();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: levelColor.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Level badge with animation
          AnimatedBuilder(
            animation: _levelUpAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + _levelUpAnimation.value * 0.2,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glow effect
                    AnimatedBuilder(
                      animation: _glowAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: levelColor.withValues(
                                  alpha: 0.3 * _glowAnimation.value,
                                ),
                                blurRadius: 20 * _glowAnimation.value,
                                spreadRadius: 5 * _glowAnimation.value,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    // Level icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            levelColor,
                            levelColor.withValues(alpha: 0.7),
                          ],
                        ),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.military_tech,
                              color: Colors.white,
                              size: 32,
                            ),
                            Text(
                              '${widget.level}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          const SizedBox(height: 12),
          
          // Level title
          Text(
            widget.levelTitle.toUpperCase(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: levelColor,
              letterSpacing: 2,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // XP Progress bar
          Container(
            height: 30,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.grey[800]!,
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Stack(
                children: [
                  // Progress fill
                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return FractionallySizedBox(
                        widthFactor: _progressAnimation.value,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                levelColor,
                                levelColor.withValues(alpha: 0.8),
                              ],
                            ),
                          ),
                          child: Stack(
                            children: [
                              // Shimmer effect
                              Positioned.fill(
                                child: AnimatedBuilder(
                                  animation: _glowAnimation,
                                  builder: (context, child) {
                                    return Transform.translate(
                                      offset: Offset(
                                        100 * (_glowAnimation.value - 0.5),
                                        0,
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            colors: [
                                              Colors.transparent,
                                              Colors.white.withValues(alpha: 0.3),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  // XP text
                  Center(
                    child: Text(
                      '${widget.currentXP} / ${widget.maxXP} XP',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Next level preview
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.trending_up,
                color: Colors.grey[400],
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'Next: ${_getNextLevelTitle(widget.level + 1)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  String _getNextLevelTitle(int level) {
    if (level >= 30) return 'MAX LEVEL';
    if (level >= 20) return 'Champion';
    if (level >= 10) return 'Warrior';
    return 'Level $level';
  }
}
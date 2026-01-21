
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/app_colors.dart';

class AnimatedOrderButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Future<void> Function()? onPressedAsync;
  final String label;
  final IconData icon;
  final bool isLoading;

  const AnimatedOrderButton({
    super.key,
    this.onPressed,
    this.onPressedAsync,
    required this.label,
    required this.icon,
    this.isLoading = false,
  }) : assert(onPressed != null || onPressedAsync != null,
  'Either onPressed or onPressedAsync must be provided');

  @override
  State<AnimatedOrderButton> createState() => _AnimatedOrderButtonState();
}

class _AnimatedOrderButtonState extends State<AnimatedOrderButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if ((widget.onPressed != null || widget.onPressedAsync != null) &&
        !_isProcessing &&
        !widget.isLoading) {
      setState(() => _isProcessing = true);
      _controller.forward();
      try {
        if (widget.onPressedAsync != null) {
          await widget.onPressedAsync!();
        } else {
          widget.onPressed!();
        }
      } finally {
        _controller.reverse();
        if (mounted) {
          setState(() => _isProcessing = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasAction = widget.onPressed != null || widget.onPressedAsync != null;
    final isDisabled = !hasAction || _isProcessing || widget.isLoading;

    return MouseRegion(
      onEnter: (_) {
        if (!isDisabled) _controller.forward();
      },
      onExit: (_) {
        if (!isDisabled) _controller.reverse();
      },
      child: GestureDetector(
        onTapDown: (_) {
          if (!isDisabled) _controller.forward();
        },
        onTapUp: (_) {
          if (!isDisabled) {
            _controller.reverse();
            _handleTap();
          }
        },
        onTapCancel: () {
          if (!isDisabled) _controller.reverse();
        },
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDisabled
                    ? [Colors.grey, Colors.grey[700]!]
                    : [AppColors.primary, AppColors.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(50),
              boxShadow: isDisabled
                  ? []
                  : [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isProcessing || widget.isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                else
                  Icon(widget.icon, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class GuidelineTile extends StatefulWidget {
  final IconData icon;
  final String   title;
  final String   body;
  final Color    accentColor;
  final bool     isEn;           // ✅ new param

  const GuidelineTile({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.accentColor = const Color(0xFF4CAF50),
    this.isEn = true,            // ✅ default true
  });

  @override
  State<GuidelineTile> createState() => _GuidelineTileState();
}

class _GuidelineTileState extends State<GuidelineTile>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _controller;
  late final Animation<double>   _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_controller.isAnimating) return;
    setState(() => _expanded = !_expanded);
    _expanded ? _controller.forward() : _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _expanded
              ? widget.accentColor.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _expanded
                ? widget.accentColor.withValues(alpha: 0.35)
                : Colors.white.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ===== HEADER ROW =====
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: widget.accentColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.icon,
                    color: widget.accentColor,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      // ✅ language-aware font size
                      fontSize: widget.isEn ? 12 : 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.3,
                    ),
                    // ✅ allow 2 lines for ML/TA
                    maxLines: widget.isEn ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: _expanded
                        ? widget.accentColor
                        : Colors.white38,
                    size: 18,
                  ),
                ),
              ],
            ),

            // ===== EXPANDED BODY =====
            SizeTransition(
              sizeFactor: _expandAnimation,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, left: 38),
                child: Text(
                  widget.body,
                  style: TextStyle(
                    fontSize: widget.isEn ? 11 : 10,
                    color: Colors.white.withValues(alpha: 0.6),
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
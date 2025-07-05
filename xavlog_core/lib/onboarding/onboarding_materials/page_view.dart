
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/scheduler.dart';
import 'package:xavlog_core/route/welcome.dart';

import 'clipper.dart';

class ConcentricPageView extends StatefulWidget {
  final Function(int index) itemBuilder;
  final Function(int page)? onChange;
  final Function? onFinish;
  final int? itemCount;
  final PageController? pageController;
  final bool pageSnapping;
  final bool reverse;
  final List<Color> colors;
  final ValueNotifier? notifier;
  final double scaleFactor;
  final double opacityFactor;
  final double radius;
  final double verticalPosition;
  final Axis direction;
  final ScrollPhysics? physics;
  final Duration duration;
  final Curve curve;
  final Key? pageViewKey;

  /// Useful for adding a next icon to the page view button
  final WidgetBuilder? nextButtonBuilder;

  const ConcentricPageView({
    super.key,
    required this.itemBuilder,
    required this.colors,
    this.pageViewKey,
    this.onChange,
    this.onFinish,
    this.itemCount,
    this.pageController,
    this.pageSnapping = true,
    this.reverse = false,
    this.notifier,
    this.scaleFactor = 0.3,
    this.opacityFactor = 0.0,
    this.radius = 40.0,
    this.verticalPosition = 0.75,
    this.direction = Axis.horizontal,
    this.physics = const ClampingScrollPhysics(),
    this.duration = const Duration(milliseconds: 1200),
    this.curve = Curves.easeInOutSine, // const Cubic(0.7, 0.5, 0.5, 0.1),
    this.nextButtonBuilder,
  }) : assert(colors.length >= 2);

  @override
  _ConcentricPageViewState createState() => _ConcentricPageViewState();
}

class _ConcentricPageViewState extends State<ConcentricPageView> {
  late PageController _pageController;
  double _progress = 0;
  int _prevPage = 0;
  Color? _prevColor;
  Color? _nextColor;

  @override
  void initState() {
    _prevColor = widget.colors[_prevPage];
    _nextColor = widget.colors[_prevPage + 1];
    _pageController = (widget.pageController ?? PageController(initialPage: 0))
      ..addListener(_onScroll);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.removeListener(_onScroll);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        _buildClipper(),
        _buildPageView(),
        Positioned(
          top: MediaQuery.of(context).size.height * widget.verticalPosition,
          child: _Button(
            pageController: _pageController,
            widget: widget,
          ),
        ),
      ],
    );
  }

  Widget _buildPageView() {
    return PageView.builder(
      key: widget.pageViewKey,
      scrollBehavior: ScrollConfiguration.of(context).copyWith(
        scrollbars: false,
        overscroll: false,
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
        },
      ),
      clipBehavior: Clip.none,
      scrollDirection: widget.direction,
      controller: _pageController,
      reverse: widget.reverse,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.itemCount,
      pageSnapping: widget.pageSnapping,
      // Remove onPageChanged to prevent auto navigation
      itemBuilder: (context, index) {
        final child = widget.itemBuilder(index);
        if (!_pageController.position.hasContentDimensions) {
          return child;
        }
        return AnimatedBuilder(
          animation: _pageController,
          builder: (context, child) {
            final progress = _pageController.page! - index;
            if (widget.opacityFactor != 0) {
              child = Opacity(
                opacity: (1 - (progress.abs() * widget.opacityFactor))
                    .clamp(0.0, 1.0),
                child: child,
              );
            }
            if (widget.scaleFactor != 0) {
              child = Transform.scale(
                scale:
                    (1 - (progress.abs() * widget.scaleFactor)).clamp(0.0, 1.0),
                child: child,
              );
            }
            return child!;
          },
          child: child,
        );
      },
    );
  }

  Widget _buildClipper() {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (ctx, _) {
        return ColoredBox(
          color: _prevColor!,
          child: ClipPath(
            clipper: ConcentricClipper(
              progress: _progress,
              reverse: widget.reverse,
              radius: widget.radius,
              verticalPosition: widget.verticalPosition,
            ),
            child: ColoredBox(
              color: _nextColor!,
              child: const SizedBox.expand(),
            ),
          ),
        );
      },
    );
  }

  void _onScroll() {
    final direction = _pageController.position.userScrollDirection;
    double page = _pageController.page ?? 0;

    if (direction == ScrollDirection.forward) {
      _prevPage = page.toInt();
      _progress = page - _prevPage;
    } else {
      _prevPage = page.toInt();
      _progress = page - _prevPage;
    }

    final total = widget.colors.length;
    final prevIndex = _prevPage % total;
    int nextIndex = prevIndex + 1;

    if (prevIndex == total - 1) {
      nextIndex = 0;
    }

    _prevColor = widget.colors[prevIndex];
    _nextColor = widget.colors[nextIndex];

    widget.notifier?.value = page - _prevPage;
  }
}

class _Button extends StatefulWidget {
  const _Button({
    Key? key,
    required this.pageController,
    required this.widget,
  }) : super(key: key);

  final PageController pageController;
  final ConcentricPageView widget;

  @override
  State<_Button> createState() => _ButtonState();
}

class _ButtonState extends State<_Button> {
  double _holdProgress = 0.0;
  bool _isHolding = false;
  late final int _holdDurationMs;
  late final int _holdTickMs;
  late final int _holdTicksTotal;
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _holdDurationMs = 1500; // 1.5 seconds hold
    _holdTickMs = 30;
    _holdTicksTotal = (_holdDurationMs / _holdTickMs).round();
    _ticker = Ticker(_onTick);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (!_isHolding) return;
    setState(() {
      _holdProgress += 1 / _holdTicksTotal;
      if (_holdProgress >= 1.0) {
        _holdProgress = 1.0;
        _isHolding = false;
        _ticker.stop();
        _showLottieAndNavigate();
      }
    });
  }

  void _showLottieAndNavigate() async {
    // Show the dialog, then after a delay, pop and navigate
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/lottie/driving_life.json',
              width: 320,
              height: 320,
              repeat: true,
            ),
            const SizedBox(height: 16),
            const Text(
              'Going to destination...',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                shadows: [Shadow(blurRadius: 8, color: Colors.black45)],
              ),
            ),
          ],
        ),
      ),
    );
    await Future.delayed(const Duration(milliseconds: 2900));
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      // Navigate directly to the WelcomeScreen widget
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    }
  }

  void _onHoldStart() {
    setState(() {
      _isHolding = true;
      _holdProgress = 0.0;
    });
    _ticker.start();
  }

  void _onHoldEnd() {
    setState(() {
      _isHolding = false;
      _holdProgress = 0.0;
    });
    _ticker.stop();
  }

  @override
  Widget build(BuildContext context) {
    final double buttonSize = widget.widget.radius * 2.2;
    final double glowSize = buttonSize + 10;

    final bool isFinal =
        widget.pageController.page == widget.widget.colors.length - 1;

    final Widget? child = widget.widget.nextButtonBuilder?.call(context);

    // Elegant Ateneo Blue & Metallic Gold
    const Color ateneoBlue = Color(0xFF003A70);
    const Color gold = Color(0xFFFFD700);
    return Semantics(
      button: true,
      label: isFinal ? 'Finish' : 'Next',
      child: GestureDetector(
        onTap: () {
          final int currentPage = widget.pageController.page?.round() ?? 0;
          final bool isFinal = currentPage == widget.widget.colors.length - 1;
          if (isFinal) {
            Navigator.of(context, rootNavigator: true).pushReplacementNamed(
                '/welcome'); // Updated to use the WelcomeScreen route
          } else {
            widget.pageController.nextPage(
              duration: widget.widget.duration,
              curve: widget.widget.curve,
            );
          }
        },
        onLongPressStart: (_) => _onHoldStart(),
        onLongPressEnd: (_) => _onHoldEnd(),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Radiant Gold Glow
            if (_isHolding || _holdProgress > 0)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: glowSize,
                height: glowSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      gold.withOpacity(0.15),
                      ateneoBlue.withOpacity(0.07),
                    ],
                    center: Alignment.center,
                    radius: 0.85,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: gold.withOpacity(0.3),
                      blurRadius: 14,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),

            // Main Button
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [ateneoBlue, ateneoBlue.withOpacity(0.85)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: SizedBox.square(
                dimension: buttonSize,
                child: Center(
                  child: DefaultTextStyle(
                    style: const TextStyle(
                      color: gold,
                      fontWeight: FontWeight.bold,
                    ),
                    child:
                        child ?? const Icon(Icons.arrow_forward, color: gold),
                  ),
                ),
              ),
            ),

            // Circular Progress
            if (_isHolding || _holdProgress > 0)
              SizedBox(
                width: buttonSize - 15,
                height: buttonSize - 15,
                child: CircularProgressIndicator(
                  value: _holdProgress,
                  strokeWidth: 2.5,
                  backgroundColor: gold.withOpacity(0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(gold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

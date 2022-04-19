import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'collapsed.dart';
import 'panel.dart';

class SlidingPanel extends ConsumerStatefulWidget {
  const SlidingPanel({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FloatingPlayerState();
}

class _FloatingPlayerState extends ConsumerState<SlidingPanel> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _collapsedAnimationController;

  late Animation<Offset> _collapsedOffsetAnimation;

  late double maxHeight = 400.0;
  late double minHeight = 60.0;

  // might come in handly with some scrolling inside the panel?
  // curently setting to final just to improve performance even a tad
  final _scrollEnabled = false;

  //VelocityTracker _velocityTracker = VelocityTracker.withKind(PointerDeviceKind.touch);

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 0.0,
    );
    _collapsedAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
      value: 0.0,
    );
    _collapsedOffsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, -1.0),
    ).animate(CurvedAnimation(
      parent: _collapsedAnimationController,
      curve: Curves.decelerate,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        gestureHandler(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Container(
                color: Colors.red,
                height: _animationController.value * (maxHeight - minHeight) + minHeight,
                //margin: const EdgeInsets.only(bottom: kBottomNavigationBarHeight),
                child: child,
              );
            },
            child: Stack(
              children: <Widget>[
                Positioned(
                  top: 0.0,
                  width: MediaQuery.of(context).size.width,
                  child: SizedBox(
                    height: maxHeight,
                    child: const Panel(),
                  ),
                ),
                Positioned(
                  top: 0.0,
                  width: MediaQuery.of(context).size.width,
                  child: ClipRect(
                    child: SlideTransition(
                      position: _collapsedOffsetAnimation,
                      child: SizedBox(
                        height: minHeight,
                        child: const Collapsed(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget gestureHandler({required Widget child}) {
    return GestureDetector(
      child: child,
      onVerticalDragUpdate: (DragUpdateDetails dets) => _onGestureSlide(dets.delta.dy),
      onVerticalDragEnd: (DragEndDetails dets) => _onGestureSlideEnd(dets.velocity),
    );
  }

  void _onGestureSlide(double dy) {
    if (!_scrollEnabled) {
      _animationController.value -= dy / (maxHeight - minHeight);
      _collapsedAnimationController.value = _animationController.value;
    }
  }
  void _onGestureSlideEnd(Velocity velocity) {
    if (_animationController.isAnimating) return;

    double velocityValue = -velocity.pixelsPerSecond.dy / (maxHeight - minHeight);

    // if the velocity + current value is greater than 40% of the max height,
    // then we fully open the panel
    // otherwise, we close it to prevent a half-open state
    if (_animationController.value + velocityValue * 0.3 > 0.4) {
      _animationController.animateTo(
        1.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.decelerate,
      );
      _collapsedAnimationController.animateTo(
        1.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.decelerate,
      );
    } else {
      _animationController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.decelerate,
      );
      _collapsedAnimationController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.decelerate,
      );
    }
  }
}

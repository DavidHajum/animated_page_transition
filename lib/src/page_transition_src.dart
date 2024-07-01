import 'package:flutter/material.dart';

class _PageTransitionController {
  Key pageKey = const ValueKey("page_transition");

  final Duration scaleAnimationDuration = const Duration(milliseconds: 250);
  AnimationController? scaleAnimationController;
  Animation<double>? scaleAnimation;

  initializeAnimationController({required TickerProvider vsync}) {
    scaleAnimationController = AnimationController(
      vsync: vsync,
      duration: scaleAnimationDuration,
    );

    scaleAnimation = Tween(begin: 1.0, end: 0.75).animate(
      CurvedAnimation(
          parent: scaleAnimationController!.view, curve: Curves.easeInExpo),
    );
  }

  animateScaleTransition(
      {required BuildContext context, required Widget routePage}) {
    scaleAnimationController!.forward().then(
      (value) {
        scaleAnimationController!.reverse();
        Navigator.push(
          context,
          CustomPageRoute(
            builder: (context) => routePage,
          ),
        );
      },
    );
  }
}

class PageTransitionButton extends StatefulWidget {
  const PageTransitionButton({
    Key? key,
    required this.vsync,
    required this.child,
    required this.nextPage,
  }) : super(key: key);

  /// Provide [TickerProvider] for animation purpose
  final TickerProvider vsync;

  /// Child property. Pass your button here.
  final Widget child;

  /// Pass the widget of the next screen where you want to navigate the user.
  final Widget nextPage;

  @override
  State<PageTransitionButton> createState() => _PageTransitionButtonState();
}

class _PageTransitionButtonState extends State<PageTransitionButton> {
  final _PageTransitionController _homeScreenController =
      _PageTransitionController();

  @override
  void initState() {
    super.initState();
    _homeScreenController.initializeAnimationController(vsync: widget.vsync);
  }

  runAnimation() {
    _homeScreenController.animateScaleTransition(
      context: context,
      routePage: widget.nextPage,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _homeScreenController.scaleAnimationController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _homeScreenController.scaleAnimation!,
      child: Hero(
        tag: /*"page_transition"*/ _homeScreenController.pageKey,
        child: widget.child,
      ),
    );
  }
}

class PageTransitionReceiver extends StatelessWidget {
  PageTransitionReceiver({Key? key, required this.scaffold}) : super(key: key);

  /// Provide scaffold of the destination screen
  final Scaffold scaffold;

  final _PageTransitionController _pageTransitionController =
      _PageTransitionController();

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: _pageTransitionController.pageKey,
      child: scaffold,
    );
  }
}

class CustomPageRoute extends MaterialPageRoute {
  CustomPageRoute({builder}) : super(builder: builder);

  @override
  Duration get transitionDuration => const Duration(milliseconds: 0);
}

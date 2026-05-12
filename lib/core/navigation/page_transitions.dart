import 'package:flutter/material.dart';

class PageTransitions {
  static PageRoute<T> slide<T>({
    required WidgetBuilder builder,
    required String? routeName,
  }) {
    return PageRouteBuilder<T>(
      settings: RouteSettings(name: routeName),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  static PageRoute<T> fade<T>({
    required WidgetBuilder builder,
    required String? routeName,
  }) {
    return PageRouteBuilder<T>(
      settings: RouteSettings(name: routeName),
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  static PageRoute<T> scale<T>({
    required WidgetBuilder builder,
    required String? routeName,
  }) {
    return PageRouteBuilder<T>(
      settings: RouteSettings(name: routeName),
      transitionDuration: const Duration(milliseconds: 450),
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.0;
        const end = 1.0;
        const curve = Curves.easeInOutCubic;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return ScaleTransition(
          scale: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  static PageRoute<T> rotate<T>({
    required WidgetBuilder builder,
    required String? routeName,
  }) {
    return PageRouteBuilder<T>(
      settings: RouteSettings(name: routeName),
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.0;
        const end = 1.0;
        const curve = Curves.elasticOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return RotationTransition(
          turns: animation.drive(tween),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.5, end: 1.0).animate(animation),
            child: child,
          ),
        );
      },
    );
  }

  static PageRoute<T> combined<T>({
    required WidgetBuilder builder,
    required String? routeName,
  }) {
    return PageRouteBuilder<T>(
      settings: RouteSettings(name: routeName),
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var slideAnimation =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        var scaleAnimation = Tween<double>(begin: 0.95, end: 1.0)
            .chain(CurveTween(curve: curve));

        var fadeAnimation =
            Tween<double>(begin: 0.8, end: 1.0).animate(animation);

        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: animation.drive(scaleAnimation),
            child: SlideTransition(
              position: animation.drive(slideAnimation),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

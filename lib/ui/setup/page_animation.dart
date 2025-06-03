import 'package:flutter/material.dart';

class FadeNavigator {
  final BuildContext context;

  FadeNavigator(this.context);

  Future<T?> navigateTo<T extends Object?>(Widget page) {
    print("NEW ROUTE: ${page.runtimeType.toString()}");
    // return Navigator.of(context).push(PageRouteBuilder(
    return Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => page,
        // transitionsBuilder: (context, animation, secondaryAnimation, child) {
        //   const begin = 0.0;
        //   const end = 1.0;
        //   const curve = Curves.slowMiddle;

        //   var tween =
        //       Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        //   return FadeTransition(
        //     opacity: animation.drive(tween),
        //     child: child,
        //   );
        // },
        settings: RouteSettings(name: page.runtimeType.toString())));
  }

  Future<T?> navigateToReplace<T extends Object?>(Widget page, {String? customName}) {
    print("NEW ROUTE: ${page.runtimeType.toString()}");
    // return Navigator.of(context).push(PageRouteBuilder(
    return Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => page,
        // transitionsBuilder: (context, animation, secondaryAnimation, child) {
        //   const begin = 0.0;
        //   const end = 1.0;
        //   const curve = Curves.slowMiddle;

        //   var tween =
        //       Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        //   return FadeTransition(
        //     opacity: animation.drive(tween),
        //     child: child,
        //   );
        // },
        settings: RouteSettings(name: customName??page.runtimeType.toString())));
  }
}

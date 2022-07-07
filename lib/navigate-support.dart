import 'package:flutter/material.dart';

class Posit<T> {
  /// Key of posit
  final dynamic key;

  /// Title of posit
  final String? title;

  /// Icon of posit
  final dynamic icon;

  /// Fragment of posit
  final Widget Function(dynamic params) fragmentBuilder;

  /// Drawer title
  final String? drawerTitle;

  /// Params
  final T? params;

  const Posit(
      {required this.key,
      required this.fragmentBuilder,
      this.title,
      this.icon,
      this.params,
      this.drawerTitle});
}

class FullPosit<T> {
  final dynamic key;
  final String? title;
  final T? params;
  final Bottom? bottom;
  final Widget fragment;
  final List<Widget>? actions;
  final Widget? floatingAction;

  const FullPosit(
      {required this.key,
      required this.title,
      required this.fragment,
      required this.actions,
      required this.bottom,
      this.params,
      required this.floatingAction});

  factory FullPosit.byPosit(
      {required Posit<T> posit,
      List<Widget>? actions,
      dynamic params,
      Widget? floatingAction,
      Bottom? bottom}) {
    return FullPosit<T>(
        fragment: posit.fragmentBuilder(params),
        floatingAction: floatingAction,
        params: posit.params,
        title: posit.title,
        actions: actions,
        bottom: bottom,
        key: posit.key);
  }
}

class Bottom {
  /// Length of bottom
  final int length;

  /// Child
  final PreferredSizeWidget? child;

  const Bottom({required this.length, required this.child});

  factory Bottom.byBottomPosit({BottomPosit? bottomPosit}) {
    if (bottomPosit != null)
      return Bottom(length: bottomPosit.length, child: bottomPosit.child);

    return Bottom(length: 1, child: null);
  }

  @override
  String toString() {
    return 'Bottom{length: $length, child: $child}';
  }
}

class ActionPosit {
  /// List of keys that I have will have these actions
  final List<dynamic> keys;

  /// List of actions
  final List<Widget> actions;

  const ActionPosit({required this.keys, required this.actions});
}

class BottomPosit {
  /// Child
  final PreferredSizeWidget child;

  /// List of keys that I have will have these bottom
  final List<dynamic> keys;

  /// Length
  final int length;

  const BottomPosit(
      {required this.keys, required this.length, required this.child});
}

class FloatingPosit {
  /// List of keys that I have will have these floating
  final List<dynamic> keys;

  /// Widget
  final Widget child;

  FloatingPosit({required this.keys, required this.child});
}

abstract class ActionInterface {
  Future<bool> onPut();
  Future<bool> onBack();
  void action(String tag, {dynamic params});
}

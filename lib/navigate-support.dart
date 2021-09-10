import 'package:flutter/material.dart';

class Posit {
  /// Key of posit
  final dynamic key;

  /// Title of posit
  final String? title;

  /// Icon of posit
  final dynamic icon;

  /// Fragment of posit
  final Widget fragment;

  /// Drawer title
  final String? drawerTitle;

  /// Permission level
  final dynamic permissionLevel;

  const Posit(
      {required this.key,
      required this.fragment,
      this.title,
      this.icon,
      this.permissionLevel,
      this.drawerTitle});
}

class FullPosit {
  final dynamic key;
  final String? title;
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
      required this.floatingAction});

  factory FullPosit.byPosit(
      {required Posit posit,
      List<Widget>? actions,
      Widget? floatingAction,
      Bottom? bottom}) {
    return FullPosit(
        bottom: bottom,
        key: posit.key,
        actions: actions,
        title: posit.title,
        fragment: posit.fragment,
        floatingAction: floatingAction);
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
  void action(String tag, {Object params});
}

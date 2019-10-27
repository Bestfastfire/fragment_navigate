import 'package:flutter/material.dart';

class Posit{
  final dynamic key;
  final String title;
  final Widget fragment;

  const Posit({@required this.key, @required this.title, @required this.fragment});
}

class FullPosit{
  final dynamic key;
  final String title;
  final Bottom bottom;
  final Widget fragment;
  final List<Widget> actions;

  const FullPosit({@required this.key, @required this.title, @required this.fragment, @required this.actions, @required this.bottom});

  factory FullPosit.byPosit({@required Posit posit, @required List<Widget> actions, @required Bottom bottom}){
    return FullPosit(
      bottom: bottom,
      key: posit.key,
      actions: actions,
      title: posit.title,
      fragment: posit.fragment,
    );
  }
}

class Bottom{
  final int length;
  final PreferredSizeWidget child;

  const Bottom({@required this.length, @required this.child});

  factory Bottom.byBottomPosit({@required BottomPosit bottomPosit}){
    if(bottomPosit != null){
      return Bottom(
        length: bottomPosit.length,
        child: bottomPosit.child
      );
    }

    return Bottom(
      length: 1,
      child: null
    );
  }

  @override
  String toString() {
    return 'Bottom{length: $length, child: $child}';
  }
}

class ActionPosit{
  final List<dynamic> keys;
  final List<Widget> actions;

  const ActionPosit({@required this.keys, @required this.actions});
}

class BottomPosit{
  final PreferredSizeWidget child;
  final List<dynamic> keys;
  final int length;

  const BottomPosit({@required this.keys, @required this.length, @required this.child});
}

abstract class ActionInterface{
  void action(String tag, {Object params});
}
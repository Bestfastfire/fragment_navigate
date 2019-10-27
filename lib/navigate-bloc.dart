import 'package:fragment_navigate/navigate-support.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

export 'package:fragment_navigate/widgets/widgets-support.dart';
export 'package:fragment_navigate/navigate-support.dart';

class FragNavigate implements BlocBase {
  final GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  final _fragment = BehaviorSubject<FullPosit>();
  final Map<dynamic, Posit> _screens = {};
  final List<ActionPosit> actionsList;
  final List<BottomPosit> bottomList;
  final List<Posit> _stack = [];
  BuildContext drawerContext;

  final Function(dynamic oldKey, dynamic newKey) onBack;
  final Function(dynamic oldKey, dynamic newKey) onPut;

  Stream<FullPosit> get outStreamFragment => _fragment.stream;
  dynamic get currentKey => _fragment.stream.value.key;
  GlobalKey<ScaffoldState> get drawerKey => _drawerKey;

  set setDrawerContext(BuildContext c) => drawerContext = c;
  set setInterface(Object obj) => _interface = obj;

  ActionInterface _interface;

  static FragNavigate _instance;
  factory FragNavigate(
      {@required dynamic firstKey,
      @required List<Posit> screens,
      BuildContext drawerContext,
      List<BottomPosit> bottomList,
      List<ActionPosit> actionsList,
      Function(dynamic oldKey, dynamic newKey) onBack,
      Function(dynamic oldKey, dynamic newKey) onPut}) {
    _instance ??= FragNavigate._internal(
      onPut: onPut,
      onBack: onBack,
      screens: screens,
      firstKey: firstKey,
      bottomList: bottomList,
      actionsList: actionsList,
      drawerContext: drawerContext,
    );
    return _instance;
  }

  FragNavigate._internal(
      {@required List<Posit> screens,
      @required this.drawerContext,
      @required dynamic firstKey,
      this.actionsList = const [],
      this.bottomList = const [],
      this.onBack,
      this.onPut}) {
    screens.forEach((i) => _screens[i.key] = i);
    putPosit(key: firstKey, force: true);
  }

  List<Widget> _getActions({@required key}) {
    if (actionsList.isNotEmpty) {
      ActionPosit item = actionsList.firstWhere((v) => v.keys.contains(key),
          orElse: () => null);

      return item != null ? item.actions : null;
    }

    return null;
  }

  Bottom _getBottom({@required key}) {
    if (bottomList.isNotEmpty) {
      BottomPosit item = bottomList.firstWhere((v) => v.keys.contains(key),
          orElse: () => null);

      return Bottom.byBottomPosit(bottomPosit: item);
    }

    return null;
  }

  action(String tag, {Object params}) {
    if (_interface != null) {
      _interface.action(tag, params: params);
    }
  }

  putPosit(
      {@required dynamic key, bool force = false, bool closeDrawer = true}) {
    if (force || _stack.isEmpty || _stack.last.key != key) {
      _onPut(_stack.isNotEmpty ? _stack.last.key : null, key);

      if (_drawerKey.currentState != null &&
          _drawerKey.currentState.isDrawerOpen &&
          closeDrawer) {
        Navigator.pop(drawerContext);
      }

      _stack.add(_screens[key]);
      _fragment.sink.add(FullPosit.byPosit(
          posit: _stack.last,
          bottom: _getBottom(key: key),
          actions: _getActions(key: key)));
    }
  }

  putAndReplace(
      {@required dynamic key, bool force = true, bool closeDrawer = true}) {
    _onPut(_stack.isNotEmpty ? _stack.last.key : null, key);

    _stack.removeLast();
    putPosit(key: key, force: force, closeDrawer: closeDrawer);
  }

  putAndClean(
      {@required dynamic key, bool force = true, bool closeDrawer = true}) {
    _onPut(_stack.isNotEmpty ? _stack.last.key : null, key);

    _stack.clear();
    putPosit(key: key, force: force, closeDrawer: closeDrawer);
  }

  Future<bool> jumpBack() async {
    if (_drawerKey.currentState != null &&
        _drawerKey.currentState.isDrawerOpen) {
      Navigator.pop(drawerContext);
      return false;
    } else if (_stack.length > 1) {
      String old = _stack.isNotEmpty ? _stack.last.key : null;

      _stack.removeLast();
      _onBack(old, _stack.last.key);

      _fragment.sink.add(FullPosit.byPosit(
          posit: _stack.last,
          bottom: _getBottom(key: _stack.last.key),
          actions: _getActions(key: _stack.last.key)));
      return false;
    }

    return true;
  }

  jumpBackToFirst() {
    String old = _stack.isNotEmpty ? _stack.last.key : null;

    while (_stack.length > 1) {
      _stack.removeLast();
    }

    _onBack(old, _stack.last.key);

    _fragment.sink.add(FullPosit.byPosit(
        posit: _stack.last,
        bottom: _getBottom(key: _stack.last.key),
        actions: _getActions(key: _stack.last.key)));
  }

  _onPut(String old, String newKey) {
    if (onPut != null) {
      onPut(old, newKey);
    }
  }

  _onBack(String old, String newKey) {
    if (onBack != null) {
      onBack(old, newKey);
    }
  }

  @override
  void dispose() {
    _fragment.close();
  }

  @override
  void addListener(listener) {}

  @override
  bool get hasListeners => null;

  @override
  void notifyListeners() {}

  @override
  void removeListener(listener) {}
}

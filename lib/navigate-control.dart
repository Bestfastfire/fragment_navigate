import 'package:fragment_navigate/navigate-support.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

export 'package:fragment_navigate/widgets/widgets-support.dart';
export 'package:fragment_navigate/navigate-support.dart';
import 'package:collection/collection.dart';

abstract class _BlocBase {
  void dispose();
}

class FragNavigate implements _BlocBase {
  /// Drawer key to close drawer when call jumpBack
  final GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  /// Fragment stream
  final _fragment = BehaviorSubject<FullPosit>();

  /// Screen Posit List
  final Map<dynamic, Posit> screenList = {};

  /// Floating List
  final List<FloatingPosit>? floatingList;

  /// Action List
  final List<ActionPosit>? actionsList;

  /// Bottom List
  final List<BottomPosit>? bottomList;

  /// Stack List
  final List<Posit> stack = [];

  /// Drawer context
  BuildContext? drawerContext;

  /// OnBack function
  final Function(dynamic oldKey, dynamic newKey)? onBack;

  /// OnPut function
  final Function(dynamic oldKey, dynamic newKey)? onPut;

  /// Fragment stream
  Stream<FullPosit> get outStreamFragment => _fragment.stream;
  dynamic get currentKey => _fragment.stream.value.key;
  GlobalKey<ScaffoldState> get drawerKey => _drawerKey;

  /// Drawer controller
  set setDrawerContext(BuildContext c) => drawerContext = c;
  set setInterface(dynamic obj) => _interface = obj;

  ActionInterface? _interface;

  static FragNavigate? _instance;
  factory FragNavigate(
      {required dynamic firstKey,
      required List<Posit> screens,
      BuildContext? drawerContext,
      List<BottomPosit>? bottomList,
      List<ActionPosit>? actionsList,
      List<FloatingPosit>? floatingPosit,
      Function(dynamic oldKey, dynamic newKey)? onBack,
      Function(dynamic oldKey, dynamic newKey)? onPut}) {
    _instance ??= FragNavigate._internal(
        onPut: onPut,
        onBack: onBack,
        screens: screens,
        firstKey: firstKey,
        bottomList: bottomList,
        actionsList: actionsList,
        floatingList: floatingPosit,
        drawerContext: drawerContext);

    return _instance!;
  }

  FragNavigate._internal(
      {required List<Posit> screens,
      required this.drawerContext,
      required dynamic firstKey,
      this.floatingList = const [],
      this.actionsList = const [],
      this.bottomList = const [],
      this.onBack,
      this.onPut}) {
    screens.forEach((i) => screenList[i.key] = i);
    putPosit(key: firstKey, force: true);
  }

  /// Get actions in appBar
  List<Widget>? _getActions({@required key}) {
    if (actionsList != null && actionsList!.isNotEmpty) {
      final item =
          actionsList?.firstWhereOrNull((v) => v.keys.contains(key)) ?? null;

      return item != null ? item.actions : null;
    }

    return null;
  }

  /// Get bottom in appBar
  Bottom _getBottom({@required key}) {
    if (bottomList != null && bottomList!.isNotEmpty) {
      BottomPosit? item =
          bottomList?.firstWhereOrNull((v) => v.keys.contains(key));

      return Bottom.byBottomPosit(bottomPosit: item);
    }

    return Bottom(length: 1, child: null);
  }

  /// Get widget of floatingButton
  Widget? _getFloating({@required key}) {
    if (floatingList != null && floatingList!.isNotEmpty) {
      FloatingPosit? item =
          floatingList?.firstWhereOrNull((v) => v.keys.contains(key));

      return item != null ? item.child : null;
    }

    return null;
  }

  /// Call action in interface
  action(String tag, {dynamic params}) {
    if (_interface != null) _interface!.action(tag, params: params);
  }

  /// Put new key
  Future<bool> putPosit(
      {required dynamic key,
      bool force = false,
      bool closeDrawer = true}) async {
    if (_interface != null) {
      if (!force && !await _interface!.onPut()) {
        return false;
      }
    }

    if (force || stack.isEmpty || stack.last.key != key) {
      _onPut(stack.isNotEmpty ? stack.last.key : null, key);

      if (_drawerKey.currentState != null &&
          _drawerKey.currentState!.isDrawerOpen &&
          closeDrawer) {
        Navigator.pop(drawerContext!);
      }

      stack.add(screenList[key]!);
      _fragment.sink.add(FullPosit.byPosit(
          posit: stack.last,
          bottom: _getBottom(key: key),
          actions: _getActions(key: key),
          floatingAction: _getFloating(key: key)));

      return true;
    }

    return false;
  }

  /// Put key and replace current
  Future<bool> putAndReplace(
      {@required dynamic key,
      bool force = true,
      bool closeDrawer = true}) async {
    if (_interface != null) {
      if (!force && !await _interface!.onPut()) {
        return false;
      }
    }

    _onPut(stack.isNotEmpty ? stack.last.key : null, key);

    stack.removeLast();
    return await putPosit(key: key, force: force, closeDrawer: closeDrawer);
  }

  /// Put key and clean all
  Future<bool> putAndClean(
      {@required dynamic key,
      bool force = true,
      bool closeDrawer = true}) async {
    if (_interface != null) {
      if (!force && !await _interface!.onPut()) {
        return false;
      }
    }

    _onPut(stack.isNotEmpty ? stack.last.key : null, key);
    stack.clear();

    return await putPosit(key: key, force: force, closeDrawer: closeDrawer);
  }

  /// Jump back to last key
  Future<bool> jumpBack() async {
    if (_drawerKey.currentState != null &&
        _drawerKey.currentState!.isDrawerOpen) {
      Navigator.pop(drawerContext!);
      return false;
    } else if (stack.length > 1) {
      String old = stack.isNotEmpty ? stack.last.key : null;
      if (_interface != null) {
        if (!await _interface!.onBack()) {
          return false;
        }
      }

      stack.removeLast();
      _onBack(old, stack.last.key);

      _fragment.sink.add(FullPosit.byPosit(
        posit: stack.last,
        bottom: _getBottom(key: stack.last.key),
        actions: _getActions(key: stack.last.key),
        floatingAction: _getFloating(key: stack.last.key),
      ));

      return false;
    }

    return true;
  }

  /// Jump back to key passed and clean all after
  jumpBackTo(dynamic key) {
    String old = stack.isNotEmpty ? stack.last.key : null;
    int index = -1;

    for (int i = 0; i < stack.length; i++) {
      final item = stack[i];

      if (item.key.toString() == key.toString()) {
        index = i;
        break;
      }
    }

    if (index > -1) {
      while (stack.length > index) {
        stack.removeLast();

      }

      _onBack(old, stack.last.key);

      _fragment.sink.add(FullPosit.byPosit(
          posit: stack.last,
          bottom: _getBottom(key: stack.last.key),
          actions: _getActions(key: stack.last.key),
          floatingAction: _getFloating(key: stack.last.key)));
    }
  }

  /// Jump back to first key and clean all
  Future<bool> jumpBackToFirst() async {
    String old = stack.isNotEmpty ? stack.last.key : null;

    if (stack.length > 1) {
      if (_interface != null) {
        if (!await _interface!.onBack()) {
          return false;
        }
      }
    }

    while (stack.length > 1)
      stack.removeLast();

    _onBack(old, stack.last.key);

    _fragment.sink.add(FullPosit.byPosit(
        posit: stack.last,
        bottom: _getBottom(key: stack.last.key),
        actions: _getActions(key: stack.last.key),
        floatingAction: _getFloating(key: stack.last.key)));

    return true;
  }

  /// onPut in class
  _onPut(dynamic old, dynamic newKey) {
    if (onPut != null)
      onPut!(old, newKey);

  }

  /// onBack in class
  _onBack(dynamic old, dynamic newKey) {
    if (onBack != null) onBack!(old, newKey);
  }

  @override
  void dispose() => _fragment.close();
}

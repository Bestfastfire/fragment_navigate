import 'package:fragment_navigate/navigate-support.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

export 'package:fragment_navigate/widgets/widgets-support.dart';
export 'package:fragment_navigate/navigate-support.dart';

abstract class _BlocBase {
  void dispose();
}

extension _IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
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
  final List<FullPosit> stack = [];

  /// Drawer context
  BuildContext? drawerContext;

  /// OnBack function
  final Function(dynamic oldKey, dynamic newKey)? onBack;

  /// OnPut function
  final Function(dynamic oldKey, dynamic newKey)? onPut;

  /// Fragment stream
  Stream<FullPosit> get outStreamFragment => _fragment.stream;
  GlobalKey<ScaffoldState> get drawerKey => _drawerKey;
  dynamic get currentKey => stack.last.key;

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

  factory FragNavigate.restart(
      {required dynamic firstKey,
      required List<Posit> screens,
      BuildContext? drawerContext,
      List<BottomPosit>? bottomList,
      List<ActionPosit>? actionsList,
      List<FloatingPosit>? floatingPosit,
      Function(dynamic oldKey, dynamic newKey)? onBack,
      Function(dynamic oldKey, dynamic newKey)? onPut}) {
    _instance = FragNavigate._internal(
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
  Future<bool> putPosit<K>(
      {required dynamic key,
      bool force = false,
      bool closeDrawer = true,
      K? params}) async {
    if (_interface != null) {
      if (!force && !await _interface!.onPut()) {
        return false;
      }
    }

    if (force || stack.isEmpty || stack.last.key != key) {
      _onPut(stack.isNotEmpty ? stack.last.key : null, key);

      if (closeDrawer &&
          _drawerKey.currentState != null &&
          _drawerKey.currentState!.isDrawerOpen) {
        Navigator.pop(drawerContext!);
      }

      final _position = FullPosit.byPosit(
          floatingAction: _getFloating(key: key),
          actions: _getActions(key: key),
          bottom: _getBottom(key: key),
          posit: screenList[key]!,
          params: params);

      stack.add(_position);
      _fragment.sink.add(stack.last);

      return true;
    }

    return false;
  }

  /// Put key and replace current
  Future<bool> putAndReplace<K>(
      {@required dynamic key,
      bool force = true,
      K? params,
      bool closeDrawer = true}) async {
    if (_interface != null) {
      if (!force && !await _interface!.onPut()) {
        return false;
      }
    }

    _onPut(stack.isNotEmpty ? stack.last.key : null, key);
    stack.removeLast();

    return await putPosit(
        closeDrawer: closeDrawer, params: params, force: force, key: key);
  }

  /// Put key and clean all
  Future<bool> putAndClean<K>(
      {@required dynamic key,
      bool force = true,
      K? params,
      bool closeDrawer = true}) async {
    if (_interface != null) {
      if (!force && !await _interface!.onPut()) {
        return false;
      }
    }

    _onPut(stack.isNotEmpty ? stack.last.key : null, key);
    stack.clear();

    return await putPosit(
        key: key, force: force, closeDrawer: closeDrawer, params: params);
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
      _fragment.sink.add(stack.last);

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

      _fragment.sink.add(stack.last);
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

    while (stack.length > 1) {
      stack.removeLast();
    }

    _onBack(old, stack.last.key);
    _fragment.sink.add(stack.last);

    return true;
  }

  /// onPut in class
  _onPut(dynamic old, dynamic newKey) {
    if (onPut != null) onPut!(old, newKey);
  }

  /// onBack in class
  _onBack(dynamic old, dynamic newKey) {
    if (onBack != null) onBack!(old, newKey);
  }

  @override
  void dispose() => _fragment.close();
}

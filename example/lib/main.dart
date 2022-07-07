import 'package:fragment_navigate/navigate-control.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const Main());
  }
}

class Main extends StatelessWidget {
  static const String a = 'a';
  static const String b = 'b';
  static const String c = 'c';
  static const String d = 'd';

  static final FragNavigate _fragNav =
      FragNavigate(firstKey: a, drawerContext: null, screens: <Posit>[
    Posit(
        key: a,
        title: 'Title A',
        icon: Icons.settings,
        fragmentBuilder: (dynamic p) => Container(color: Colors.amberAccent)),
    Posit(
        key: b,
        title: 'Title B',
        drawerTitle: 'Diff in B',
        icon: Icons.settings,
        fragmentBuilder: (p) => const SecondScreen()),
    Posit(
        key: c,
        title: 'Title C',
        icon: Icons.settings,
        fragmentBuilder: (p) => Container(color: Colors.blueAccent)),
    Posit(
        key: d,
        title: 'Title D',
        icon: Icons.settings,
        fragmentBuilder: (p) => Text(p as String)),
  ], actionsList: [
    ActionPosit(keys: [
      a,
      b,
      c
    ], actions: [
      IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            _fragNav.action('teste');
          })
    ])
  ], bottomList: [
    const BottomPosit(
        keys: [a, b, c],
        length: 2,
        child: TabBar(
          indicatorColor: Colors.white,
          tabs: <Widget>[Text('a'), Text('b')],
        ))
  ]);

  const Main({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _fragNav.setDrawerContext = context;

    return StreamBuilder<FullPosit>(
        stream: _fragNav.outStreamFragment,
        builder: (con, s) {
          if (s.data != null) {
            if (s.data?.params is Map) {
              print('Params passeds: ${s.data?.params}');
            }

            return DefaultTabController(
                length: s.data!.bottom?.length ?? 1,
                child: Scaffold(
                    key: _fragNav.drawerKey,
                    appBar: AppBar(
                      title: Text(s.data!.title ?? 'NULL'),
                      actions: s.data?.actions,
                      bottom: s.data?.bottom?.child,
                    ),
                    drawer: CustomDrawer(fragNav: _fragNav),
                    body: ScreenNavigate(
                        child: s.data!.fragment, control: _fragNav)));
          }

          return Container();
        });
  }
}

class SecondScreen extends StatelessWidget implements ActionInterface {
  const SecondScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.purple,
    );
  }

  @override
  void action(String tag, {dynamic params}) {
    print('called on secondScreen with tag: $tag');
  }

  @override
  Future<bool> onBack() async {
    return true;
  }

  @override
  Future<bool> onPut() async {
    return true;
  }
}

class CustomDrawer extends StatelessWidget {
  final FragNavigate fragNav;
  const CustomDrawer({Key? key, required this.fragNav}) : super(key: key);

  Widget _getItem(
      {required String currentSelect,
      required text,
      required key,
      required icon}) {
    Color _getColor() => currentSelect == key ? Colors.white : Colors.black87;

    return Material(
        color: currentSelect == key ? Colors.blueAccent : Colors.transparent,
        child: ListTile(
            leading:
                Icon(icon, color: currentSelect == key ? Colors.white : null),
            selected: currentSelect == key,
            title: Text(text, style: TextStyle(color: _getColor())),
            onTap: () => fragNav.putPosit<int>(key: key, params: 1)));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          const DrawerHeader(
            child: Text('Drawer Header'),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
            ),
          ),
          for (Posit item in fragNav.screenList.values)
            _getItem(
                currentSelect: fragNav.currentKey,
                text: item.drawerTitle ?? item.title,
                key: item.key,
                icon: item.icon)
        ],
      ),
    );
  }
}

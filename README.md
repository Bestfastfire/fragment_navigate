# Fragment Navigate
Check it out at [Pub.Dev](https://pub.dev/packages/fragment_navigate)

A controller to make the effect of swapping fragments like in native Android.

![ezgif com-video-to-gif-2](https://user-images.githubusercontent.com/22732544/67630039-b7c17000-f85f-11e9-83f3-c70f7869b178.gif)

Stack Feature:

![ezgif com-video-to-gif](https://user-images.githubusercontent.com/22732544/67629822-1c2e0080-f85b-11e9-9639-8a83872999ab.gif)

## Help Maintenance

I've been maintaining quite many repos these days and burning out slowly. If you could help me cheer up, buying me a cup of coffee will make my life really happy and get much energy out of it.

<a href="https://www.buymeacoffee.com/RtrHv1C" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/purple_img.png" alt="Buy Me A Coffee" style="height: auto !important;width: auto !important;" ></a>

## Getting Started
You must first create an object with the following attributes:

    static final _fragNav = FragNavigate(
        firstKey: 'a',
        screens: <Posit>[
            // T is typeof "params"
            Posit<T>(
              key: a,
              title: 'Title A',
              fragmentBuilder: (p) => Container(color: Colors.amberAccent),
              params: {'value': "x"}
            ),
            Posit(
              key: b,
              title: 'Title B',
              fragmentBuilder: (p) => Text('Test B...')
            ),
            Posit(
              key: c,
              title: 'Title C',
              fragmentBuilder: (p) => Container(color: Colors.blueAccent,)
            ),
            Posit(
              key: d,
              title: 'Title D',
              fragmentBuilder: (p) => Text(p as String)
            ),
        ],
        actionsList: [
            ActionPosit(
              keys: [a, b, c],
              actions: [
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: (){
                    _fragNav.action('teste');
                  }
                )
              ]
            )
          ],
      bottomList: [
        BottomPosit(
          keys: [a, b, c],
          length: 2,
          child: TabBar(
            indicatorColor: Colors.white,
            tabs: <Widget>[
              Text('a'),
              Text('b')
            ],
          )
        )
      ]
    )

### Screens:
In `Screens`, you need pass one list of `Posit`, to every `Posit` in `screens`, you need pass one unique key, one title and one *Widget*

### ActionsList:
Here you pass one list of `ActionPosit`, to every `ActionPosit`, you parse one list of *keys* and one list of *Widgets*, the keys is the same keys of screens to show this actions. In click action of your Widget, you can call `_fragNav.action('tag', params: 'any object');`

### _fragNav.action('tag')
To use it, your widget need implements interface: `ActionInterface`, and the action will called in:

    @override
    void action(String tag, {dynamic params}) {
        switch(tag){
            case 'tag': ...
        }
    }

### BottomList:
Here is like `ActionsList`, but the difference is you need pass length of tabs and the child is one `PreferedSizedWidget`.

## Mounting Layout
Case the controller of fragments is one Drawer, you need set in build this value: `_fragNav.setDrawerContext = context;`, this is useful when you change fragment or click in back button, Case the controller of fragments is one Drawer, you need set in build this value: `_fragNav.setDrawerContext = context;`, this is useful when you change fragment or click in back button, then drawer close.
    
    @override
    Widget build(BuildContext context) {
        _fragNav.setDrawerContext = context;

        return StreamBuilder<FullPosit>(
            stream: _fragNav.outStreamFragment,
            builder: (con, s){
              if(s.data != null){
                if(s.data!.params is Map){
                  print('Params passeds: ${s.data?.params}');
                  
                }
            
                return DefaultTabController(
                    length: s.data.bottom.length,
                    child: Scaffold(
                      key: _fragNav.drawerKey,
                      appBar: AppBar(
                        title: Text(s.data.title),
                        actions: s.data.actions,
                        bottom: s.data.bottom.child,
                      ),
                      drawer: CustomDrawer(bloc: _fragNav),
                      body: ScreenNavigate(
                          child: s.data.fragment,
                          control: _fragNav
                      ),
                    )
                );
            }

          return Container();
        }
    );
    
Use one `StreamBuilder` passing like stream `_fragNav.outStreamFragment`, and it return one `FullPosit`:

    FullPosit(
      bottom: => BottomPosit(
          keys => list,
          length => size, 
          child => PreferedSizedWidget
      ),
      key: key,
      actions: actions,
      title: title,
      fragment: fragment,
    );

*IMPORTANT*
Case you will use the `BottomList`, remember that you need pass your `Scaffold` in one `TabController` like example above.

To set actual fragment, title and bottom only make this in scaffold:

    Scaffold(
      key: _fragNav.drawerKey, // Pass it to controller Drawer on back and on put fragment
      appBar: AppBar(
        title: Text(snapshot.data.title),
        actions: snapshot.data.actions,
        bottom: snapshot.data.bottom.child,
      ),
      drawer: CustomDrawer(bloc: _fragNav),
      body: ScreenNavigate(
          child: snapshot.data.fragment,
          control: _fragNav
      ),
    )
    
## ScreenNavigate
In body of `Scaffold`, pass the `ScreenNavigate` like this:

    ScreenNavigate(
      child: snapshot.data.fragment,
      control: _fragNav
    )
    
It will make effect FadeIn on changed fragments.

## Drawer
In every item of Drawer that call one new fragment ou can do it:

    ListTile(
      leading: Icon(Icons.settings, color: currentSelect == key ? Colors.white : null), //
      selected: currentSelect == key, //here and above show how you can change color of selected fragment item
      title: Text(text, style: TextStyle(color: _getColor())),
      onTap: () => _fragNav.putPosit(key: newKey),
    )
    
### Change Fragment
To change fragment you can call in `FragNavigate` methods:

    putPosit<K>(key, force => default false, closeDrawer => default true, K? params => Params to pass for fragmentBuilder); //put new fragment in stack
    putAndReplace<K>(key, force => default false, closeDrawer => default true, K? params => Params to pass for fragmentBuilder); //put and discart atual fragment in stack
    putAndClean<K>(key, force => default false, closeDrawer => default true, K? params => Params to pass for fragmentBuilder); //put and clean stack
    jumpBack(); //back to last in stack, it is called automatically if you click in back buttom
    jumpBackToFirst(); //back to first in stack and clean it
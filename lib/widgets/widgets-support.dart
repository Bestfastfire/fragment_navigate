import 'package:fragment_navigate/navigate-bloc.dart';
import 'package:flutter/material.dart';

class ScreenNavigate extends StatelessWidget {
  final Function onBack;
  final FragNavigate bloc;
  final Widget child;

  const ScreenNavigate(
      {@required this.child, @required this.bloc, this.onBack});

  @override
  Widget build(BuildContext context) {
    if (child is ActionInterface) {
      bloc.setInterface = child;
    } else {
      bloc.setInterface = null;
    }

    return FadeWidget(
        child: WillPopScope(
      onWillPop: bloc.jumpBack,
      child: child,
    ));
  }
}

class FadeWidget extends StatefulWidget {
  final Widget child;

  FadeWidget({@required this.child});

  @override
  _FadeWidgetState createState() => _FadeWidgetState();
}

class _FadeWidgetState extends State<FadeWidget> {
  bool isBuildingFade = false;
  bool state = false;

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(milliseconds: 50)).then((_) {
      if (!isBuildingFade) {
        setState(() {
          isBuildingFade = true;
          state = true;
        });
      } else {
        isBuildingFade = false;
        state = false;
      }
    });

    return AnimatedOpacity(
      opacity: state ? 1.0 : 0.0,
      duration: Duration(milliseconds: 200),
      child: widget.child,
    );
  }
}

import 'package:fragment_navigate/navigate-bloc.dart';
import 'package:flutter/material.dart';

class ScreenNavigate extends StatelessWidget {
  final FragNavigate bloc;
  final Function onBack;
  final Widget child;

  const ScreenNavigate(
      {@required this.child, @required this.bloc, this.onBack});

  @override
  Widget build(BuildContext context) {
    if (child is ActionInterface) {
      bloc.setInterface = child;
    } else {
      // ignore: invalid_use_of_protected_member
      if (child is StatefulWidget &&
          // ignore: invalid_use_of_protected_member
          (child as StatefulWidget).createState() is ActionInterface) {
        // ignore: invalid_use_of_protected_member
        bloc.setInterface = (child as StatefulWidget).createState();
      } else {
        bloc.setInterface = null;
      }
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
      child: widget.child);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase_example/share/app_constraints.dart';
import 'package:in_app_purchase_example/share/text_styles.dart';

class BaseButtonPage extends StatelessWidget {
  final String title;
  final Widget toPage;

  BaseButtonPage({Key? key, required this.title, required this.toPage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => toPage,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(10.0),
        width: double.infinity,
        // maxWidth: 300,
        constraints: AppConstraints.gestureConstraintsBaseButton3Line,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: Colors.blue,
        ),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyles.whiteTextStyle1,
          ),
        ),
      ),
    );
  }
}

class BaseButtonExit extends StatelessWidget {
  final String title;
  // final Function toPage;
  static Future<void> _popExit({bool? animated}) async {
    await SystemChannels.platform
        .invokeMethod<void>('SystemNavigator.pop', animated);
  }

  BaseButtonExit(
      {
      //Key key,
      required this.title}) //, this.toPage
      : super(
        //key: key
        );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
        _popExit();
      },
      child: Container(
        padding: const EdgeInsets.all(10.0),
        width: double.infinity,
        // maxWidth: 300,
        constraints: AppConstraints.gestureConstraintsBaseButton3Line,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: Colors.blue,
        ),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyles
                .whiteTextStyle1, // Theme.of(context).textTheme.bodyText1,
          ),
        ),
      ),
    );
  }
}

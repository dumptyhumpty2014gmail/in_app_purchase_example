import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:in_app_purchase_example/pages/in_app_payment/inapppurchas.dart';
import 'package:in_app_purchase_example/pages/my_home/home_button.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<void> initHive() async {
    await Hive.openBox('in_apppurhase');
  }

  Future<void> closeHive() async {
    await Hive.box('in_apppurhase').close();
  }

  @override
  void initState() {
    super.initState();
    initHive();
  }

  @override
  void dispose() {
    closeHive();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            BaseButtonPage(
              title: 'Покупки',
              toPage: InAppPurchasesPage(),
            ),
            BaseButtonExit(title: 'Выход'),
          ],
        ),
      ),
    );
  }
}

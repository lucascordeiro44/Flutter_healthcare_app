import 'package:flutter/material.dart';
import 'package:flutter_dandelin/utils/nav.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _settingModalBottomSheet(context);
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}

void _settingModalBottomSheet(context) {
  showModalBottomSheet(
    backgroundColor: Colors.transparent,
    context: context,
    isScrollControlled: true,
    builder: (BuildContext bc) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Container(
            margin: EdgeInsets.only(top: 80),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        pop();
                      },
                    ),
                  ],
                ),
                Text("digite o celular"),
                Expanded(child: TextField()),
                FlatButton(
                  onPressed: () {},
                  child: Text("confirmar"),
                )
              ],
            ),
          ),
        ),
      );
    },
  );
}

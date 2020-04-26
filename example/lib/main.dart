import 'package:flutter/material.dart';
import 'package:monalisa_client/monalisa_client.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData( primarySwatch: Colors.blue,),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final MonalisaClient monalisa_client = MonalisaClient();
  int _counter = 0;
  Map _data; //ignore: unused_field

  @override
  void initState() {
    super.initState();
    monalisa_client.read_local_config()
        .then((data) => monalisa_client.ensure_user_token())
        .then((data) => _loadProfileFrom(data))
        .catchError((SocketException) => _setStateNoInternet());
  }

  void _loadProfileFrom(data) {
    setState(() { _data = data; });
  }

  void _setStateNoInternet() {
    setState(() { });
  }

  void _incrementCounter() {
    setState(() { _counter++; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( title: Text(widget.title),),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text( 'You have pushed the button this many times:',),
            Text( '$_counter', style: Theme.of(context).textTheme.display1,),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter, tooltip: 'Increment', child: Icon(Icons.add),
      ),
    );
  }
}

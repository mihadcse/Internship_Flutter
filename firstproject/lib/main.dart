import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int? _counter;

  void _incrementCounter() {
    setState(() {

      if (_counter == null) {
        _counter = 1;
      } else {
        _counter = _counter! + 1;
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    _counter = 4;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MyHomePage oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: Center(

        child: SingleChildScrollView(
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.asset('assets/images/iut.jpeg', width: 35, height: 60, fit: BoxFit.cover),
              ),
              Row(
                spacing: 43,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Flexible(child: const Text('Islamic University of Technology', style: TextStyle(color: Colors.green, fontSize: 18), textAlign: TextAlign.center,)),
                ],
              ),
              // const Text('Student ID Card', style: TextStyle(color: Colors.green, fontSize: 15), textAlign: TextAlign.center,),
              // ClipRRect(child: Image.asset('assets/images/mihad.jpg', width:65, height: 100, fit: BoxFit.cover)),
              // const Text('Syed Huzzatullah Mihad', style: TextStyle(color: Colors.green, fontSize: 15, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
              // const Text('ID - 210041218', style: TextStyle(color: Colors.black, fontSize: 15, backgroundColor: Color.fromARGB(255, 158, 193, 209), fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
              // const Text('Program - B.Sc. in CSE', style: TextStyle(color: Colors.green, fontSize: 15), textAlign: TextAlign.center,),
              // const Text('Department - CSE', style: TextStyle(color: Colors.green, fontSize: 15), textAlign: TextAlign.center,),
              // const Text('Bangladesh', style: TextStyle(color: Colors.green, fontSize: 15), textAlign: TextAlign.center,),
              Text('Count- ${_counter ?? 0}', style: TextStyle(color: const Color.fromARGB(255, 38, 123, 214), fontSize: 25), textAlign: TextAlign.center,),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

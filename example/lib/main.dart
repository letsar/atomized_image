import 'package:atomized_image/atomized_image.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Atomized Image demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<String> _images = [
    '947228834121658368/z3AHPKHY_400x400.jpg',
    '1322300827726356480/QUIpVQ_M_400x400.jpg',
  ];
  int _index = 0;

  void _nextImage() {
    _index = (_index + 1) % _images.length;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atomized Image'),
      ),
      body: AtomizedImage(
        image: NetworkImage(
          'https://pbs.twimg.com/profile_images/${_images[_index]}',
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _nextImage,
        tooltip: 'Next',
        child: const Icon(Icons.navigate_next),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    fetchData(); // 서버로부터 데이터를 불러옵니다.
  }

  void fetchData() async {
    var url = Uri.parse('http://172.10.7.14:3000/');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      print("Data from server: ${response.body}");
    } else {
      print("Failed to fetch data");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Home Page'),
      ),
      body: Center(
        child: Text('Check your console for data.'),
      ),
    );
  }
}

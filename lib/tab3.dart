import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Tab3 extends StatefulWidget {
  const Tab3({super.key});

  @override
  _Tab3State createState() => _Tab3State();
}

class _Tab3State extends State<Tab3> {
  List<String> fileNames = [];
  bool isLoading = true;

  // 서버에서 파일 이름 가져오기
  Future<void> _fetchAndSetFileNames() async {
    try {
      const int userId = 1; // 예제에서는 userId = 1 사용
      final url = Uri.parse('http://<your-server-address>:3000/voices/files/$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<String> fetchedFileNames = List<String>.from(data['fileNames']);

        setState(() {
          fileNames = fetchedFileNames;
          isLoading = false;
        });
      } else {
        print('Failed to fetch files. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching files: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchAndSetFileNames(); // 서버에서 파일 이름 가져오기
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator() // 로딩 상태 표시
            : fileNames.isEmpty
            ? const Text('No files found.')
            : ListView.builder(
          itemCount: fileNames.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(fileNames[index]),
            );
          },
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'services/api_service.dart';

class ApiTest extends StatefulWidget {
  const ApiTest({super.key});

  @override
  State<ApiTest> createState() => _ApiTestState();
}

class _ApiTestState extends State<ApiTest> {
  List<dynamic> users = [];
  String message = 'Press the button to test API';
  bool isLoading = false;

  Future<void> fetchUsers() async {
    setState(() {
      isLoading = true;
      message = '';
    });

    try {
      final result = await ApiService.getUsers();

      setState(() {
        users = result;
        message = 'API connected successfully!';
      });
    } catch (e) {
      setState(() {
        message = 'Error: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('API Connection Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message),
            const SizedBox(height: 20),
            if (isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: fetchUsers,
                child: const Text('Fetch Users'),
              ),
            const SizedBox(height: 20),
            Text('Total Users: ${users.length}'),
          ],
        ),
      ),
    );
  }
}

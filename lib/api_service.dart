import 'dart:convert';
import 'package:http/http.dart' as http;
import 'history.dart'; // Import your History model

class ApiService {
  final String baseUrl = 'http://10.0.2.2:8000/api/'; // Base URL for your API

  Future<List<History>> fetchHistory() async {
    final response = await http.get(Uri.parse('${baseUrl}users/history/'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => History.fromMap(item)).toList();
    } else {
      throw Exception('Failed to load history: ${response.reasonPhrase}');
    }
  }

  Future<http.Response> apiCalculate(String expression) async {
    // Implement your calculation API call here
    // Example:
    final response = await http.post(
      Uri.parse('${baseUrl}calculate/'), // Adjust endpoint as necessary
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'expression': expression}),
    );
    return response;
  }

  Future<void> saveHistory(String expression, String result,int userId) async {
    final response = await http.post(
      Uri.parse('${baseUrl}users/history/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token YOUR_API_TOKEN', // Adjust this based on your auth method
      },
      body: json.encode({
        'expression': expression,
        'result': result,
        'user': userId,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to save history: ${response.reasonPhrase}');
    }
  }

}

import 'package:flutter/material.dart';
import 'api_service.dart'; // Import your API service
import 'history.dart'; // Import your History model
import 'dart:convert'; // Add this import for JSON handling

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Calculator'), // Main screen title
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ApiService apiService = ApiService();
  List<History> historyList = [];
  String _expression = '';
  String _result = '';
  late int userId;

  void setUserId(int id) {
    setState(() {
      userId = id; // Set userId when you have it
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    try {
      List<History> fetchedHistory = await apiService.fetchHistory();
      setState(() {
        historyList = fetchedHistory;
      });
    } catch (e) {
      print('Error fetching history: $e');
    }
  }

  void _onButtonPressed(String value) {
    setState(() {
      if (value == '=') {
        _calculateResult();
      } else if (value == 'C') {
        _expression = '';
        _result = '';
      } else {
        _expression += value;
      }
    });
  }

  Future<void> _calculateResult() async {
    String expression = _expression.replaceAll('^', '**');
    try {
      final response = await apiService.apiCalculate(expression); // Call the API
      if (response.statusCode == 200) {
        var resultData = json.decode(response.body); // Decode the JSON response
        setState(() {
          _result = (resultData['result'] as num).toString(); // Ensure this is a number
          _saveHistory(expression, _result); // Save to history
        });
      } else {
        setState(() {
          _result = 'Error';
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Error';
      });
    }
  }

  Future<void> _saveHistory(String expression, String result) async {
    // Implement saving history logic here if needed
    // You can send a POST request to your API to save the history
    try {
      await apiService.saveHistory(expression, result,userId ?? 0); // Assuming you implement this in ApiService
      _fetchHistory(); // Refresh the history list
    } catch (e) {
      print('Error saving history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _expression,
              style: TextStyle(fontSize: 24),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _result,
              style: TextStyle(fontSize: 24),
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 4,
              children: [
                for (var button in [
                  '7', '8', '9', '/',
                  '4', '5', '6', '*',
                  '1', '2', '3', '-',
                  'C', '0', '=', '+',
                ])
                  ElevatedButton(
                    onPressed: () => _onButtonPressed(button),
                    child: Text(button, style: TextStyle(fontSize: 24)),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: historyList.length,
              itemBuilder: (context, index) {
                History history = historyList[index];
                return ListTile(
                  title: Text(history.expression),
                  subtitle: Text('Result: ${history.result}'),
                  trailing: Text(history.createdAt.toLocal().toString()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

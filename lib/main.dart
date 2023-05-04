import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Random Number Generator',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(),
        fontFamily: 'SyongSyong',
      ),
      home: RandomNumberGenerator(),
    );
  }
}

class RandomNumberGenerator extends StatefulWidget {
  const RandomNumberGenerator({Key? key}) : super(key: key);

  @override
  RandomNumberGeneratorState createState() => RandomNumberGeneratorState();
}

class RandomNumberGeneratorState extends State<RandomNumberGenerator> {
  final _formKey = GlobalKey<FormState>();
  final _minController = TextEditingController(text: "0");
  final _maxController = TextEditingController(text: "100");
  final _numController = TextEditingController(text: "3");
  bool _allowDuplicate = true;
  bool _sortAscending = false;
  List<int> _results = [];
  final List<List<int>> _history = [];

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    _numController.dispose();
    super.dispose();
  }

  String? _validateNumber(String? value,
      {required String fieldName, int? maxValue, int? minValue}) {
    if (value?.isEmpty == true) {
      return 'Please enter a $fieldName';
    }
    final number = int.tryParse(value!);
    if (number == null) {
      return 'Please enter a valid integer for $fieldName';
    }
    if (maxValue != null && number > maxValue) {
      return 'The $fieldName must be less than or equal to $maxValue';
    }
    if (minValue != null && number < minValue) {
      return 'The $fieldName must be grater than or equal to $minValue';
    }
    return null;
  }

  void _generateRandomNumber() {
    if (_formKey.currentState?.validate() == true) {
      final int min = int.parse(_minController.text);
      final int max = int.parse(_maxController.text);
      final int num = int.parse(_numController.text);

      if (min > max) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'The minimum number must be less than or equal to the maximum number')),
        );
        return;
      }

      if (!_allowDuplicate && num > max - min + 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Not enough unique numbers in the given range to generate')),
        );
        return;
      }

      final set = <int>{};
      _results = [];

      while (_results.length < num) {
        final int randomNumber = Random().nextInt(max - min + 1) + min;
        if (_allowDuplicate || set.add(randomNumber)) {
          _results.add(randomNumber);
        }
      }

      if (_sortAscending) {
        _results.sort();
      }

      if (_history.length == 10) {
        _history.removeAt(0);
      }
      _history.add(List.from(_results));

      setState(() {});
    }
  }

  void _clearHistory() {
    setState(() {
      _history.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Random Number Generator'),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: _history.length,
                  itemBuilder: (BuildContext context, int index) {
                    final numbers =
                        _history[_history.length - index - 1]; // 이 부분이 수정되었습니다.
                    return ListTile(
                      title: Text('Numbers ${numbers.join(", ")} generated'),
                    );
                  },
                ),
              ),
              TextButton(
                onPressed: _clearHistory,
                child: const Text('Clear History'),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _minController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: false),
                decoration: InputDecoration(
                  labelText: 'Minimum Number',
                  labelStyle: TextStyle(fontSize: 22.0), // 크기를 조정하세요
                ),
                validator: (value) => _validateNumber(value,
                    fieldName: 'minimum number',
                    maxValue: 2147483645,
                    minValue: -2147483646),
              ),
              TextFormField(
                controller: _maxController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: false),
                decoration: InputDecoration(
                  labelText: 'Maximum Number',
                  labelStyle: TextStyle(fontSize: 22.0), // 크기를 조정하세요
                ),
                validator: (value) => _validateNumber(value,
                    fieldName: 'maximum number',
                    maxValue: 2147483646,
                    minValue: -2147483645),
              ),
              TextFormField(
                controller: _numController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: false),
                decoration: InputDecoration(
                  labelText: 'Number of random numbers',
                  labelStyle: TextStyle(fontSize: 22.0), // 크기를 조정하세요
                ),
                validator: (value) => _validateNumber(value,
                    fieldName: 'number of random numbers',
                    maxValue: 2147483646),
              ),
              CheckboxListTile(
                title: const Text('Allow Duplicates'),
                value: _allowDuplicate,
                onChanged: (bool? value) {
                  setState(() {
                    _allowDuplicate = value ?? true;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Sort Ascending'),
                value: _sortAscending,
                onChanged: (bool? value) {
                  setState(() {
                    _sortAscending = value ?? false;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              Center(
                  child: ElevatedButton(
                      onPressed: _generateRandomNumber,
                      child: const Text('Generate Random Number'),
                      style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ))))),
              const SizedBox(height: 16.0),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _results.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildNumberTile(
                      _results[index],
                      int.parse(_minController.text),
                      int.parse(_maxController.text),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildNumberTile(int number, int min, int max) {
  final double fraction = (number - min) / (max - min);

  Color color;
  if (fraction < 0.33) {
    color = Color.lerp(Colors.blue, Colors.green, fraction * 3)!;
  } else if (fraction < 0.66) {
    color = Color.lerp(Colors.green, Colors.orange, (fraction - 0.33) * 3)!;
  } else {
    color = Color.lerp(Colors.orange, Colors.red, (fraction - 0.66) * 3)!;
  }

  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color,
    ),
    child: Center(
      child: Text(
        '$number',
        style: const TextStyle(fontSize: 28.0, color: Colors.white),
      ),
    ),
  );
}

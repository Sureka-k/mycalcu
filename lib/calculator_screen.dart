import 'package:flutter/material.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({Key? key}) : super(key: key);

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _displayText = '0';
  String _input = '';

  void _onButtonPressed(String buttonText) {
    setState(() {
      if (buttonText == 'C') {
        _displayText = '0';
        _input = '';
      } else if (buttonText == '=') {
        // Perform calculation
        try {
          final result = _calculate(_input);
          _displayText = result.toString();
          _input = result.toString();
        } catch (e) {
          _displayText = 'Error';
        }
      } else if (buttonText == '%' || buttonText == '(' || buttonText == ')') {
        // Append the bracket or percentage sign directly to the input string
        _input += buttonText;
        _displayText = _input;
      } else {
        // Append the pressed button value to the input string
        _input += buttonText;
        _displayText = _input;
      }
    });
  }

  dynamic _calculate(String input) {
    // Remove all whitespaces from the input
    input = input.replaceAll(' ', '');

    // Handle percentage operation
    if (input.contains('%')) {
      final parts = input.split('%');
      if (parts.length != 2) {
        throw const FormatException('Invalid input');
      }
      final value = double.parse(parts[0]);
      final percentage = value / 100;
      return percentage;
    }

    // If the input doesn't contain '%', continue with regular calculation
    if (input.startsWith('-')) {
      input = '0$input'; // Add a leading zero to make it a valid expression
    }

    // Regular expression pattern to match numbers and operators
    final pattern = RegExp(r'(\d+(\.\d+)?)|([-+*/()])');
    final matches = pattern.allMatches(input);

    List<String> tokens = [];
    for (final match in matches) {
      tokens.add(match.group(0)!);
    }

    // Evaluate the expression using a stack-based algorithm
    List<dynamic> values = [];
    List<String> operators = [];

    for (String token in tokens) {
      if (token == '(') {
        // Start of a new sub-expression
        operators.add(token);
      } else if (token == ')') {
        // End of a sub-expression, evaluate it
        while (operators.isNotEmpty && operators.last != '(') {
          _applyOperator(values, operators.removeLast());
        }
        operators.removeLast(); // Remove the '(' from the stack
      } else if (_isNumber(token)) {
        // Token is a number, push it to the values stack
        values.add(double.parse(token));
      } else {
        // Token is an operator
        while (operators.isNotEmpty && _precedence(operators.last) >= _precedence(token)) {
          _applyOperator(values, operators.removeLast());
        }
        operators.add(token);
      }
    }

    // Evaluate the remaining operators
    while (operators.isNotEmpty) {
      _applyOperator(values, operators.removeLast());
    }

    // The final result is the only value left in the values stack
    return values.first;
  }

  void _applyOperator(List<dynamic> values, String operator) {
    dynamic right = values.removeLast();
    dynamic left = values.removeLast();
    switch (operator) {
      case '+':
        values.add(left + right);
        break;
      case '-':
        values.add(left - right);
        break;
      case '*':
        values.add(left * right);
        break;
      case '/':
        values.add(left / right);
        break;
    }
  }

  bool _isNumber(String value) {
    return double.tryParse(value) != null;
  }

  int _precedence(String operator) {
    switch (operator) {
      case '+':
      case '-':
        return 1;
      case '*':
      case '/':
        return 2;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.all(16),
                child: Text(
                  _displayText,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
              Wrap(
                children: [
                  ..._buildButtonRows([
                    '7', '8', '9', '/',
                  ]),
                  ..._buildButtonRows([
                    '4', '5', '6', '*',
                  ]),
                  ..._buildButtonRows([
                    '1', '2', '3', '-',
                  ]),
                  ..._buildButtonRows([
                    '0', '.', 'C', '+',
                  ]),
                  ..._buildButtonRows([
                    '=', '%', '(', ')',
                  ]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildButtonRows(List<String> rowValues) {
    return rowValues
        .map(
          (value) => SizedBox(
            width: MediaQuery.of(context).size.width / 4,
            height: MediaQuery.of(context).size.width / 5,
            child: TextButton(
              onPressed: () => _onButtonPressed(value),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  value == '+' || value == '-' || value == '*' || value == '/' || value == '=' || value == '%' || value == '(' || value == ')'
                      ? Colors.orange // Change color for specified buttons
                      : value == 'C'
                          ? Colors.green // Change color for "C" button
                          : Colors.grey[300]!,
                ),
                side: MaterialStateProperty.all<BorderSide>(
                  const BorderSide(
                    color: Colors.black, // Set border color to black for all buttons
                  ),
                ),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 30,
                  color: value == 'C' ? Colors.white : null, // Change text color for "C" button
                ),
              ),
            ),
          ),
        )
        .toList();
  }
}
import 'package:flutter/material.dart';
import 'dart:math' as math;

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _display = '0';
  String _operation = '';
  double _firstOperand = 0;
  bool _shouldResetDisplay = false;
  final List<String> _history = [];

  void _onNumberPressed(String number) {
    setState(() {
      if (_shouldResetDisplay) {
        _display = number;
        _shouldResetDisplay = false;
      } else {
        _display = _display == '0' ? number : _display + number;
      }
    });
  }

  void _onOperationPressed(String operation) {
    setState(() {
      _firstOperand = double.parse(_display);
      _operation = operation;
      _shouldResetDisplay = true;
    });
  }

  void _onEqualsPressed() {
    if (_operation.isEmpty) return;

    setState(() {
      double secondOperand = double.parse(_display);
      double result = 0;

      switch (_operation) {
        case '+':
          result = _firstOperand + secondOperand;
          break;
        case '-':
          result = _firstOperand - secondOperand;
          break;
        case '×':
          result = _firstOperand * secondOperand;
          break;
        case '÷':
          result = secondOperand != 0 ? _firstOperand / secondOperand : 0;
          break;
        case '%':
          result = _firstOperand % secondOperand;
          break;
      }

      String calculation =
          '$_firstOperand $_operation $secondOperand = ${result.toStringAsFixed(result.truncateToDouble() == result ? 0 : 2)}';

      _history.insert(0, calculation);
      if (_history.length > 10) _history.removeLast();

      _display = result.toStringAsFixed(result.truncateToDouble() == result ? 0 : 2);
      _operation = '';
      _shouldResetDisplay = true;
    });
  }

  void _onClear() {
    setState(() {
      _display = '0';
      _operation = '';
      _firstOperand = 0;
      _shouldResetDisplay = false;
    });
  }

  void _onBackspace() {
    setState(() {
      if (_display.length > 1) {
        _display = _display.substring(0, _display.length - 1);
      } else {
        _display = '0';
      }
    });
  }

  void _onDecimalPressed() {
    if (!_display.contains('.')) {
      setState(() {
        _display += '.';
      });
    }
  }

  void _onPercentPressed() {
    setState(() {
      double value = double.parse(_display);
      _display = (value / 100).toString();
    });
  }

  void _onSquareRoot() {
    setState(() {
      double value = double.parse(_display);
      if (value >= 0) {
        _display = math.sqrt(value).toStringAsFixed(2);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showHistory(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Display Area - Flexible untuk menyesuaikan ukuran
          Flexible(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.bottomRight,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (_operation.isNotEmpty)
                      Text(
                        '$_firstOperand $_operation',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _display,
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          
          // Buttons Area - Flexible dengan padding yang lebih kecil
          Flexible(
            flex: 5,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Hitung padding berdasarkan available space
                final buttonPadding = constraints.maxHeight > 400 ? 8.0 : 4.0;
                final buttonVerticalPadding = constraints.maxHeight > 400 ? 20.0 : 16.0;
                
                return Container(
                  padding: EdgeInsets.all(buttonPadding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            _buildButton('C', Colors.red, _onClear, buttonVerticalPadding),
                            _buildButton('⌫', Colors.orange, _onBackspace, buttonVerticalPadding),
                            _buildButton('%', Colors.blue, _onPercentPressed, buttonVerticalPadding),
                            _buildButton('÷', Colors.blue, () => _onOperationPressed('÷'), buttonVerticalPadding),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            _buildButton('7', Colors.grey[800]!, () => _onNumberPressed('7'), buttonVerticalPadding),
                            _buildButton('8', Colors.grey[800]!, () => _onNumberPressed('8'), buttonVerticalPadding),
                            _buildButton('9', Colors.grey[800]!, () => _onNumberPressed('9'), buttonVerticalPadding),
                            _buildButton('×', Colors.blue, () => _onOperationPressed('×'), buttonVerticalPadding),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            _buildButton('4', Colors.grey[800]!, () => _onNumberPressed('4'), buttonVerticalPadding),
                            _buildButton('5', Colors.grey[800]!, () => _onNumberPressed('5'), buttonVerticalPadding),
                            _buildButton('6', Colors.grey[800]!, () => _onNumberPressed('6'), buttonVerticalPadding),
                            _buildButton('-', Colors.blue, () => _onOperationPressed('-'), buttonVerticalPadding),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            _buildButton('1', Colors.grey[800]!, () => _onNumberPressed('1'), buttonVerticalPadding),
                            _buildButton('2', Colors.grey[800]!, () => _onNumberPressed('2'), buttonVerticalPadding),
                            _buildButton('3', Colors.grey[800]!, () => _onNumberPressed('3'), buttonVerticalPadding),
                            _buildButton('+', Colors.blue, () => _onOperationPressed('+'), buttonVerticalPadding),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            _buildButton('√', Colors.green, _onSquareRoot, buttonVerticalPadding),
                            _buildButton('0', Colors.grey[800]!, () => _onNumberPressed('0'), buttonVerticalPadding),
                            _buildButton('.', Colors.grey[800]!, _onDecimalPressed, buttonVerticalPadding),
                            _buildButton('=', Colors.green, _onEqualsPressed, buttonVerticalPadding),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build button dengan responsive padding
  Widget _buildButton(String text, Color color, VoidCallback onPressed, double verticalPadding) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(3),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(vertical: verticalPadding),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'History',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_history.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _history.clear();
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Clear'),
                    ),
                ],
              ),
              const Divider(),
              Expanded(
                child: _history.isEmpty
                    ? const Center(
                        child: Text(
                          'No calculations yet',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: _history.length,
                        itemBuilder: (context, index) {
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text('${index + 1}'),
                              ),
                              title: Text(
                                _history[index],
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                ),
                              ),
                              onTap: () {
                                final result = _history[index].split('= ')[1];
                                setState(() {
                                  _display = result;
                                });
                                Navigator.pop(context);
                              },
                            ),
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
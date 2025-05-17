import 'package:flutter/material.dart';

void main() => runApp(const CalculatorApp());

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator & Converter',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Calculator & Converter'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Calc'), Tab(text: 'Conv')],
          ),
        ),
        body: const TabBarView(
          children: [CalculatorPage(), ConverterPage()],
        ),
      ),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({Key? key}) : super(key: key);

  @override
  _CalculatorPageState createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _display = '0';
  String? _first;
  String? _op;
  bool _reset = false;
  bool _insertLeftParen = true;
  final List<String> _history = [];

  void _input(String v) {
    setState(() {
      if (_reset || _display == '0') _display = v;
      else _display += v;
      _reset = false;
    });
  }

  void _erase() => setState(() {
        _display = _display.length > 1
            ? _display.substring(0, _display.length - 1)
            : '0';
      });

  void _clear() => setState(() {
        _display = '0';
        _first = null;
        _op = null;
        _reset = false;
      });

  void _setOp(String o) {
    _first = _display;
    _op = o;
    _reset = true;
  }

  void _calc() {
    if (_first == null || _op == null) return;
    final a = double.tryParse(_first!) ?? 0;
    final b = double.tryParse(_display) ?? 0;
    double r;
    switch (_op) {
      case '+':
        r = a + b;
        break;
      case '-':
        r = a - b;
        break;
      case '×':
        r = a * b;
        break;
      case '÷':
        r = b != 0 ? a / b : double.nan;
        break;
      case '%':
        r = a % b;
        break;
      default:
        return;
    }
    final resultText = (r % 1 == 0)
        ? r.toInt().toString()
        : r
            .toStringAsFixed(6)
            .replaceAll(RegExp(r"0+$"), '')
            .replaceAll(RegExp(r"\.$"), '');
    setState(() {
      _history.add("$_first $_op $_display = $resultText");
      _display = resultText;
      _reset = true;
    });
  }

  void _toggleParen() {
    _input(_insertLeftParen ? '(' : ')');
    _insertLeftParen = !_insertLeftParen;
  }

  void _showHistory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      builder: (_) => ListView(
        padding: const EdgeInsets.all(16),
        children: _history
            .map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(e, style: const TextStyle(fontSize: 18)),
                ))
            .toList(),
      ),
    );
  }

  Widget buildButton(String label,
      {Color? fg, Color? bg, VoidCallback? onTap}) {
    return AspectRatio(
      aspectRatio: 1,
      child: Material(
        color: bg ?? const Color(0xFF333333),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(100),
          child: Center(
            child: Text(label,
                style: TextStyle(color: fg ?? Colors.white, fontSize: 24)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final opColor = Colors.deepPurpleAccent;
    final btns = [
      'C',
      '()',
      '%',
      '÷',
      '7',
      '8',
      '9',
      '×',
      '4',
      '5',
      '6',
      '-',
      '1',
      '2',
      '3',
      '+',
      '+/-',
      '0',
      '.',
      '=',
    ];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.history, color: Colors.orange),
                onPressed: _showHistory,
              ),
              Expanded(
                child: Text(_display,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        fontSize: 48, fontWeight: FontWeight.bold)),
              ),
              IconButton(icon: const Icon(Icons.backspace), onPressed: _erase),
            ],
          ),
        ),
        const Divider(
          color: Colors.grey,
          thickness: 1, // Line thickness
          height: 40, // Space above and below the line
          indent: 8, // Left padding
          endIndent: 8, // Right padding
        ),
        // Reduced spacing below divider
        const SizedBox(height: 40),
        // Use Flexible so grid shrinks to content
        Flexible(
          fit: FlexFit.loose,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isPortrait ? 4 : 6,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              children: btns.map((t) {
                Color? fg;
                Color? bg;
                VoidCallback? cb;
                switch (t) {
                  case 'C':
                    fg = Colors.red;
                    cb = _clear;
                    break;
                  case '=':
                    fg = Colors.white;
                    bg = Colors.green;
                    cb = _calc;
                    break;
                  case '+':
                  case '-':
                  case '×':
                  case '÷':
                  case '%':
                    fg = opColor;
                    cb = () => _setOp(t);
                    break;
                  case '+/-':
                    cb = () => _input(_display.startsWith('-')
                        ? _display.substring(1)
                        : '-$_display');
                    break;
                  case '()':
                    fg = Colors.orange;
                    cb = _toggleParen;
                    break;
                  default:
                    cb = () => _input(t);
                }
                return buildButton(t, fg: fg, bg: bg, onTap: cb);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
class ConverterPage extends StatefulWidget {
  const ConverterPage({Key? key}) : super(key: key);
  @override
  _ConverterPageState createState() => _ConverterPageState();
}

class _ConverterPageState extends State<ConverterPage> {
  final Map<String, List<String>> types = {
    'Length': ['m', 'km', 'cm', 'mm'],
    'Area': ['m²', 'km²', 'cm²'],
    'Temp': ['°C', '°F', 'K'],
    'Volume': ['L', 'mL', 'm³'],
    'Mass': ['kg', 'g', 'lb'],
    'Data': ['B', 'KB', 'MB', 'GB'],
    'Speed': ['m/s', 'km/h', 'mph'],
    'Time': ['s', 'min', 'h'],
  };
  String type = 'Length';
  String from = 'm';
  String to = 'km';
  String input = '';
  String output = '';

  void convert() {
    final v = double.tryParse(input) ?? 0;
    double b = toBase(v, type, from);
    double r = fromBase(b, type, to);
    if (r % 1 == 0) {
      output = r.toInt().toString();
    } else {
      output = r
          .toStringAsFixed(6)
          .replaceAll(RegExp(r"0+$"), '')
          .replaceAll(RegExp(r"\.$"), '');
    }
    setState(() {});
  }

  double toBase(double v, String t, String u) {
    switch (t) {
      case 'Length':
        switch (u) {
          case 'm':
            return v;
          case 'km':
            return v * 1000;
          case 'cm':
            return v * 0.01;
          case 'mm':
            return v * 0.001;
        }
        break;
      case 'Area':
        switch (u) {
          case 'm²':
            return v;
          case 'km²':
            return v * 1e6;
          case 'cm²':
            return v * 0.0001;
        }
        break;
      case 'Temp':
        switch (u) {
          case '°C':
            return v;
          case '°F':
            return (v - 32) * 5 / 9;
          case 'K':
            return v - 273.15;
        }
        break;
      case 'Volume':
        switch (u) {
          case 'L':
            return v;
          case 'mL':
            return v * 0.001;
          case 'm³':
            return v * 1000;
        }
        break;
      case 'Mass':
        switch (u) {
          case 'kg':
            return v;
          case 'g':
            return v * 0.001;
          case 'lb':
            return v * 0.45359237;
        }
        break;
      case 'Data':
        switch (u) {
          case 'B':
            return v;
          case 'KB':
            return v * 1024;
          case 'MB':
            return v * 1024 * 1024;
          case 'GB':
            return v * 1024 * 1024 * 1024;
        }
        break;
      case 'Speed':
        switch (u) {
          case 'm/s':
            return v;
          case 'km/h':
            return v / 3.6;
          case 'mph':
            return v * 0.44704;
        }
        break;
      case 'Time':
        switch (u) {
          case 's':
            return v;
          case 'min':
            return v * 60;
          case 'h':
            return v * 3600;
        }
        break;
    }
    return v;
  }

  double fromBase(double v, String t, String u) {
    switch (t) {
      case 'Length':
        switch (u) {
          case 'm':
            return v;
          case 'km':
            return v / 1000;
          case 'cm':
            return v / 0.01;
          case 'mm':
            return v / 0.001;
        }
        break;
      case 'Area':
        switch (u) {
          case 'm²':
            return v;
          case 'km²':
            return v / 1e6;
          case 'cm²':
            return v / 0.0001;
        }
        break;
      case 'Temp':
        switch (u) {
          case '°C':
            return v;
          case '°F':
            return v * 9 / 5 + 32;
          case 'K':
            return v + 273.15;
        }
        break;
      case 'Volume':
        switch (u) {
          case 'L':
            return v;
          case 'mL':
            return v / 0.001;
          case 'm³':
            return v / 1000;
        }
        break;
      case 'Mass':
        switch (u) {
          case 'kg':
            return v;
          case 'g':
            return v / 0.001;
          case 'lb':
            return v / 0.45359237;
        }
        break;
      case 'Data':
        switch (u) {
          case 'B':
            return v;
          case 'KB':
            return v / 1024;
          case 'MB':
            return v / (1024 * 1024);
          case 'GB':
            return v / (1024 * 1024 * 1024);
        }
        break;
      case 'Speed':
        switch (u) {
          case 'm/s':
            return v;
          case 'km/h':
            return v * 3.6;
          case 'mph':
            return v / 0.44704;
        }
        break;
      case 'Time':
        switch (u) {
          case 's':
            return v;
          case 'min':
            return v / 60;
          case 'h':
            return v / 3600;
        }
        break;
    }
    return v;
  }

  @override
  Widget build(BuildContext c) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButton<String>(
            value: type,
            items: types.keys
                .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                .toList(),
            onChanged: (v) {
              setState(() {
                type = v!;
                from = types[type]!.first;
                to = types[type]!.last;
                output = '';
                input = '';
              });
            },
          ),
          Row(children: [
            Expanded(
              child: DropdownButton<String>(
                value: from,
                items: types[type]!
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: (v) => setState(() {
                  from = v!;
                  output = '';
                }),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButton<String>(
                value: to,
                items: types[type]!
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: (v) => setState(() {
                  to = v!;
                  output = '';
                }),
              ),
            ),
          ]),
          TextField(
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Value'),
            onChanged: (v) {
              input = v;
              output = '';
            },
          ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: convert, child: const Text('Convert')),
          const SizedBox(height: 12),
          Text('Result: $output', style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}

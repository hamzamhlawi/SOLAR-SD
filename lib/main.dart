import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const SudansoApp());

class SudansoApp extends StatelessWidget {
  const SudansoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SUDANSO',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1B8A4A)),
        scaffoldBackgroundColor: const Color(0xFFF6F9F7),
        appBarTheme: const AppBarTheme(
            centerTitle: true,
            backgroundColor: Color(0xFF1B8A4A),
            foregroundColor: Colors.white),
      ),
      home: const HomePage(),
    );
  }
}

double pn(String s) => double.tryParse(s.replaceAll(',', '.')) ?? 0;
String fm(num v, [int d = 2]) =>
    (v.isNaN || v.isInfinite) ? '—' : v.toStringAsFixed(d);

class Item {
  String name;
  double w;
  int q;
  double h;
  bool motor;
  Item(this.name, this.w, this.q, this.h, this.motor);
  double get wh => w * q * h;
  double get cw => w * q;
  Map<String, dynamic> toJ() =>
      {'n': name, 'w': w, 'q': q, 'h': h, 'm': motor};
  factory Item.fromJ(Map<String, dynamic> j) => Item(
      j['n'] ?? 'جهاز',
      (j['w'] as num).toDouble(),
      (j['q'] as num).toInt(),
      (j['h'] as num).toDouble(),
      j['m'] ?? false);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Item> items = [];
  final _nameC = TextEditingController();
  final _wC = TextEditingController();
  final _qC = TextEditingController(text: '1');
  final _hC = TextEditingController(text: '4');
  bool _isMotor = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString('items');
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      setState(() {
        items.clear();
        items.addAll(
            list.map((e) => Item.fromJ(e as Map<String, dynamic>)));
      });
    }
  }

  Future<void> _save() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(
        'items', jsonEncode(items.map((e) => e.toJ()).toList()));
  }

  void _add() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('إضافة جهاز'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: _nameC,
                    decoration:
                        const InputDecoration(labelText: 'اسم الجهاز')),
                TextField(
                    controller: _wC,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'القدرة W')),
                TextField(
                    controller: _qC,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'العدد')),
                TextField(
                    controller: _hC,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'ساعات التشغيل')),
                CheckboxListTile(
                  value: _isMotor,
                  title: const Text('محرك/كمبروسر'),
                  onChanged: (v) =>
                      setS(() => _isMotor = v ?? false),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('إلغاء')),
            FilledButton(
              onPressed: () {
                if (pn(_wC.text) <= 0) return;
                setState(() => items.add(Item(
                    _nameC.text.isEmpty ? 'جهاز' : _nameC.text,
                    pn(_wC.text),
                    pn(_qC.text).round(),
                    pn(_hC.text),
                    _isMotor)));
                _save();
                Navigator.pop(ctx);
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dailyWh = items.fold<double>(0, (s, a) => s + a.wh);
    final peakW = items.fold<double>(0, (s, a) => s + a.cw);
    final motorW = items
        .where((a) => a.motor)
        .fold<double>(0, (s, a) => s + a.cw);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('SUDANSO')),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _add,
          icon: const Icon(Icons.add),
          label: const Text('جهاز'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(children: const [
                  Icon(Icons.wb_sunny,
                      size: 60, color: Colors.orange),
                  SizedBox(height: 8),
                  Text('SUDANSO',
                      style: TextStyle(
                          fontSize: 26, fontWeight: FontWeight.bold)),
                  Text('حلول الطاقة الشمسية'),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            ...items.asMap().entries.map((e) => Card(
                  child: ListTile(
                    title: Text(e.value.name +
                        (e.value.motor ? ' (محرك)' : '')),
                    subtitle: Text(
                        '${fm(e.value.w, 0)}W × ${e.value.q} × ${fm(e.value.h, 1)}h = ${fm(e.value.wh / 1000)} kWh'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() => items.removeAt(e.key));
                        _save();
                      },
                    ),
                  ),
                )),
            const Divider(),
            _res('الاستهلاك اليومي',
                '${fm(dailyWh / 1000)} kWh', Icons.bolt),
            _res('الاستهلاك الشهري',
                '${fm(dailyWh * 30 / 1000)} kWh', Icons.calendar_month),
            _res('الحمل المتزامن', '${fm(peakW)} W', Icons.speed),
            _res('أحمال المحركات', '${fm(motorW)} W', Icons.settings),
          ],
        ),
      ),
    );
  }

  Widget _res(String t, String v, IconData i) => Card(
        child: ListTile(
          leading: CircleAvatar(
              backgroundColor: Colors.green.shade50,
              child: Icon(i, color: Colors.green.shade700)),
          title: Text(t),
          trailing: Text(v,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      );
}
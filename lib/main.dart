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
          seedColor: const Color(0xFF1B8A4A),
          primary: const Color(0xFF1B8A4A),
          secondary: const Color(0xFFEF6C00),
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F9F7),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color(0xFF1B8A4A),
          foregroundColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

double parseNum(String text) {
  if (text.trim().isEmpty) return 0;
  return double.tryParse(text.replaceAll(',', '.').trim()) ?? 0;
}

String fmt(num value, [int digits = 2]) {
  if (value.isNaN || value.isInfinite) return '—';
  return value.toDouble().toStringAsFixed(digits);
}

class Appliance {
  String name;
  double watts;
  int quantity;
  double hours;
  bool isMotor;

  Appliance({
    required this.name,
    required this.watts,
    required this.quantity,
    required this.hours,
    this.isMotor = false,
  });

  double get dailyWh => watts * quantity * hours;
  double get continuousW => watts * quantity;

  Map<String, dynamic> toJson() => {
        'name': name,
        'watts': watts,
        'quantity': quantity,
        'hours': hours,
        'isMotor': isMotor,
      };

  factory Appliance.fromJson(Map<String, dynamic> j) => Appliance(
        name: j['name'] as String? ?? 'جهاز',
        watts: (j['watts'] as num?)?.toDouble() ?? 0,
        quantity: (j['quantity'] as num?)?.toInt() ?? 1,
        hours: (j['hours'] as num?)?.toDouble() ?? 0,
        isMotor: j['isMotor'] as bool? ?? false,
      );
}

class Project {
  String id;
  String name;
  String type;
  DateTime createdAt;
  DateTime updatedAt;
  List<Appliance> appliances;

  Project({
    required this.id,
    required this.name,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    required this.appliances,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'appliances': appliances.map((a) => a.toJson()).toList(),
      };

  factory Project.fromJson(Map<String, dynamic> j) => Project(
        id: j['id'] as String,
        name: j['name'] as String,
        type: j['type'] as String? ?? 'منزل',
        createdAt: DateTime.parse(j['createdAt'] as String),
        updatedAt: DateTime.parse(j['updatedAt'] as String),
        appliances: (j['appliances'] as List)
            .map((e) => Appliance.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class ProjectService {
  static const _key = 'sudanso_projects_v1';

  static Future<List<Project>> loadAll() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final List list = jsonDecode(raw) as List;
    return list
        .map((e) => Project.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> saveAll(List<Project> projects) async {
    final sp = await SharedPreferences.getInstance();
    final raw = jsonEncode(projects.map((p) => p.toJson()).toList());
    await sp.setString(_key, raw);
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const DashboardTab(),
      const FullSystemPage(),
      const ProjectsPage(),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: pages[_index],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'الرئيسية',
            ),
            NavigationDestination(
              icon: Icon(Icons.auto_graph_outlined),
              selectedIcon: Icon(Icons.auto_graph),
              label: 'التصميم',
            ),
            NavigationDestination(
              icon: Icon(Icons.folder_outlined),
              selectedIcon: Icon(Icons.folder),
              label: 'مشاريعي',
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_Dash>[
      _Dash('الحساب الكامل', 'تصميم نظام شمسي كامل',
          Icons.auto_graph, const FullSystemPage()),
      _Dash('الأجهزة والاستهلاك', 'احسب الاستهلاك اليومي',
          Icons.electrical_services, const AppliancesPage()),
      _Dash('حاسبة الألواح', 'عدد الألواح وMPPT',
          Icons.solar_power, const PanelsPage()),
      _Dash('حاسبة البطارية', 'Lithium / AGM / FLD',
          Icons.battery_charging_full, const BatteryPage()),
      _Dash('حاسبة الإنفرتر', 'الحمل المستمر وحمل الإقلاع',
          Icons.power, const InverterPage()),
      _Dash('عن التطبيق', 'معلومات وتواصل',
          Icons.info_outline, const AboutPage()),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('SUDANSO')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: const [
                  Icon(Icons.wb_sunny, size: 60, color: Colors.orange),
                  SizedBox(height: 8),
                  Text('SUDANSO',
                      style: TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold)),
                  Text('حلول الطاقة الشمسية',
                      style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...items.map((it) => Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.shade50,
                    child: Icon(it.icon, color: Colors.green.shade700),
                  ),
                  title: Text(it.title,
                      style:
                          const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(it.subtitle),
                  trailing:
                      const Icon(Icons.arrow_back_ios_new, size: 16),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => it.page),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class _Dash {
  final String title, subtitle;
  final IconData icon;
  final Widget page;
  _Dash(this.title, this.subtitle, this.icon, this.page);
}
class AppliancesPage extends StatefulWidget {
  const AppliancesPage({super.key});

  @override
  State<AppliancesPage> createState() => _AppliancesPageState();
}

class _AppliancesPageState extends State<AppliancesPage> {
  final List<Appliance> appliances = [];

  double get dailyWh => appliances.fold(0.0, (s, a) => s + a.dailyWh);
  double get peakW =>
      appliances.fold(0.0, (s, a) => s + a.continuousW);
  double get motorW => appliances
      .where((a) => a.isMotor)
      .fold(0.0, (s, a) => s + a.continuousW);

  void addAppliance() {
    final nameC = TextEditingController();
    final wattsC = TextEditingController();
    final qtyC = TextEditingController(text: '1');
    final hoursC = TextEditingController(text: '4');
    bool isMotor = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: const Text('إضافة جهاز'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameC,
                  decoration:
                      const InputDecoration(labelText: 'اسم الجهاز'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: wattsC,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'القدرة W'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: qtyC,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'العدد'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: hoursC,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'ساعات التشغيل يومياً'),
                ),
                CheckboxListTile(
                  value: isMotor,
                  title: const Text('جهاز بمحرك/كمبروسر'),
                  onChanged: (v) =>
                      setDialog(() => isMotor = v ?? false),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                final w = parseNum(wattsC.text);
                final q = parseNum(qtyC.text).round();
                final h = parseNum(hoursC.text);
                if (w <= 0 || q <= 0 || h <= 0) return;
                setState(() {
                  appliances.add(Appliance(
                    name: nameC.text.trim().isEmpty
                        ? 'جهاز'
                        : nameC.text.trim(),
                    watts: w,
                    quantity: q,
                    hours: h,
                    isMotor: isMotor,
                  ));
                });
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('الأجهزة والاستهلاك')),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: addAppliance,
          icon: const Icon(Icons.add),
          label: const Text('إضافة جهاز'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (appliances.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Text('لا توجد أجهزة. أضف الأجهزة.',
                      textAlign: TextAlign.center),
                ),
              ),
            ...appliances.asMap().entries.map((e) {
              final i = e.key;
              final a = e.value;
              return Card(
                child: ListTile(
                  title:
                      Text(a.name + (a.isMotor ? ' (محرك)' : '')),
                  subtitle: Text(
                      '${fmt(a.watts, 0)}W × ${a.quantity} × ${fmt(a.hours, 1)}h = ${fmt(a.dailyWh / 1000)} kWh/day'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () =>
                        setState(() => appliances.removeAt(i)),
                  ),
                ),
              );
            }),
            const SizedBox(height: 10),
            _result('الاستهلاك اليومي', '${fmt(dailyWh / 1000)} kWh',
                Icons.bolt),
            _result('الاستهلاك الشهري',
                '${fmt(dailyWh * 30 / 1000)} kWh',
                Icons.calendar_month),
            _result('الحمل المتزامن', '${fmt(peakW)} W', Icons.speed),
            _result('أحمال المحركات', '${fmt(motorW)} W',
                Icons.settings),
          ],
        ),
      ),
    );
  }

  Widget _result(String t, String v, IconData i) => Card(
        child: ListTile(
          leading: CircleAvatar(
              backgroundColor: Colors.green.shade50,
              child: Icon(i, color: Colors.green.shade700)),
          title: Text(t),
          trailing: Text(v,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      );
}

class FullSystemPage extends StatefulWidget {
  const FullSystemPage({super.key});

  @override
  State<FullSystemPage> createState() => _FullSystemPageState();
}

class _FullSystemPageState extends State<FullSystemPage> {
  final daily = TextEditingController(text: '10');
  final peak = TextEditingController(text: '3000');
  final sun = TextEditingController(text: '5.5');
  final loss = TextEditingController(text: '15');
  final auto = TextEditingController(text: '8');
  final bAh = TextEditingController(text: '100');
  final dod = TextEditingController(text: '80');
  final eff = TextEditingController(text: '95');
  final margin = TextEditingController(text: '20');
  final surge = TextEditingController(text: '3');
  double panelW = 550;
  String voltage = '48';

  final List<TextEditingController> _all = [];

  @override
  void initState() {
    super.initState();
    _all.addAll(
        [daily, peak, sun, loss, auto, bAh, dod, eff, margin, surge]);
    for (final c in _all) {
      c.addListener(_onChange);
    }
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    for (final c in _all) {
      c.removeListener(_onChange);
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final e = parseNum(daily.text);
    final p = parseNum(peak.text);
    final s = parseNum(sun.text);
    final l = parseNum(loss.text) / 100;
    final a = parseNum(auto.text);
    final ah = parseNum(bAh.text);
    final d = parseNum(dod.text) / 100;
    final ef = parseNum(eff.text) / 100;
    final m = parseNum(margin.text) / 100;
    final sf = parseNum(surge.text);
    final v = double.tryParse(voltage) ?? 48;

    final perf = math.max(0.01, 1 - l);
    final pvKW = s > 0 ? e / (s * perf) : 0.0;
    final panels = panelW > 0 ? (pvKW * 1000 / panelW).ceil() : 0;

    final backupWh = p * a;
    final battKWh =
        (d > 0 && ef > 0) ? backupWh / (d * ef) / 1000 : 0.0;
    final oneKWh = ah * v / 1000;
    final bCount = oneKWh > 0 ? (battKWh / oneKWh).ceil() : 0;
    final totalAh = bCount * ah;

    final invKW = p * (1 + m) / 1000;
    final surgeKW = p * sf / 1000;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('تصميم النظام الكامل')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _section('الاستهلاك', Icons.bolt),
            _num(daily, 'الاستهلاك اليومي', 'kWh/day'),
            _num(peak, 'الحمل الأقصى', 'W'),
            _section('الألواح', Icons.solar_power),
            _num(sun, 'ساعات الشمس', 'h'),
            _num(loss, 'خسائر النظام', '%'),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: DropdownButtonFormField<double>(
                value: panelW,
                decoration: const InputDecoration(
                    labelText: 'قدرة اللوح', suffixText: 'W'),
                items: const [400, 450, 500, 550, 600]
                    .map((x) => DropdownMenuItem(
                          value: x.toDouble(),
                          child: Text('${x}W'),
                        ))
                    .toList(),
                onChanged: (x) => setState(() => panelW = x ?? 550),
              ),
            ),
            _section('البطارية', Icons.battery_full),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: DropdownButtonFormField<String>(
                value: voltage,
                decoration:
                    const InputDecoration(labelText: 'جهد النظام'),
                items: const ['12', '24', '48']
                    .map((x) => DropdownMenuItem(
                          value: x,
                          child: Text('${x}V'),
                        ))
                    .toList(),
                onChanged: (x) =>
                    setState(() => voltage = x ?? '48'),
              ),
            ),
            _num(bAh, 'سعة البطارية', 'Ah'),
            _num(dod, 'DoD', '%'),
            _num(eff, 'الكفاءة', '%'),
            _num(auto, 'الاستقلالية', 'h'),
            _section('الإنفرتر', Icons.power),
            _num(margin, 'هامش التصميم', '%'),
            _num(surge, 'معامل الإقلاع', '×'),
            const SizedBox(height: 12),
            _big('الألواح المطلوبة', '${fmt(pvKW)} kWp',
                Icons.solar_power),
            _big('عدد الألواح', '$panels لوح', Icons.grid_view),
            _big('البطارية المطلوبة', '${fmt(battKWh)} kWh',
                Icons.battery_full),
            _big('عدد البطاريات', '$bCount',
                Icons.battery_charging_full),
            _big('إجمالي Ah', '${fmt(totalAh)} Ah',
                Icons.battery_std),
            _big('الإنفرتر', '${fmt(invKW)} kW', Icons.power),
            _big('حمل الإقلاع', '${fmt(surgeKW)} kW',
                Icons.flash_on),
          ],
        ),
      ),
    );
  }

  Widget _section(String t, IconData i) => Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 6),
        child: Row(children: [
          Icon(i, color: Colors.green.shade700),
          const SizedBox(width: 8),
          Text(t,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
        ]),
      );

  Widget _num(TextEditingController c, String l, String s) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: TextField(
          controller: c,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: l, suffixText: s),
        ),
      );

  Widget _big(String t, String v, IconData i) => Card(
        color: Colors.green.withOpacity(0.08),
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Icon(i, color: Colors.green.shade800, size: 30),
            const SizedBox(width: 10),
            Expanded(child: Text(t)),
            Text(v,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800)),
          ]),
        ),
      );
}
12),
            _big('الإنفرتر المقترح', '${fmt(recommended / 1000)} kW'),
            _big('حمل الإقلاع', '${fmt(surgeW / 1000)} kW'),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'تنبيه: معامل الإقلاع قيمة تقديرية. '
                  'يجب مراجعة تيار البدء الحقيقي من الداتا شيت.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _num(TextEditingController c, String l, String s) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: TextField(
          controller: c,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: l, suffixText: s),
        ),
      );

  Widget _big(String t, String v) => Card(
        color: Colors.green.withOpacity(0.08),
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Expanded(child: Text(t)),
            Text(v,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800)),
          ]),
        ),
      );
}

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  List<Project> projects = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await ProjectService.loadAll();
    if (!mounted) return;
    setState(() {
      projects = list;
      loading = false;
    });
  }

  Future<void> _addProject() async {
    final nameC = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('مشروع جديد'),
        content: TextField(
          controller: nameC,
          decoration:
              const InputDecoration(labelText: 'اسم المشروع'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, nameC.text.trim()),
            child: const Text('إنشاء'),
          ),
        ],
      ),
    );
    if (result == null || result.isEmpty) return;
    final p = Project(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: result,
      type: 'منزل',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      appliances: [],
    );
    setState(() => projects.add(p));
    await ProjectService.saveAll(projects);
  }

  Future<void> _delete(Project p) async {
    setState(() => projects.removeWhere((x) => x.id == p.id));
    await ProjectService.saveAll(projects);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('مشاريعي')),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _addProject,
          icon: const Icon(Icons.add),
          label: const Text('مشروع جديد'),
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : projects.isEmpty
                ? const Center(child: Text('لا توجد مشاريع بعد'))
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: projects
                        .map((p) => Card(
                              child: ListTile(
                                leading: const CircleAvatar(
                                  child: Icon(Icons.folder),
                                ),
                                title: Text(p.name),
                                subtitle: Text(
                                    'الأجهزة: ${p.appliances.length}'),
                                trailing: IconButton(
                                  icon: const Icon(
                                      Icons.delete_outline),
                                  onPressed: () => _delete(p),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('عن التطبيق')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: const [
                    Icon(Icons.wb_sunny,
                        size: 70, color: Colors.orange),
                    SizedBox(height: 8),
                    Text('SUDANSO',
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('حلول الطاقة الشمسية'),
                    SizedBox(height: 12),
                    Text(
                      'منصة سودانية متخصصة في حساب وتصميم أنظمة '
                      'الطاقة الشمسية واختيار المعدات المناسبة.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            Card(
              child: Column(
                children: const [
                  ListTile(
                    leading: Icon(Icons.info),
                    title: Text('الإصدار'),
                    trailing: Text('1.0.0'),
                  ),
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text('المطور'),
                    trailing: Text('فريق SUDANSO'),
                  ),
                  ListTile(
                    leading: Icon(Icons.email),
                    title: Text('التواصل'),
                    trailing: Text('info@sudanso.app'),
                  ),
                ],
              ),
            ),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(14),
                child: Text(
                  'تنبيه: جميع الحسابات مبدئية ويجب مراجعة '
                  'الداتا شيت الرسمية للمعدات قبل التنفيذ.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
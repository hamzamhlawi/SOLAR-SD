import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() {
  runApp(const SudanSOApp());
}

// ============================================================
// SUDANSO
// Solar Energy Calculator + Solar Market
// Updated Architecture
// ============================================================

class SudanSOApp extends StatelessWidget {
  const SudanSOApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SUDANSO',
      locale: const Locale('ar'),
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF6F9F7),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      home: const HomePage(),
    );
  }
}

// ============================================================
// HELPERS
// ============================================================

double ceilTo(double value, double step) {
  if (step == 0) return value;
  return (value / step).ceil() * step;
}

String f(double value, [int digits = 2]) {
  return value.toStringAsFixed(digits);
}

Widget sectionTitle(String title, IconData icon) {
  return Padding(
    padding: const EdgeInsets.only(top: 18, bottom: 10),
    child: Row(
      children: [
        Icon(icon, color: Colors.green.shade700),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget resultCard({
  required String title,
  required String value,
  String? subtitle,
  IconData icon = Icons.check_circle,
}) {
  return Card(
    elevation: 1,
    margin: const EdgeInsets.symmetric(vertical: 5),
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.green.shade50,
        child: Icon(icon, color: Colors.green.shade700),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: subtitle == null ? null : Text(subtitle),
      trailing: Text(
        value,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: Colors.green.shade800,
        ),
      ),
    ),
  );
}

double parse(String text) {
  return double.tryParse(text.replaceAll(',', '.')) ?? 0;
}

Widget numberField(
  TextEditingController controller,
  String label, {
  String? suffix,
  double? initial,
}) {
  if (initial != null && controller.text.isEmpty) {
    controller.text = initial.toString();
  }

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
      ),
    ),
  );
}

// ============================================================
// HOME
// ============================================================

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        'الحساب الكامل',
        'تصميم نظام شمسي كامل',
        Icons.auto_graph,
        const FullSystemPage()
      ),
      (
        'الأجهزة والاستهلاك',
        'احسب الاستهلاك اليومي بدون نسب مخفية',
        Icons.electrical_services,
        const ApplianceCalculatorPage()
      ),
      (
        'حاسبة الألواح',
        'عدد الألواح والقدرة المطلوبة',
        Icons.solar_power,
        const PanelCalculatorPage()
      ),
      (
        'حاسبة البطارية',
        'Lithium / AGM / FLD',
        Icons.battery_charging_full,
        const BatteryCalculatorPage()
      ),
      (
        'حاسبة الإنفرتر',
        'الحمل المستمر وحمل الإقلاع',
        Icons.power,
        const InverterCalculatorPage()
      ),
      (
        'سوق الإنفرترات',
        'البراندات والمواصفات والأسعار بالدولار',
        Icons.storefront,
        const MarketPage()
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SUDANSO',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.wb_sunny,
                      size: 60,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'SUDANSO',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'حلول الطاقة الشمسية',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...items.map(
              (item) => Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.shade50,
                    child: Icon(item.$3, color: Colors.green.shade700),
                  ),
                  title: Text(
                    item.$1,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(item.$2),
                  trailing: const Icon(Icons.arrow_back_ios_new, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => item.$4),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// APPLIANCE MODEL
// ============================================================

class Appliance {
  String name;
  double watts;
  int quantity;
  double hours;
  bool motor;

  Appliance({
    required this.name,
    required this.watts,
    required this.quantity,
    required this.hours,
    this.motor = false,
  });

  double get dailyWh => watts * quantity * hours;

  double get continuousW => watts * quantity;
}

// ============================================================
// APPLIANCE CALCULATOR
// ============================================================

class ApplianceCalculatorPage extends StatefulWidget {
  const ApplianceCalculatorPage({super.key});

  @override
  State<ApplianceCalculatorPage> createState() =>
      _ApplianceCalculatorPageState();
}

class _ApplianceCalculatorPageState
    extends State<ApplianceCalculatorPage> {
  final List<Appliance> appliances = [];

  double get dailyWh =>
      appliances.fold(0, (sum, a) => sum + a.dailyWh);

  double get peakW =>
      appliances.fold(0, (sum, a) => sum + a.continuousW);

  void addAppliance() {
    final name = TextEditingController();
    final watts = TextEditingController();
    final qty = TextEditingController(text: '1');
    final hours = TextEditingController(text: '4');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('إضافة جهاز'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              numberField(name, 'اسم الجهاز'),
              numberField(watts, 'القدرة W'),
              numberField(qty, 'العدد'),
              numberField(hours, 'ساعات التشغيل يومياً'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                appliances.add(
                  Appliance(
                    name: name.text.isEmpty ? 'جهاز' : name.text,
                    watts: parse(watts.text),
                    quantity: parse(qty.text).round(),
                    hours: parse(hours.text),
                  ),
                );
              });
              Navigator.pop(context);
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الأجهزة والاستهلاك')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addAppliance,
        icon: const Icon(Icons.add),
        label: const Text('إضافة جهاز'),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            sectionTitle('قائمة الأحمال', Icons.devices),
            if (appliances.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Text(
                    'لا توجد أجهزة.\nأضف الأجهزة والقدرة وساعات التشغيل الفعلية.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ...appliances.asMap().entries.map(
              (entry) {
                final index = entry.key;
                final a = entry.value;

                return Card(
                  child: ListTile(
                    title: Text(a.name),
                    subtitle: Text(
                      '${a.watts}W × ${a.quantity} × ${a.hours}h = '
                      '${f(a.dailyWh / 1000)} kWh/day',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        setState(() {
                          appliances.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            resultCard(
              title: 'الاستهلاك اليومي',
              value: '${f(dailyWh / 1000)} kWh',
              icon: Icons.bolt,
            ),
            resultCard(
              title: 'الحمل المتزامن المدخل',
              value: '${f(peakW)} W',
              icon: Icons.speed,
            ),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(14),
                child: Text(
                  'ملاحظة: التطبيق لا يفرض استهلاكاً ثابتاً للثلاجات أو '
                  'المكيفات أو المراوح. أدخل القدرة الحقيقية من لوحة الجهاز '
                  'أو الداتا شيت، وساعات التشغيل الفعلية.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// BATTERY PROFILES
// ============================================================

enum BatteryType {
  lithium,
  agm,
  flooded,
}

String batteryName(BatteryType type) {
  switch (type) {
    case BatteryType.lithium:
      return 'Lithium LiFePO4';
    case BatteryType.agm:
      return 'AGM';
    case BatteryType.flooded:
      return 'FLD / Flooded Lead Acid';
  }
}

double batteryDefaultDod(BatteryType type) {
  switch (type) {
    case BatteryType.lithium:
      return 80;
    case BatteryType.agm:
      return 50;
    case BatteryType.flooded:
      return 50;
  }
}

double batteryDefaultEfficiency(BatteryType type) {
  switch (type) {
    case BatteryType.lithium:
      return 95;
    case BatteryType.agm:
      return 90;
    case BatteryType.flooded:
      return 85;
  }
}

double voltageFor(BatteryType type, String system) {
  if (type == BatteryType.lithium) {
    switch (system) {
      case '12V':
        return 12.55;
      case '24V':
        return 25.10;
      case '48V':
        return 51.20;
    }
  }

  switch (system) {
    case '12V':
      return 12;
    case '24V':
      return 24;
    case '48V':
      return 48;
  }

  return 48;
}

// ============================================================
// FULL SYSTEM
// ============================================================

class FullSystemPage extends StatefulWidget {
  const FullSystemPage({super.key});

  @override
  State<FullSystemPage> createState() => _FullSystemPageState();
}

class _FullSystemPageState extends State<FullSystemPage> {
  final dailyEnergy = TextEditingController(text: '10');
  final peakLoad = TextEditingController(text: '3000');
  final sunHours = TextEditingController(text: '5.5');
  final pvLoss = TextEditingController(text: '15');

  final autonomy = TextEditingController(text: '8');
  final batteryAh = TextEditingController(text: '100');
  final dod = TextEditingController();
  final efficiency = TextEditingController();
  final inverterMargin = TextEditingController(text: '20');
  final surge = TextEditingController(text: '2');

  BatteryType batteryType = BatteryType.lithium;
  String batterySystem = '48V';

  double panelW = 550;

  @override
  void initState() {
    super.initState();
    updateBatteryDefaults();
  }

  void updateBatteryDefaults() {
    dod.text = batteryDefaultDod(batteryType).toString();
    efficiency.text =
        batteryDefaultEfficiency(batteryType).toString();
  }

  @override
  void dispose() {
    dailyEnergy.dispose();
    peakLoad.dispose();
    sunHours.dispose();
    pvLoss.dispose();
    autonomy.dispose();
    batteryAh.dispose();
    dod.dispose();
    efficiency.dispose();
    inverterMargin.dispose();
    surge.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final energy = parse(dailyEnergy.text);
    final load = parse(peakLoad.text);
    final sun = parse(sunHours.text);
    final losses = parse(pvLoss.text);
    final auto = parse(autonomy.text);
    final ah = parse(batteryAh.text);
    final d = parse(dod.text) / 100;
    final eff = parse(efficiency.text) / 100;
    final margin = parse(inverterMargin.text) / 100;
    final surgeFactor = parse(surge.text);

    final performance = math.max(0.01, 1 - losses);

    final pvKW = sun > 0
        ? energy / (sun * performance)
        : 0;

    final panels = panelW > 0
        ? (pvKW * 1000 / panelW).ceil()
        : 0;

    final inverterW = load * (1 + margin);

    final surgeW = load * surgeFactor;

    final backupWh = load * auto;

    final batteryKWh =
        (d > 0 && eff > 0)
            ? backupWh / (d * eff) / 1000
            : 0;

    final selectedVoltage =
        voltageFor(batteryType, batterySystem);

    final batteryEnergyEach =
        ah * selectedVoltage / 1000;

    final batteryCount =
        batteryEnergyEach > 0
            ? (batteryKWh / batteryEnergyEach).ceil()
            : 0;

    final totalAh =
        batteryCount * ah;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تصميم النظام الكامل'),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            sectionTitle(
              'الاستهلاك والحمل',
              Icons.electrical_services,
            ),
            numberField(
              dailyEnergy,
              'الاستهلاك اليومي',
              suffix: 'kWh/day',
            ),
            numberField(
              peakLoad,
              'الحمل الأقصى المتزامن',
              suffix: 'W',
            ),

            sectionTitle(
              'الألواح الشمسية',
              Icons.solar_power,
            ),
            numberField(
              sunHours,
              'ساعات الشمس الفعالة',
              suffix: 'h/day',
            ),
            numberField(
              pvLoss,
              'خسائر النظام',
              suffix: '%',
            ),
            DropdownButtonFormField<double>(
              value: panelW,
              decoration: const InputDecoration(
                labelText: 'قدرة اللوح',
                suffixText: 'W',
              ),
              items: const [400, 450, 500, 540, 550, 580, 600]
                  .map(
                    (v) => DropdownMenuItem(
                      value: v.toDouble(),
                      child: Text('${v}W'),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  setState(() => panelW = v);
                }
              },
            ),

            sectionTitle(
              'البطارية',
              Icons.battery_full,
            ),

            DropdownButtonFormField<BatteryType>(
              value: batteryType,
              decoration: const InputDecoration(
                labelText: 'نوع البطارية',
              ),
              items: BatteryType.values
                  .map(
                    (type) => DropdownMenuItem(
                      value: type,
                      child: Text(batteryName(type)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    batteryType = value;
                    updateBatteryDefaults();
                  });
                }
              },
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              value: batterySystem,
              decoration: const InputDecoration(
                labelText: 'نظام البطارية',
              ),
              items: const ['12V', '24V', '48V']
                  .map(
                    (v) => DropdownMenuItem(
                      value: v,
                      child: Text(v),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => batterySystem = value);
                }
              },
            ),

            const SizedBox(height: 8),

            resultCard(
              title: 'جهد البطارية المستخدم',
              value:
                  '${f(voltageFor(batteryType, batterySystem), 2)} V',
              icon: Icons.bolt,
            ),

            numberField(
              batteryAh,
              'سعة البطارية الواحدة',
              suffix: 'Ah',
            ),

            numberField(
              dod,
              'Depth of Discharge',
              suffix: '%',
            ),

            numberField(
              efficiency,
              'كفاءة البطارية/التفريغ',
              suffix: '%',
            ),

            numberField(
              autonomy,
              'زمن الاستقلالية',
              suffix: 'h',
            ),

            sectionTitle(
              'الإنفرتر',
              Icons.power,
            ),

            numberField(
              inverterMargin,
              'هامش قدرة الإنفرتر',
              suffix: '%',
            ),

            numberField(
              surge,
              'معامل حمل الإقلاع للمحركات',
              suffix: '×',
            ),

            const SizedBox(height: 10),

            resultCard(
              title: 'الاستهلاك اليومي',
              value: '${f(energy)} kWh',
            ),
            resultCard(
              title: 'قدرة الألواح المطلوبة',
              value: '${f(pvKW)} kWp',
              icon: Icons.solar_power,
            ),
            resultCard(
              title: 'عدد الألواح',
              value: '$panels لوح',
              icon: Icons.grid_view,
            ),
            resultCard(
              title: 'قدرة الإنفرتر المقترحة',
              value: '${f(inverterW / 1000)} kW',
              icon: Icons.power,
            ),
            resultCard(
              title: 'حمل الإقلاع النظري',
              value: '${f(surgeW / 1000)} kW',
              icon: Icons.flash_on,
            ),
            resultCard(
              title: 'طاقة البطارية الاسمية المطلوبة',
              value: '${f(batteryKWh)} kWh',
              icon: Icons.battery_full,
            ),
            resultCard(
              title: 'عدد البطاريات',
              value: '$batteryCount',
              icon: Icons.battery_charging_full,
            ),
            resultCard(
              title: 'إجمالي Ah',
              value: '${f(totalAh)} Ah',
              icon: Icons.battery_std,
            ),

            const Card(
              child: Padding(
                padding: EdgeInsets.all(14),
                child: Text(
                  'تنبيه هندسي:\n'
                  'هذه حاسبة تصميم أولي. يجب مقارنة Voc/Vmp/Isc للألواح '
                  'مع حدود MPPT الفعلية للإنفرتر، ومراجعة تيارات الإقلاع '
                  'للمحركات والضواغط من الداتا شيت قبل التنفيذ.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PANEL CALCULATOR
// ============================================================

class PanelCalculatorPage extends StatefulWidget {
  const PanelCalculatorPage({super.key});

  @override
  State<PanelCalculatorPage> createState() =>
      _PanelCalculatorPageState();
}

class _PanelCalculatorPageState
    extends State<PanelCalculatorPage> {
  final energy = TextEditingController(text: '10');
  final sun = TextEditingController(text: '5.5');
  final losses = TextEditingController(text: '15');
  final panel = TextEditingController(text: '550');

  final voc = TextEditingController(text: '52.4');
  final vmp = TextEditingController(text: '42.3');
  final isc = TextEditingController(text: '14');
  final imp = TextEditingController(text: '13');

  final mpptMin = TextEditingController(text: '120');
  final mpptMax = TextEditingController(text: '450');
  final maxVoc = TextEditingController(text: '500');

  @override
  Widget build(BuildContext context) {
    final e = parse(energy.text);
    final s = parse(sun.text);
    final l = parse(losses.text) / 100;
    final p = parse(panel.text);

    final requiredKW =
        s > 0 ? e / (s * math.max(0.01, 1 - l)) : 0;

    final count =
        p > 0 ? (requiredKW * 1000 / p).ceil() : 0;

    final vocV = parse(voc.text);
    final vmpV = parse(vmp.text);
    final mpptLow = parse(mpptMin.text);
    final mpptHigh = parse(mpptMax.text);
    final maxVocV = parse(maxVoc.text);

    final seriesMin =
        vmpV > 0 ? (mpptLow / vmpV).ceil() : 0;

    final seriesMax =
        vocV > 0 ? math.min(
          (mpptHigh / vmpV).floor(),
          (maxVocV / vocV).floor(),
        ) : 0;

    return Scaffold(
      appBar: AppBar(title: const Text('حاسبة الألواح')),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            sectionTitle(
              'الطاقة اليومية',
              Icons.bolt,
            ),
            numberField(
              energy,
              'الاستهلاك اليومي',
              suffix: 'kWh/day',
            ),
            numberField(
              sun,
              'ساعات الشمس الفعالة',
              suffix: 'h',
            ),
            numberField(
              losses,
              'خسائر النظام',
              suffix: '%',
            ),
            numberField(
              panel,
              'قدرة اللوح',
              suffix: 'W',
            ),

            sectionTitle(
              'بيانات اللوح',
              Icons.solar_power,
            ),
            numberField(voc, 'Voc', suffix: 'V'),
            numberField(vmp, 'Vmp', suffix: 'V'),
            numberField(isc, 'Isc', suffix: 'A'),
            numberField(imp, 'Imp', suffix: 'A'),

            sectionTitle(
              'بيانات MPPT للإنفرتر',
              Icons.tune,
            ),
            numberField(
              mpptMin,
              'أقل جهد MPPT',
              suffix: 'V',
            ),
            numberField(
              mpptMax,
              'أعلى جهد MPPT',
              suffix: 'V',
            ),
            numberField(
              maxVoc,
              'أقصى Voc للإنفرتر',
              suffix: 'V',
            ),

            const SizedBox(height: 10),

            resultCard(
              title: 'قدرة PV المطلوبة',
              value: '${f(requiredKW)} kWp',
            ),
            resultCard(
              title: 'عدد الألواح',
              value: '$count لوح',
              icon: Icons.grid_view,
            ),
            resultCard(
              title: 'عدد الألواح Series المقترح',
              value: '$seriesMin – $seriesMax',
              subtitle:
                  'يجب تأكيد التصميم النهائي مع درجات الحرارة وبيانات الداتا شيت.',
              icon: Icons.linear_scale,
            ),

            const Card(
              child: Padding(
                padding: EdgeInsets.all(14),
                child: Text(
                  'الحساب لا يفترض أن كل الألواح متطابقة مع أي إنفرتر. '
                  'يتم فحص نطاق MPPT وVoc، لكن يجب أيضاً فحص Isc/Imp '
                  'والحد الأقصى لتيار كل MPPT.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// BATTERY CALCULATOR
// ============================================================

class BatteryCalculatorPage extends StatefulWidget {
  const BatteryCalculatorPage({super.key});

  @override
  State<BatteryCalculatorPage> createState() =>
      _BatteryCalculatorPageState();
}

class _BatteryCalculatorPageState
    extends State<BatteryCalculatorPage> {
  final load = TextEditingController(text: '1000');
  final hours = TextEditingController(text: '8');
  final ah = TextEditingController(text: '100');
  final dod = TextEditingController();
  final efficiency = TextEditingController();

  BatteryType type = BatteryType.lithium;
  String system = '48V';

  @override
  void initState() {
    super.initState();
    update();
  }

  void update() {
    dod.text = batteryDefaultDod(type).toString();
    efficiency.text =
        batteryDefaultEfficiency(type).toString();
  }

  @override
  Widget build(BuildContext context) {
    final loadW = parse(load.text);
    final h = parse(hours.text);
    final batteryAhValue = parse(ah.text);
    final d = parse(dod.text) / 100;
    final eff = parse(efficiency.text) / 100;

    final voltage = voltageFor(type, system);
    final backupWh = loadW * h;

    final requiredKWh =
        d > 0 && eff > 0
            ? backupWh / (d * eff) / 1000
            : 0;

    final eachKWh =
        batteryAhValue * voltage / 1000;

    final count =
        eachKWh > 0
            ? (requiredKWh / eachKWh).ceil()
            : 0;

    return Scaffold(
      appBar: AppBar(title: const Text('حاسبة البطارية')),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            sectionTitle(
              'نوع البطارية',
              Icons.battery_full,
            ),

            DropdownButtonFormField<BatteryType>(
              value: type,
              decoration: const InputDecoration(
                labelText: 'نوع البطارية',
              ),
              items: BatteryType.values
                  .map(
                    (x) => DropdownMenuItem(
                      value: x,
                      child: Text(batteryName(x)),
                    ),
                  )
                  .toList(),
              onChanged: (x) {
                if (x != null) {
                  setState(() {
                    type = x;
                    update();
                  });
                }
              },
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              value: system,
              decoration: const InputDecoration(
                labelText: 'نظام البطارية',
              ),
              items: const ['12V', '24V', '48V']
                  .map(
                    (x) => DropdownMenuItem(
                      value: x,
                      child: Text(x),
                    ),
                  )
                  .toList(),
              onChanged: (x) {
                if (x != null) {
                  setState(() => system = x);
                }
              },
            ),

            const SizedBox(height: 8),

            resultCard(
              title: 'الجهد المستخدم',
              value:
                  '${f(voltageFor(type, system), 2)} V',
            ),

            sectionTitle(
              'بيانات الحمل',
              Icons.power,
            ),

            numberField(
              load,
              'الحمل أثناء فترة البطارية',
              suffix: 'W',
            ),

            numberField(
              hours,
              'زمن التشغيل',
              suffix: 'h',
            ),

            numberField(
              ah,
              'Ah للبطارية الواحدة',
              suffix: 'Ah',
            ),

            numberField(
              dod,
              'DoD',
              suffix: '%',
            ),

            numberField(
              efficiency,
              'كفاءة البطارية',
              suffix: '%',
            ),

            const SizedBox(height: 10),

            resultCard(
              title: 'الطاقة المطلوبة من الحمل',
              value: '${f(backupWh / 1000)} kWh',
            ),
            resultCard(
              title: 'السعة الاسمية المطلوبة',
              value: '${f(requiredKWh)} kWh',
            ),
            resultCard(
              title: 'طاقة البطارية الواحدة',
              value: '${f(eachKWh)} kWh',
            ),
            resultCard(
              title: 'عدد البطاريات',
              value: '$count',
            ),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  type == BatteryType.lithium
                      ? 'Lithium: يجب الالتزام بحدود الشحن والتفريغ وBMS الخاصة بالموديل.'
                      : type == BatteryType.agm
                          ? 'AGM: لا تستخدم Equalization إلا إذا نصت الشركة المصنعة على ذلك.'
                          : 'FLD: تحتاج تهوية وصيانة ومتابعة مستوى الإلكتروليت حسب الشركة المصنعة.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// INVERTER CALCULATOR
// ============================================================

class InverterCalculatorPage extends StatefulWidget {
  const InverterCalculatorPage({super.key});

  @override
  State<InverterCalculatorPage> createState() =>
      _InverterCalculatorPageState();
}

class _InverterCalculatorPageState
    extends State<InverterCalculatorPage> {
  final load = TextEditingController(text: '3000');
  final margin = TextEditingController(text: '20');
  final surge = TextEditingController(text: '2');

  @override
  Widget build(BuildContext context) {
    final w = parse(load.text);
    final m = parse(margin.text) / 100;
    final s = parse(surge.text);

    final recommended = w * (1 + m);
    final surgeW = w * s;

    return Scaffold(
      appBar: AppBar(title: const Text('حاسبة الإنفرتر')),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            numberField(
              load,
              'الحمل المستمر',
              suffix: 'W',
            ),
            numberField(
              margin,
              'هامش التصميم',
              suffix: '%',
            ),
            numberField(
              surge,
              'معامل الإقلاع',
              suffix: '×',
            ),

            const SizedBox(height: 10),

            resultCard(
              title: 'الإنفرتر المستمر المقترح',
              value: '${f(recommended / 1000)} kW',
              icon: Icons.power,
            ),
            resultCard(
              title: 'قدرة Surge النظرية',
              value: '${f(surgeW / 1000)} kW',
              icon: Icons.flash_on,
            ),

            const Card(
              child: Padding(
                padding: EdgeInsets.all(14),
                child: Text(
                  'معامل Surge ليس قيمة ثابتة لكل الأجهزة. '
                  'المحركات والضواغط قد تحتاج بيانات تيار البدء من لوحة المحرك '
                  'أو الداتا شيت للحصول على نتيجة أدق.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// MARKET DATA MODEL
// ============================================================

enum QualityLevel {
  premium,
  mid,
  economy,
}

class InverterProduct {
  final String brand;
  final QualityLevel level;
  final String model;
  final String type;
  final double powerKW;
  final String phase;
  final String battery;
  final String batteryRange;
  final String maxPv;
  final String maxPvVoltage;
  final String mpptRange;
  final String mppt;
  final String pvCurrent;
  final String acVoltage;
  final String acFrequency;
  final String maxOutputCurrent;
  final String efficiency;
  final String surge;
  final String communication;
  final String protection;
  final String cooling;
  final String temperature;
  final String altitude;
  final String dimensions;
  final String weight;
  final String ip;
  final String warranty;
  final double? priceUsd;
  final String priceNote;
  final String datasheetUrl;

  const InverterProduct({
    required this.brand,
    required this.level,
    required this.model,
    required this.type,
    required this.powerKW,
    required this.phase,
    required this.battery,
    required this.batteryRange,
    required this.maxPv,
    required this.maxPvVoltage,
    required this.mpptRange,
    required this.mppt,
    required this.pvCurrent,
    required this.acVoltage,
    required this.acFrequency,
    required this.maxOutputCurrent,
    required this.efficiency,
    required this.surge,
    required this.communication,
    required this.protection,
    required this.cooling,
    required this.temperature,
    required this.altitude,
    required this.dimensions,
    required this.weight,
    required this.ip,
    required this.warranty,
    required this.priceUsd,
    required this.priceNote,
    required this.datasheetUrl,
  });
}

// ============================================================
// MARKET DATABASE
// ============================================================

final List<String> premiumBrands = [
  'Solis',
  'Deye',
  'FusionSolar / Huawei',
];

final List<String> midBrands = [
  'GSB',
  'Motoma',
  'Felicity Solar',
  'MUST',
];

final List<String> economyBrands = [
  'VACKSON',
  'Restar',
  'Eruonet',
  'Megasun',
];

final List<InverterProduct> products = [
  // ----------------------------------------------------------
  // SOLIS
  // ----------------------------------------------------------
  InverterProduct(
    brand: 'Solis',
    level: QualityLevel.premium,
    model: 'S6-EH1P6K-L-PLUS',
    type: 'Hybrid',
    powerKW: 6,
    phase: 'Single Phase',
    battery: '48V / Low Voltage',
    batteryRange: 'حسب إصدار البطارية',
    maxPv: '9.6 kW usable',
    maxPvVoltage: '500 V',
    mpptRange: '90–435 V',
    mppt: '2 MPPT / حتى 4 strings',
    pvCurrent: 'حسب إصدار MPPT',
    acVoltage: '220/230/240 V',
    acFrequency: '50/60 Hz',
    maxOutputCurrent: 'حسب الداتا شيت',
    efficiency: '97.5% تقريباً',
    surge: 'حسب الإصدار',
    communication: 'WiFi / RS485 / CAN حسب التكوين',
    protection: 'حماية DC/AC حسب الإصدار',
    cooling: 'Fan / حسب الإصدار',
    temperature: 'حسب الداتا شيت',
    altitude: 'حسب الداتا شيت',
    dimensions: 'حسب الداتا شيت',
    weight: 'حسب الداتا شيت',
    ip: 'حسب الإصدار',
    warranty: 'حسب السوق والموديل',
    priceUsd: 875,
    priceNote: 'سعر مرجعي من متجر خارجي، وليس سعراً سودانياً ثابتاً.',
    datasheetUrl:
        'https://www.solisinverters.com/us/downloadcenter.html',
  ),

  // ----------------------------------------------------------
  // DEYE
  // ----------------------------------------------------------
  InverterProduct(
    brand: 'Deye',
    level: QualityLevel.premium,
    model: 'SUN-6K-SG05LP1-EU',
    type: 'Hybrid',
    powerKW: 6,
    phase: 'Single Phase',
    battery: 'Low Voltage',
    batteryRange: 'حسب إصدار البطارية',
    maxPv: 'حسب الداتا شيت',
    maxPvVoltage: 'حسب الداتا شيت',
    mpptRange: 'حسب الداتا شيت',
    mppt: 'حسب الداتا شيت',
    pvCurrent: 'حسب الداتا شيت',
    acVoltage: '220/230 V',
    acFrequency: '50/60 Hz',
    maxOutputCurrent: 'حسب الداتا شيت',
    efficiency: 'حسب الإصدار',
    surge: 'حسب الداتا شيت',
    communication: 'CAN / RS485 / WiFi حسب الإصدار',
    protection: 'حسب الداتا شيت',
    cooling: 'Fan',
    temperature: 'حسب الداتا شيت',
    altitude: 'حسب الداتا شيت',
    dimensions: 'حسب الداتا شيت',
    weight: 'حسب الداتا شيت',
    ip: 'حسب الإصدار',
    warranty: '5 سنوات لبعض العروض',
    priceUsd: 1671,
    priceNote:
        'سعر مرجعي لإصدار SUN-6K-SG05LP1-EU؛ السعر يختلف حسب المورد والكمية.',
    datasheetUrl:
        'https://www.deyeinverter.com/download/product-2/',
  ),

  // ----------------------------------------------------------
  // HUAWEI / FUSIONSOLAR
  // ----------------------------------------------------------
  InverterProduct(
    brand: 'FusionSolar / Huawei',
    level: QualityLevel.premium,
    model: 'SUN2000-6KTL-L1',
    type: 'Smart Energy Controller',
    powerKW: 6,
    phase: 'Single Phase',
    battery: 'High Voltage',
    batteryRange: '350–560 V DC',
    maxPv: '9 kWp recommended',
    maxPvVoltage: '600 V',
    mpptRange: '90–560 V',
    mppt: '2 MPPT',
    pvCurrent: '12.5 A / MPPT',
    acVoltage: '220/230/240 V',
    acFrequency: '50/60 Hz',
    maxOutputCurrent: '27.3 A',
    efficiency: '98.4%',
    surge: 'حسب النظام',
    communication: 'RS485 / WLAN / Ethernet optional / 4G optional',
    protection: 'DC/AC SPD Type II, AFCI, anti-islanding وغيرها',
    cooling: 'Natural Convection',
    temperature: '-25 إلى +60°C',
    altitude: '0–4000 m',
    dimensions: '365 × 375 × 156 mm',
    weight: '12 kg',
    ip: 'IP65',
    warranty: 'حسب السوق',
    priceUsd: null,
    priceNote:
        'لم أضع سعراً غير موثق لهذا الموديل. أضف سعر المورد عند توفره.',
    datasheetUrl:
        'https://solar.huawei.com/en/products/SUN2000-3-4-5-6KTL-L1/specs/',
  ),

  // ----------------------------------------------------------
  // GSB
  // ----------------------------------------------------------
  InverterProduct(
    brand: 'GSB',
    level: QualityLevel.mid,
    model: 'GSB 6kW — حسب الموديل',
    type: 'Hybrid / Off-grid',
    powerKW: 6,
    phase: 'حسب الموديل',
    battery: 'حسب الموديل',
    batteryRange: 'يحدد من الداتا شيت',
    maxPv: 'يحدد من الداتا شيت',
    maxPvVoltage: 'يحدد من الداتا شيت',
    mpptRange: 'يحدد من الداتا شيت',
    mppt: 'يحدد من الداتا شيت',
    pvCurrent: 'يحدد من الداتا شيت',
    acVoltage: 'حسب الموديل',
    acFrequency: '50/60 Hz',
    maxOutputCurrent: 'حسب الموديل',
    efficiency: 'حسب الموديل',
    surge: 'حسب الموديل',
    communication: 'حسب الموديل',
    protection: 'حسب الموديل',
    cooling: 'حسب الموديل',
    temperature: 'حسب الموديل',
    altitude: 'حسب الموديل',
    dimensions: 'حسب الموديل',
    weight: 'حسب الموديل',
    ip: 'حسب الموديل',
    warranty: 'حسب المورد',
    priceUsd: null,
    priceNote: 'السعر يضاف بعد تحديد موديل GSB بالضبط.',
    datasheetUrl: '',
  ),

  // ----------------------------------------------------------
  // MOTOMA
  // ----------------------------------------------------------
  InverterProduct(
    brand: 'Motoma',
    level: QualityLevel.mid,
    model: 'Motoma 48V 6000W',
    type: 'Solar Inverter',
    powerKW: 6,
    phase: 'Single Phase',
    battery: '48V',
    batteryRange: '48V',
    maxPv: '6 kW',
    maxPvVoltage: '500 V Voc',
    mpptRange: '60–450 V',
    mppt: 'MPPT',
    pvCurrent: 'حسب الداتا شيت',
    acVoltage: '220/230 V',
    acFrequency: '50/60 Hz',
    maxOutputCurrent: 'حسب الموديل',
    efficiency: 'حسب الموديل',
    surge: 'حسب الموديل',
    communication: 'RS485 / USB / حسب الإصدار',
    protection: 'حسب الداتا شيت',
    cooling: 'Fan',
    temperature: 'حسب الداتا شيت',
    altitude: 'حسب الداتا شيت',
    dimensions: 'حسب الداتا شيت',
    weight: 'حسب الداتا شيت',
    ip: 'حسب الداتا شيت',
    warranty: 'حسب المورد',
    priceUsd: null,
    priceNote: 'السعر يضاف بعد تحديد عرض المورد.',
    datasheetUrl: 'https://motoma.com/',
  ),

  // ----------------------------------------------------------
  // FELICITY
  // ----------------------------------------------------------
  InverterProduct(
    brand: 'Felicity Solar',
    level: QualityLevel.mid,
    model: 'IVAM6048P1G1',
    type: 'Off-grid',
    powerKW: 6,
    phase: 'Single Phase',
    battery: '48V',
    batteryRange: '40–60 V',
    maxPv: '9.6 kW',
    maxPvVoltage: '500 V',
    mpptRange: '90–425 V',
    mppt: '2 MPPT',
    pvCurrent: '20A + 20A',
    acVoltage: '230 V',
    acFrequency: '50/60 Hz',
    maxOutputCurrent: '26.1 A',
    efficiency: '97.6%',
    surge: '2× لمدة 10 ثوانٍ حسب الداتا',
    communication: 'حسب الإصدار',
    protection: 'حسب الداتا شيت',
    cooling: 'Fan',
    temperature: 'حسب الداتا شيت',
    altitude: 'حسب الداتا شيت',
    dimensions: 'حسب الداتا شيت',
    weight: 'حسب الداتا شيت',
    ip: 'حسب الداتا شيت',
    warranty: 'حسب السوق',
    priceUsd: 495,
    priceNote:
        'سعر مرجعي من متجر خارجي؛ يوجد اختلاف حسب الموديل والمورد.',
    datasheetUrl:
        'https://felicitysolar.me/en/products/inverters/ivam6048p1g1',
  ),

  // ----------------------------------------------------------
  // MUST
  // ----------------------------------------------------------
  InverterProduct(
    brand: 'MUST',
    level: QualityLevel.mid,
    model: 'MUST 6kW 48V',
    type: 'Off-grid / Solar',
    powerKW: 6,
    phase: 'Single Phase',
    battery: '24/48V حسب الموديل',
    batteryRange: 'حسب الموديل',
    maxPv: 'حسب الموديل',
    maxPvVoltage: 'حسب الموديل',
    mpptRange: 'حسب الموديل',
    mppt: 'حسب الموديل',
    pvCurrent: 'حسب الموديل',
    acVoltage: '220–240 V',
    acFrequency: '50/60 Hz',
    maxOutputCurrent: 'حسب الموديل',
    efficiency: '93% في عرض PV3500',
    surge: 'حسب الموديل',
    communication: 'USB / RS485 / WiFi optional',
    protection: 'حسب الموديل',
    cooling: 'Fan',
    temperature: 'حسب الداتا شيت',
    altitude: 'حسب الداتا شيت',
    dimensions: '670 × 410 × 215 mm في العرض المذكور',
    weight: 'حسب الموديل',
    ip: 'حسب الموديل',
    warranty: 'حسب المورد',
    priceUsd: 460,
    priceNote:
        'سعر مرجعي لعرض 6kW؛ لا يمثل جميع موديلات MUST.',
    datasheetUrl:
        'https://www.mustpower.com/',
  ),

  // ----------------------------------------------------------
  // ECONOMY
  // ----------------------------------------------------------
  InverterProduct(
    brand: 'VACKSON',
    level: QualityLevel.economy,
    model: 'VACKSON — حسب الموديل',
    type: 'Hybrid / Off-grid',
    powerKW: 6,
    phase: 'حسب الموديل',
    battery: 'حسب الموديل',
    batteryRange: 'يحدد من الداتا شيت',
    maxPv: 'يحدد من الداتا شيت',
    maxPvVoltage: 'يحدد من الداتا شيت',
    mpptRange: 'يحدد من الداتا شيت',
    mppt: 'يحدد من الداتا شيت',
    pvCurrent: 'يحدد من الداتا شيت',
    acVoltage: 'حسب الموديل',
    acFrequency: '50/60 Hz',
    maxOutputCurrent: 'حسب الموديل',
    efficiency: 'حسب الموديل',
    surge: 'حسب الموديل',
    communication: 'حسب الموديل',
    protection: 'حسب الموديل',
    cooling: 'حسب الموديل',
    temperature: 'حسب الموديل',
    altitude: 'حسب الموديل',
    dimensions: 'حسب الموديل',
    weight: 'حسب الموديل',
    ip: 'حسب الموديل',
    warranty: 'حسب المورد',
    priceUsd: null,
    priceNote: 'السعر والمواصفات تحتاج رقم الموديل.',
    datasheetUrl: '',
  ),

  InverterProduct(
    brand: 'Restar',
    level: QualityLevel.economy,
    model: 'Restar RT-HY / RT-I — حسب الموديل',
    type: 'Hybrid / Off-grid',
    powerKW: 6,
    phase: 'حسب الموديل',
    battery: 'حسب الموديل',
    batteryRange: 'حسب الموديل',
    maxPv: 'حسب الموديل',
    maxPvVoltage: 'حسب الموديل',
    mpptRange: 'حسب الموديل',
    mppt: 'حسب الموديل',
    pvCurrent: 'حسب الموديل',
    acVoltage: 'حسب الموديل',
    acFrequency: '50/60 Hz',
    maxOutputCurrent: 'حسب الموديل',
    efficiency: 'حسب الموديل',
    surge: 'حسب الموديل',
    communication: 'حسب الموديل',
    protection: 'حسب الموديل',
    cooling: 'حسب الموديل',
    temperature: 'حسب الموديل',
    altitude: 'حسب الموديل',
    dimensions: 'حسب الموديل',
    weight: 'حسب الموديل',
    ip: 'حسب الموديل',
    warranty: 'حسب المورد',
    priceUsd: null,
    priceNote: 'السعر يعتمد على الموديل والعرض.',
    datasheetUrl:
        'https://www.restarsolar.com/download/index_20.html',
  ),

  InverterProduct(
    brand: 'Eruonet',
    level: QualityLevel.economy,
    model: 'Eruonet — حسب الموديل',
    type: 'Solar Inverter',
    powerKW: 6,
    phase: 'حسب الموديل',
    battery: 'حسب الموديل',
    batteryRange: 'حسب الموديل',
    maxPv: 'حسب الموديل',
    maxPvVoltage: 'حسب الموديل',
    mpptRange: 'حسب الموديل',
    mppt: 'حسب الموديل',
    pvCurrent: 'حسب الموديل',
    acVoltage: 'حسب الموديل',
    acFrequency: '50/60 Hz',
    maxOutputCurrent: 'حسب الموديل',
    efficiency: 'حسب الموديل',
    surge: 'حسب الموديل',
    communication: 'حسب الموديل',
    protection: 'حسب الموديل',
    cooling: 'حسب الموديل',
    temperature: 'حسب الموديل',
    altitude: 'حسب الموديل',
    dimensions: 'حسب الموديل',
    weight: 'حسب الموديل',
    ip: 'حسب الموديل',
    warranty: 'حسب المورد',
    priceUsd: null,
    priceNote: 'أدخل الموديل للحصول على Data Sheet دقيقة.',
    datasheetUrl: '',
  ),

  InverterProduct(
    brand: 'Megasun',
    level: QualityLevel.economy,
    model: 'Megasun — حسب الموديل',
    type: 'Solar Inverter',
    powerKW: 6,
    phase: 'حسب الموديل',
    battery: 'حسب الموديل',
    batteryRange: 'حسب الموديل',
    maxPv: 'حسب الموديل',
    maxPvVoltage: 'حسب الموديل',
    mpptRange: 'حسب الموديل',
    mppt: 'حسب الموديل',
    pvCurrent: 'حسب الموديل',
    acVoltage: 'حسب الموديل',
    acFrequency: '50/60 Hz',
    maxOutputCurrent: 'حسب الموديل',
    efficiency: 'حسب الموديل',
    surge: 'حسب الموديل',
    communication: 'حسب الموديل',
    protection: 'حسب الموديل',
    cooling: 'حسب الموديل',
    temperature: 'حسب الموديل',
    altitude: 'حسب الموديل',
    dimensions: 'حسب الموديل',
    weight: 'حسب الموديل',
    ip: 'حسب الموديل',
    warranty: 'حسب المورد',
    priceUsd: null,
    priceNote: 'أدخل الموديل للحصول على Data Sheet دقيقة.',
    datasheetUrl: '',
  ),
];

// ============================================================
// MARKET PAGE
// ============================================================

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  QualityLevel? filter;

  @override
  Widget build(BuildContext context) {
    final list = filter == null
        ? products
        : products.where((p) => p.level == filter).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('سوق SUDANSO'),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                  'أسعار المنتجات بالدولار الأمريكي فقط.\n'
                  'الأسعار المرجعية قابلة للتغير حسب المورد والكمية والشحن.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('الكل'),
                  selected: filter == null,
                  onSelected: (_) {
                    setState(() => filter = null);
                  },
                ),
                FilterChip(
                  label: const Text('Premium'),
                  selected: filter == QualityLevel.premium,
                  onSelected: (_) {
                    setState(
                      () => filter = QualityLevel.premium,
                    );
                  },
                ),
                FilterChip(
                  label: const Text('Mid-range'),
                  selected: filter == QualityLevel.mid,
                  onSelected: (_) {
                    setState(
                      () => filter = QualityLevel.mid,
                    );
                  },
                ),
                FilterChip(
                  label: const Text('Economy'),
                  selected: filter == QualityLevel.economy,
                  onSelected: (_) {
                    setState(
                      () => filter = QualityLevel.economy,
                    );
                  },
                ),
              ],
            ),

            sectionTitle(
              'البراندات الموجودة في السوق',
              Icons.store,
            ),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...premiumBrands.map(
                  (x) => Chip(
                    avatar: const Icon(
                      Icons.workspace_premium,
                      size: 18,
                    ),
                    label: Text(x),
                  ),
                ),
                ...midBrands.map(
                  (x) => Chip(label: Text(x)),
                ),
                ...economyBrands.map(
                  (x) => Chip(label: Text(x)),
                ),
              ],
            ),

            sectionTitle(
              'المنتجات',
              Icons.inventory_2,
            ),

            ...list.map(
              (product) => Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ProductDetailsPage(product: product),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor:
                                  Colors.green.shade50,
                              child: Icon(
                                Icons.power,
                                color: Colors.green.shade700,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.brand,
                                    style: TextStyle(
                                      color:
                                          Colors.green.shade800,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    product.model,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${f(product.powerKW, 0)} kW',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const Divider(),

                        Row(
                          children: [
                            Expanded(
                              child: Text(product.type),
                            ),
                            Expanded(
                              child: Text(product.battery),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        if (product.priceUsd != null)
                          Text(
                            '\$${f(product.priceUsd!, 0)} USD',
                            style: TextStyle(
                              color: Colors.green.shade800,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        else
                          const Text(
                            'السعر: غير مضاف',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                        const SizedBox(height: 6),

                        const Row(
                          children: [
                            Icon(Icons.description_outlined),
                            SizedBox(width: 5),
                            Text('فتح Data Sheet'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PRODUCT DATA SHEET PAGE
// ============================================================

class ProductDetailsPage extends StatelessWidget {
  final InverterProduct product;

  const ProductDetailsPage({
    super.key,
    required this.product,
  });

  Widget row(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 145,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final price = product.priceUsd == null
        ? 'غير متوفر'
        : '\$${f(product.priceUsd!, 0)} USD';

    return Scaffold(
      appBar: AppBar(
        title: Text(product.brand),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    const Icon(
                      Icons.solar_power,
                      size: 65,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.brand,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      product.model,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      price,
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            sectionTitle(
              'البيانات الأساسية',
              Icons.info_outline,
            ),

            Card(
              child: Column(
                children: [
                  row('الشركة', product.brand),
                  row('الموديل', product.model),
                  row('التصنيف', product.type),
                  row(
                    'القدرة',
                    '${f(product.powerKW, 0)} kW',
                  ),
                  row('الطور', product.phase),
                  row('البطارية', product.battery),
                  row(
                    'نطاق البطارية',
                    product.batteryRange,
                  ),
                ],
              ),
            ),

            sectionTitle(
              'PV / MPPT',
              Icons.solar_power,
            ),

            Card(
              child: Column(
                children: [
                  row('Max PV', product.maxPv),
                  row(
                    'Max PV Voltage',
                    product.maxPvVoltage,
                  ),
                  row(
                    'MPPT Range',
                    product.mpptRange,
                  ),
                  row('MPPT', product.mppt),
                  row(
                    'PV Current',
                    product.pvCurrent,
                  ),
                ],
              ),
            ),

            sectionTitle(
              'AC Output',
              Icons.power,
            ),

            Card(
              child: Column(
                children: [
                  row(
                    'AC Voltage',
                    product.acVoltage,
                  ),
                  row(
                    'Frequency',
                    product.acFrequency,
                  ),
                  row(
                    'Max Output Current',
                    product.maxOutputCurrent,
                  ),
                  row(
                    'Efficiency',
                    product.efficiency,
                  ),
                  row(
                    'Surge',
                    product.surge,
                  ),
                ],
              ),
            ),

            sectionTitle(
              'Communication & Protection',
              Icons.security,
            ),

            Card(
              child: Column(
                children: [
                  row(
                    'Communication',
                    product.communication,
                  ),
                  row(
                    'Protection',
                    product.protection,
                  ),
                ],
              ),
            ),

            sectionTitle(
              'البيانات الفيزيائية',
              Icons.straighten,
            ),

            Card(
              child: Column(
                children: [
                  row('Cooling', product.cooling),
                  row(
                    'Temperature',
                    product.temperature,
                  ),
                  row(
                    'Altitude',
                    product.altitude,
                  ),
                  row(
                    'Dimensions',
                    product.dimensions,
                  ),
                  row('Weight', product.weight),
                  row('IP Rating', product.ip),
                  row('Warranty', product.warranty),
                ],
              ),
            ),

            sectionTitle(
              'السعر',
              Icons.attach_money,
            ),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      price,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.priceNote,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            if (product.datasheetUrl.isNotEmpty)
              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.picture_as_pdf,
                    color: Colors.red,
                  ),
                  title: const Text(
                    'الداتا شيت الأصلية',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    product.datasheetUrl,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(
                    Icons.open_in_new,
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          'يمكن ربط هذا الزر بفتح الرابط الخارجي '
                          'باستخدام url_launcher.',
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 20),

            const Card(
              child: Padding(
                padding: EdgeInsets.all(14),
                child: Text(
                  'مهم: بيانات الداتا شيت تختلف حسب الموديل والإصدار. '
                  'أي قيمة مكتوب أمامها "حسب الموديل" لا ينبغي استخدامها '
                  'في التصميم النهائي قبل الرجوع إلى ملف الشركة المصنعة.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
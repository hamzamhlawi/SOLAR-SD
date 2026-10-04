import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// ===============================================================
/// Sudan SO
/// Solar Energy Calculator + Solar Market
/// API Connected Version
/// ===============================================================

const String apiBaseUrl = 'http://192.168.1.100:8000';
// مثال:
// const String apiBaseUrl = 'http://10.0.2.2:8000';

void main() {
  runApp(const SudanSOApp());
}

// ===============================================================
// APP
// ===============================================================

class SudanSOApp extends StatelessWidget {
  const SudanSOApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sudan SO',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF7F9F7),
        fontFamily: 'Arial',
      ),
      locale: const Locale('ar'),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const HomePage(),
    );
  }
}

// ===============================================================
// HELPERS
// ===============================================================

double parseNumber(String value) {
  String v = value.trim();

  const arabicNumbers = {
    '٠': '0',
    '١': '1',
    '٢': '2',
    '٣': '3',
    '٤': '4',
    '٥': '5',
    '٦': '6',
    '٧': '7',
    '٨': '8',
    '٩': '9',
  };

  arabicNumbers.forEach((key, val) {
    v = v.replaceAll(key, val);
  });

  v = v.replaceAll('٫', '.').replaceAll(',', '.');

  return double.tryParse(v) ?? 0;
}

String formatNumber(double value, {int decimals = 2}) {
  if (value.isNaN || value.isInfinite) return '0';

  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }

  return value.toStringAsFixed(decimals);
}

double standardInverterSize(double kw) {
  const sizes = [
    1.0,
    1.5,
    2.0,
    3.0,
    3.6,
    5.0,
    6.0,
    8.0,
    10.0,
    12.0,
    15.0,
    20.0,
    25.0,
    30.0,
  ];

  for (final size in sizes) {
    if (kw <= size) return size;
  }

  return (kw / 5).ceil() * 5;
}

// ===============================================================
// API PRODUCT MODEL
// ===============================================================

class Product {
  final int id;
  final String brand;
  final String category;
  final String model;
  final String specification;
  final double? price;
  final String source;
  final String note;
  final DateTime? checkedAt;
  final bool available;

  const Product({
    required this.id,
    required this.brand,
    required this.category,
    required this.model,
    required this.specification,
    required this.price,
    required this.source,
    required this.note,
    required this.checkedAt,
    required this.available,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final priceData =
        json['price'] is Map ? Map<String, dynamic>.from(json['price']) : null;

    final categoryRaw =
        json['category']?.toString().toLowerCase() ?? '';

    String category;

    switch (categoryRaw) {
      case 'inverter':
        category = 'إنفرترات';
        break;
      case 'battery':
        category = 'بطاريات';
        break;
      case 'panel':
        category = 'ألواح';
        break;
      default:
        category = json['category']?.toString() ?? 'أخرى';
    }

    final rawPrice = priceData?['price'];

    double? price;

    if (rawPrice is num) {
      price = rawPrice.toDouble();
    } else if (rawPrice != null) {
      price = double.tryParse(rawPrice.toString());
    }

    DateTime? checkedAt;

    final checked = priceData?['checked_at'];

    if (checked != null) {
      checkedAt = DateTime.tryParse(checked.toString());
    }

    String source = '';

    final sourceType = priceData?['source_type']?.toString() ?? '';

    switch (sourceType) {
      case 'official':
      case 'official_portal':
        source = 'المصدر الرسمي';
        break;
      case 'official_store':
        source = 'المتجر الرسمي';
        break;
      case 'authorized_distributor':
        source = 'موزع معتمد';
        break;
      case 'reference':
      case 'manual_reference':
        source = 'سعر مرجعي';
        break;
      default:
        source = priceData?['source_note']?.toString() ?? '';
    }

    return Product(
      id: (json['id'] as num?)?.toInt() ?? 0,
      brand: json['brand']?.toString() ?? '',
      category: category,
      model: json['model']?.toString() ?? '',
      specification: json['name']?.toString() ??
          json['specification']?.toString() ??
          '',
      price: price,
      source: source,
      note: priceData?['source_note']?.toString() ?? '',
      checkedAt: checkedAt,
      available: priceData?['available'] == true,
    );
  }
}

// ===============================================================
// API SERVICE
// ===============================================================

class PriceApiService {
  static Future<List<Product>> fetchProducts() async {
    final uri = Uri.parse('$apiBaseUrl/api/v1/products');

    final response = await http
        .get(
          uri,
          headers: {
            'Accept': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'API Error: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception('صيغة البيانات غير صحيحة');
    }

    return decoded
        .map(
          (item) => Product.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }
}

// ===============================================================
// HOME
// ===============================================================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;

  final pages = const [
    HomeDashboard(),
    CalculatorPage(),
    MarketPage(),
    AboutPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) {
          setState(() {
            index = value;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate),
            label: 'الحسابات',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'السوق',
          ),
          NavigationDestination(
            icon: Icon(Icons.info_outline),
            selectedIcon: Icon(Icons.info),
            label: 'عن التطبيق',
          ),
        ],
      ),
    );
  }
}

// ===============================================================
// HOME DASHBOARD
// ===============================================================

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sudan SO',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Colors.green.shade800,
                  Colors.green.shade500,
                ],
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.solar_power,
                  size: 55,
                  color: Colors.white,
                ),
                SizedBox(height: 15),
                Text(
                  'Sudan SO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'حلول الطاقة الشمسية في السودان',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _homeCard(
            context,
            icon: Icons.calculate,
            title: 'حاسبة الطاقة الشمسية',
            subtitle: 'احسب الألواح والبطاريات والإنفرتر',
            page: const CalculatorPage(),
          ),
          _homeCard(
            context,
            icon: Icons.battery_charging_full,
            title: 'حاسبة البطارية',
            subtitle: 'احسب السعة المطلوبة بالأمبير ساعة',
            page: const BatteryCalculatorPage(),
          ),
          _homeCard(
            context,
            icon: Icons.electric_bolt,
            title: 'حاسبة الإنفرتر',
            subtitle: 'حدد قدرة الإنفرتر المناسبة',
            page: const InverterCalculatorPage(),
          ),
          _homeCard(
            context,
            icon: Icons.solar_power_outlined,
            title: 'حاسبة الألواح',
            subtitle: 'احسب عدد الألواح المطلوبة',
            page: const PanelCalculatorPage(),
          ),
        ],
      ),
    );
  }

  Widget _homeCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget page,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: Colors.green.shade100,
          child: Icon(
            icon,
            color: Colors.green.shade800,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_back_ios_new),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => page),
          );
        },
      ),
    );
  }
}

// ===============================================================
// CALCULATOR PAGE
// ===============================================================

class CalculatorPage extends StatelessWidget {
  const CalculatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الحسابات'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _calcTile(
            context,
            Icons.home,
            'حساب النظام الكامل',
            'الأحمال + البطاريات + الألواح + الإنفرتر',
            const FullSystemCalculatorPage(),
          ),
          _calcTile(
            context,
            Icons.battery_full,
            'حاسبة البطارية',
            'حساب Ah و kWh',
            const BatteryCalculatorPage(),
          ),
          _calcTile(
            context,
            Icons.electric_bolt,
            'حاسبة الإنفرتر',
            'حساب قدرة الإنفرتر',
            const InverterCalculatorPage(),
          ),
          _calcTile(
            context,
            Icons.solar_power,
            'حاسبة الألواح',
            'حساب عدد الألواح',
            const PanelCalculatorPage(),
          ),
        ],
      ),
    );
  }

  Widget _calcTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Widget page,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.green.shade700),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_back_ios_new),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => page),
          );
        },
      ),
    );
  }
}

// ===============================================================
// APPLIANCE
// ===============================================================

class Appliance {
  final String id;
  final String name;
  final double watts;
  double quantity;
  double hours;

  Appliance({
    required this.id,
    required this.name,
    required this.watts,
    this.quantity = 0,
    this.hours = 0,
  });
}

List<Appliance> defaultAppliances() {
  return [
    Appliance(
      id: 'fridge',
      name: 'ثلاجة',
      watts: 150,
    ),
    Appliance(
      id: 'fan',
      name: 'مروحة',
      watts: 60,
    ),
    Appliance(
      id: 'nasma',
      name: 'مكيف نسمة',
      watts: 250,
    ),
    Appliance(
      id: 'split',
      name: 'مكيف اسبليت انفيرتر',
      watts: 1200,
    ),
    Appliance(
      id: 'oven',
      name: 'فرن',
      watts: 2000,
    ),
    Appliance(
      id: 'tv',
      name: 'شاشة',
      watts: 120,
    ),
    Appliance(
      id: 'receiver',
      name: 'رسيفر',
      watts: 15,
    ),
    Appliance(
      id: 'washing',
      name: 'غسالة',
      watts: 500,
    ),
    Appliance(
      id: 'lamp',
      name: 'لمبة أريام',
      watts: 10,
    ),
    Appliance(
      id: 'exhaust',
      name: 'مروحة شفاط',
      watts: 40,
    ),
    Appliance(
      id: 'phone',
      name: 'شاحن هاتف',
      watts: 10,
    ),
    Appliance(
      id: 'laptop',
      name: 'شاحن لابتوب',
      watts: 65,
    ),
  ];
}

// ===============================================================
// FULL SYSTEM CALCULATOR
// ===============================================================

class FullSystemCalculatorPage extends StatefulWidget {
  const FullSystemCalculatorPage({super.key});

  @override
  State<FullSystemCalculatorPage> createState() =>
      _FullSystemCalculatorPageState();
}

class _FullSystemCalculatorPageState
    extends State<FullSystemCalculatorPage> {
  final sunController = TextEditingController(text: '5.5');
  final pvPerformanceController = TextEditingController(text: '80');
  final voltageController = TextEditingController(text: '48');
  final dodController = TextEditingController(text: '80');
  final efficiencyController = TextEditingController(text: '92');
  final autonomyController = TextEditingController(text: '8');
  final panelController = TextEditingController(text: '550');
  final batteryController = TextEditingController(text: '5.12');
  final inverterMarginController = TextEditingController(text: '25');

  List<Appliance> appliances = defaultAppliances();

  double dailyEnergy = 0;
  double peakLoad = 0;
  double recommendedInverter = 0;
  double requiredPvKw = 0;
  int numberOfPanels = 0;
  double requiredBatteryKwh = 0;
  double requiredBatteryAh = 0;
  int batteryModules = 0;

  bool calculated = false;

  void calculate() {
    double energy = 0;
    double peak = 0;

    for (final item in appliances) {
      energy += item.watts * item.quantity * item.hours;
      peak += item.watts * item.quantity;
    }

    final sun = parseNumber(sunController.text);
    final pvPerformance =
        parseNumber(pvPerformanceController.text) / 100;
    final voltage = parseNumber(voltageController.text);
    final dod = parseNumber(dodController.text) / 100;
    final efficiency =
        parseNumber(efficiencyController.text) / 100;
    final autonomy = parseNumber(autonomyController.text);
    final panelW = parseNumber(panelController.text);
    final batteryKwh = parseNumber(batteryController.text);
    final margin =
        parseNumber(inverterMarginController.text) / 100;

    if (sun <= 0 ||
        pvPerformance <= 0 ||
        voltage <= 0 ||
        dod <= 0 ||
        efficiency <= 0 ||
        panelW <= 0 ||
        batteryKwh <= 0) {
      return;
    }

    final rawInverterKw = peak * (1 + margin) / 1000;

    final averageLoadW = energy / 24;

    final requiredBattery =
        (averageLoadW * autonomy) /
            (dod * efficiency) /
            1000;

    final batteryAh =
        requiredBattery * 1000 / voltage;

    final pvKw =
        energy /
            (sun * pvPerformance) /
            1000;

    final panels =
        (pvKw * 1000 / panelW).ceil();

    final modules =
        (requiredBattery / batteryKwh).ceil();

    setState(() {
      dailyEnergy = energy;
      peakLoad = peak;
      recommendedInverter =
          standardInverterSize(rawInverterKw);
      requiredPvKw = pvKw;
      numberOfPanels = panels;
      requiredBatteryKwh = requiredBattery;
      requiredBatteryAh = batteryAh;
      batteryModules = modules;
      calculated = true;
    });
  }

  @override
  void dispose() {
    sunController.dispose();
    pvPerformanceController.dispose();
    voltageController.dispose();
    dodController.dispose();
    efficiencyController.dispose();
    autonomyController.dispose();
    panelController.dispose();
    batteryController.dispose();
    inverterMarginController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حساب النظام الكامل'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'الأجهزة والأحمال',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ...appliances.map(
            (item) => ApplianceEditor(
              appliance: item,
              onChanged: () {
                setState(() {});
              },
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'إعدادات النظام',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          _numberField(
            sunController,
            'ساعات الشمس الفعالة',
            'ساعة',
          ),
          _numberField(
            pvPerformanceController,
            'كفاءة منظومة الألواح',
            '%',
          ),
          _numberField(
            voltageController,
            'جهد البطارية',
            'V',
          ),
          _numberField(
            dodController,
            'Depth of Discharge',
            '%',
          ),
          _numberField(
            efficiencyController,
            'كفاءة البطارية',
            '%',
          ),
          _numberField(
            autonomyController,
            'مدة الاحتياط',
            'ساعة',
          ),
          _numberField(
            panelController,
            'قدرة اللوح',
            'W',
          ),
          _numberField(
            batteryController,
            'حجم البطارية',
            'kWh',
          ),
          _numberField(
            inverterMarginController,
            'هامش أمان الإنفرتر',
            '%',
          ),
          const SizedBox(height: 15),
          FilledButton.icon(
            onPressed: calculate,
            icon: const Icon(Icons.calculate),
            label: const Text('احسب النظام'),
          ),
          if (calculated) ...[
            const SizedBox(height: 20),
            _resultCard(),
          ],
        ],
      ),
    );
  }

  Widget _numberField(
    TextEditingController controller,
    String label,
    String suffix,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
        ),
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _resultCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const Text(
              'نتيجة التصميم',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            _resultRow(
              'الاستهلاك اليومي',
              '${formatNumber(dailyEnergy / 1000)} kWh/day',
            ),
            _resultRow(
              'الحمل الأقصى',
              '${formatNumber(peakLoad / 1000)} kW',
            ),
            _resultRow(
              'الإنفرتر المقترح',
              '${formatNumber(recommendedInverter)} kW',
            ),
            _resultRow(
              'قدرة الألواح',
              '${formatNumber(requiredPvKw)} kWp',
            ),
            _resultRow(
              'عدد الألواح',
              '$numberOfPanels لوح',
            ),
            _resultRow(
              'البطارية المطلوبة',
              '${formatNumber(requiredBatteryKwh)} kWh',
            ),
            _resultRow(
              'سعة البطارية',
              '${formatNumber(requiredBatteryAh)} Ah',
            ),
            _resultRow(
              'عدد البطاريات',
              '$batteryModules بطارية',
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultRow(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.black12,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}

// ===============================================================
// APPLIANCE EDITOR
// ===============================================================

class ApplianceEditor extends StatefulWidget {
  final Appliance appliance;
  final VoidCallback onChanged;

  const ApplianceEditor({
    super.key,
    required this.appliance,
    required this.onChanged,
  });

  @override
  State<ApplianceEditor> createState() =>
      _ApplianceEditorState();
}

class _ApplianceEditorState extends State<ApplianceEditor> {
  late TextEditingController quantityController;
  late TextEditingController hoursController;

  @override
  void initState() {
    super.initState();

    quantityController = TextEditingController(
      text: widget.appliance.quantity == 0
          ? ''
          : formatNumber(widget.appliance.quantity),
    );

    hoursController = TextEditingController(
      text: widget.appliance.hours == 0
          ? ''
          : formatNumber(widget.appliance.hours),
    );
  }

  @override
  void dispose() {
    quantityController.dispose();
    hoursController.dispose();
    super.dispose();
  }

  void update() {
    widget.appliance.quantity =
        parseNumber(quantityController.text);

    widget.appliance.hours =
        parseNumber(hoursController.text);

    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 9),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.appliance.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Text(
                  '${formatNumber(widget.appliance.watts)} W',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: quantityController,
                    onChanged: (_) => update(),
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'العدد',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: hoursController,
                    onChanged: (_) => update(),
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'ساعات التشغيل/اليوم',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================================================
// BATTERY CALCULATOR
// ===============================================================

class BatteryCalculatorPage extends StatefulWidget {
  const BatteryCalculatorPage({super.key});

  @override
  State<BatteryCalculatorPage> createState() =>
      _BatteryCalculatorPageState();
}

class _BatteryCalculatorPageState
    extends State<BatteryCalculatorPage> {
  final loadController = TextEditingController();
  final hoursController = TextEditingController();
  final voltageController =
      TextEditingController(text: '48');
  final dodController =
      TextEditingController(text: '80');
  final efficiencyController =
      TextEditingController(text: '92');

  double? energy;
  double? requiredWh;
  double? requiredAh;
  double? requiredKwh;

  void calculate() {
    final load = parseNumber(loadController.text);
    final hours = parseNumber(hoursController.text);
    final voltage = parseNumber(voltageController.text);
    final dod =
        parseNumber(dodController.text) / 100;
    final efficiency =
        parseNumber(efficiencyController.text) / 100;

    if (load <= 0 ||
        hours <= 0 ||
        voltage <= 0 ||
        dod <= 0 ||
        efficiency <= 0) {
      return;
    }

    final wh = load * hours;
    final reqWh = wh / dod / efficiency;
    final ah = reqWh / voltage;

    setState(() {
      energy = wh;
      requiredWh = reqWh;
      requiredKwh = reqWh / 1000;
      requiredAh = ah;
    });
  }

  @override
  void dispose() {
    loadController.dispose();
    hoursController.dispose();
    voltageController.dispose();
    dodController.dispose();
    efficiencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حاسبة البطارية'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _field(
            loadController,
            'الحمل',
            'W',
          ),
          _field(
            hoursController,
            'عدد الساعات',
            'ساعة',
          ),
          _field(
            voltageController,
            'جهد البطارية',
            'V',
          ),
          _field(
            dodController,
            'DoD',
            '%',
          ),
          _field(
            efficiencyController,
            'كفاءة البطارية',
            '%',
          ),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: calculate,
            child: const Text('احسب'),
          ),
          if (requiredAh != null) ...[
            const SizedBox(height: 20),
            _resultBox(
              'الطاقة المطلوبة',
              '${formatNumber(energy! / 1000)} kWh',
            ),
            _resultBox(
              'السعة الاسمية المطلوبة',
              '${formatNumber(requiredKwh!)} kWh',
            ),
            _resultBox(
              'السعة المطلوبة',
              '${formatNumber(requiredAh!)} Ah',
            ),
          ],
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    String suffix,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType:
            const TextInputType.numberWithOptions(
          decimal: true,
        ),
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _resultBox(String title, String value) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ),
    );
  }
}

// ===============================================================
// INVERTER CALCULATOR
// ===============================================================

class InverterCalculatorPage extends StatefulWidget {
  const InverterCalculatorPage({super.key});

  @override
  State<InverterCalculatorPage> createState() =>
      _InverterCalculatorPageState();
}

class _InverterCalculatorPageState
    extends State<InverterCalculatorPage> {
  final loadController = TextEditingController();
  final marginController =
      TextEditingController(text: '25');

  double? result;

  void calculate() {
    final load = parseNumber(loadController.text);
    final margin =
        parseNumber(marginController.text) / 100;

    if (load <= 0) return;

    final kw = load / 1000;
    final required = kw * (1 + margin);

    setState(() {
      result = standardInverterSize(required);
    });
  }

  @override
  void dispose() {
    loadController.dispose();
    marginController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حاسبة الإنفرتر'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: loadController,
            keyboardType:
                const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: const InputDecoration(
              labelText: 'إجمالي الحمل',
              suffixText: 'W',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: marginController,
            keyboardType:
                const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: const InputDecoration(
              labelText: 'هامش الأمان',
              suffixText: '%',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 15),
          FilledButton(
            onPressed: calculate,
            child: const Text('احسب الإنفرتر'),
          ),
          if (result != null) ...[
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                title: const Text('الإنفرتر المقترح'),
                trailing: Text(
                  '${formatNumber(result!)} kW',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ===============================================================
// PANEL CALCULATOR
// ===============================================================

class PanelCalculatorPage extends StatefulWidget {
  const PanelCalculatorPage({super.key});

  @override
  State<PanelCalculatorPage> createState() =>
      _PanelCalculatorPageState();
}

class _PanelCalculatorPageState
    extends State<PanelCalculatorPage> {
  final energyController = TextEditingController();
  final sunController =
      TextEditingController(text: '5.5');
  final performanceController =
      TextEditingController(text: '80');
  final panelController =
      TextEditingController(text: '550');

  double? pvKw;
  int? panels;

  void calculate() {
    final energy =
        parseNumber(energyController.text) * 1000;
    final sun = parseNumber(sunController.text);
    final performance =
        parseNumber(performanceController.text) / 100;
    final panel =
        parseNumber(panelController.text);

    if (energy <= 0 ||
        sun <= 0 ||
        performance <= 0 ||
        panel <= 0) {
      return;
    }

    final kw =
        energy / (sun * performance) / 1000;

    final count =
        (kw * 1000 / panel).ceil();

    setState(() {
      pvKw = kw;
      panels = count;
    });
  }

  @override
  void dispose() {
    energyController.dispose();
    sunController.dispose();
    performanceController.dispose();
    panelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حاسبة الألواح'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _field(
            energyController,
            'الاستهلاك اليومي',
            'kWh/day',
          ),
          _field(
            sunController,
            'ساعات الشمس',
            'ساعة',
          ),
          _field(
            performanceController,
            'كفاءة النظام',
            '%',
          ),
          _field(
            panelController,
            'قدرة اللوح',
            'W',
          ),
          FilledButton(
            onPressed: calculate,
            child: const Text('احسب'),
          ),
          if (panels != null) ...[
            const SizedBox(height: 20),
            _resultBox(
              'قدرة الألواح',
              '${formatNumber(pvKw!)} kWp',
            ),
            _resultBox(
              'عدد الألواح',
              '$panels لوح',
            ),
          ],
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    String suffix,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType:
            const TextInputType.numberWithOptions(
          decimal: true,
        ),
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _resultBox(String title, String value) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ),
    );
  }
}

// ===============================================================
// MARKET PAGE - API CONNECTED
// ===============================================================

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  List<Product> products = [];

  bool loading = true;
  String? error;

  String selectedCategory = 'الكل';
  String search = '';

  DateTime? lastUpdated;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    if (!mounted) return;

    setState(() {
      loading = true;
      error = null;
    });

    try {
      final data =
          await PriceApiService.fetchProducts();

      DateTime? latest;

      for (final product in data) {
        if (product.checkedAt != null) {
          if (latest == null ||
              product.checkedAt!.isAfter(latest)) {
            latest = product.checkedAt;
          }
        }
      }

      if (!mounted) return;

      setState(() {
        products = data;
        lastUpdated = latest;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        error = 'تعذر الاتصال بالسيرفر';
      });
    }
  }

  List<Product> get filteredProducts {
    return products.where((product) {
      final categoryOk =
          selectedCategory == 'الكل' ||
              product.category == selectedCategory;

      final query =
          search.trim().toLowerCase();

      final searchOk =
          query.isEmpty ||
              product.brand
                  .toLowerCase()
                  .contains(query) ||
              product.model
                  .toLowerCase()
                  .contains(query) ||
              product.specification
                  .toLowerCase()
                  .contains(query);

      return categoryOk && searchOk;
    }).toList();
  }

  String formatDate(DateTime date) {
    final local = date.toLocal();

    return '${local.year}-${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'السوق الشمسي',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'تحديث الأسعار',
            onPressed: loading ? null : loadProducts,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadProducts,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (loading && products.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (error != null && products.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(30),
        children: [
          const SizedBox(height: 100),
          const Icon(
            Icons.cloud_off,
            size: 70,
            color: Colors.grey,
          ),
          const SizedBox(height: 15),
          Center(
            child: Text(
              error!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 15),
          FilledButton.icon(
            onPressed: loadProducts,
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      children: [
        _marketHeader(),
        const SizedBox(height: 12),
        TextField(
          onChanged: (value) {
            setState(() {
              search = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'ابحث عن شركة أو موديل...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _categoryChip('الكل'),
              _categoryChip('إنفرترات'),
              _categoryChip('بطاريات'),
              _categoryChip('ألواح'),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (error != null)
          Card(
            color: Colors.orange.shade50,
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'تعذر تحديث البيانات. يتم عرض آخر بيانات متوفرة.',
              ),
            ),
          ),
        if (filteredProducts.isEmpty)
          const Padding(
            padding: EdgeInsets.all(40),
            child: Center(
              child: Text(
                'لا توجد منتجات متاحة حالياً',
                style: TextStyle(fontSize: 17),
              ),
            ),
          ),
        ...filteredProducts.map(
          (product) => _productCard(product),
        ),
      ],
    );
  }

  Widget _marketHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.green.shade100,
              child: Icon(
                Icons.public,
                color: Colors.green.shade800,
                size: 30,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'أسعار السوق',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastUpdated == null
                        ? 'الأسعار من قاعدة البيانات'
                        : 'آخر تحديث: ${formatDate(lastUpdated!)}',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryChip(String category) {
    final selected =
        selectedCategory == category;

    return Padding(
      padding: const EdgeInsets.only(left: 7),
      child: FilterChip(
        selected: selected,
        label: Text(category),
        onSelected: (_) {
          setState(() {
            selectedCategory = category;
          });
        },
      ),
    );
  }

  Widget _productCard(Product product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      Colors.green.shade100,
                  child: Text(
                    product.brand.isNotEmpty
                        ? product.brand[0]
                        : '?',
                    style: TextStyle(
                      color: Colors.green.shade900,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    product.brand,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: Text(product.category),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              product.model,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (product.specification.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.only(top: 5),
                child: Text(
                  product.specification,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: product.price != null
                      ? Text(
                          '\$${formatNumber(product.price!)}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : const Text(
                          'السعر غير منشور',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                if (product.source.isNotEmpty)
                  Flexible(
                    child: Text(
                      product.source,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
              ],
            ),
            if (product.note.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                product.note,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ===============================================================
// ABOUT
// ===============================================================

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  void openWhatsApp() {
    // رقم التواصل:
    // +249 91 653 7047
    //
    // يمكن لاحقاً إضافة url_launcher لفتح واتساب مباشرة.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('عن Sudan SO'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: LinearGradient(
                colors: [
                  Colors.green.shade800,
                  Colors.green.shade500,
                ],
              ),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.solar_power,
                  color: Colors.white,
                  size: 70,
                ),
                SizedBox(height: 12),
                Text(
                  'Sudan SO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'حلول الطاقة الشمسية',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          const Text(
            'باشمهندس حمزة الطيب',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'خبرة واسعة في مجال الطاقة الشمسية',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 25),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'خدماتنا',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _service(
                    Icons.engineering,
                    'الاستشارات الهندسية',
                  ),
                  _service(
                    Icons.design_services,
                    'تصميم أنظمة الطاقة الشمسية',
                  ),
                  _service(
                    Icons.install_mobile,
                    'تركيب وتشغيل الأنظمة',
                  ),
                  _service(
                    Icons.calculate,
                    'حساب الأحمال والبطاريات والألواح',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.phone,
                color: Colors.green,
              ),
              title: const Text('واتساب'),
              subtitle: const Text(
                '+249 91 653 7047',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _service(
    IconData icon,
    String text,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.green,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
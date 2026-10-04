import 'package:flutter/material.dart';

/// ===============================================================
/// SUDAN SO
/// Solar Energy Calculator + Solar Brands Market
/// ===============================================================

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
            subtitle: 'احسب الأحمال والبطاريات والألواح والإنفرتر',
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

          const SizedBox(height: 8),

          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(14),
              leading: CircleAvatar(
                radius: 26,
                backgroundColor: Colors.green.shade100,
                child: Icon(
                  Icons.storefront,
                  color: Colors.green.shade800,
                ),
              ),
              title: const Text(
                'سوق البراندات',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text(
                'تصفح منتجات أشهر شركات الطاقة الشمسية',
              ),
              trailing: const Icon(
                Icons.arrow_back_ios_new,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MarketPage(),
                  ),
                );
              },
            ),
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
        trailing: const Icon(
          Icons.arrow_back_ios_new,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => page,
            ),
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
        leading: Icon(
          icon,
          color: Colors.green.shade700,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(
          Icons.arrow_back_ios_new,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => page,
            ),
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
  final sunController =
      TextEditingController(text: '5.5');

  final pvPerformanceController =
      TextEditingController(text: '80');

  final voltageController =
      TextEditingController(text: '48');

  final dodController =
      TextEditingController(text: '80');

  final efficiencyController =
      TextEditingController(text: '92');

  final autonomyController =
      TextEditingController(text: '8');

  final panelController =
      TextEditingController(text: '550');

  final batteryController =
      TextEditingController(text: '5.12');

  final inverterMarginController =
      TextEditingController(text: '25');

  final backupLoadController =
      TextEditingController(text: '0');

  List<Appliance> appliances =
      defaultAppliances();

  double dailyEnergy = 0;
  double peakLoad = 0;
  double averageLoad = 0;
  double backupLoad = 0;

  double recommendedInverter = 0;
  double inverterRequiredRaw = 0;

  double requiredPvKw = 0;
  int numberOfPanels = 0;

  double requiredBatteryKwh = 0;
  double requiredBatteryAh = 0;
  int batteryModules = 0;

  bool calculated = false;
  String? errorMessage;

  // =============================================================
  // CALCULATE
  // =============================================================

  void calculate() {
    double energy = 0;
    double peak = 0;

    for (final item in appliances) {
      final quantity =
          item.quantity < 0 ? 0 : item.quantity;

      final hours =
          item.hours < 0 ? 0 : item.hours;

      final validHours =
          hours > 24 ? 24 : hours;

      energy +=
          item.watts *
          quantity *
          validHours;

      peak +=
          item.watts *
          quantity;
    }

    final sun =
        parseNumber(sunController.text);

    final pvPerformance =
        parseNumber(
              pvPerformanceController.text,
            ) /
            100;

    final voltage =
        parseNumber(
          voltageController.text,
        );

    final dod =
        parseNumber(
              dodController.text,
            ) /
            100;

    final efficiency =
        parseNumber(
              efficiencyController.text,
            ) /
            100;

    final autonomy =
        parseNumber(
          autonomyController.text,
        );

    final panelW =
        parseNumber(
          panelController.text,
        );

    final batteryKwh =
        parseNumber(
          batteryController.text,
        );

    final margin =
        parseNumber(
              inverterMarginController.text,
            ) /
            100;

    final enteredBackupLoad =
        parseNumber(
          backupLoadController.text,
        );

    if (energy <= 0 || peak <= 0) {
      setState(() {
        errorMessage =
            'أدخل عدد الأجهزة وساعات التشغيل لجهاز واحد على الأقل.';
        calculated = false;
      });
      return;
    }

    if (sun <= 0 ||
        pvPerformance <= 0 ||
        pvPerformance > 1 ||
        voltage <= 0 ||
        dod <= 0 ||
        dod > 1 ||
        efficiency <= 0 ||
        efficiency > 1 ||
        autonomy <= 0 ||
        autonomy > 24 ||
        panelW <= 0 ||
        batteryKwh <= 0 ||
        margin < 0) {
      setState(() {
        errorMessage =
            'راجع إعدادات النظام. توجد قيمة غير صحيحة.';
        calculated = false;
      });
      return;
    }

    final calculatedAverageLoad =
        energy / 24;

    final calculatedBackupLoad =
        enteredBackupLoad > 0
            ? enteredBackupLoad
            : calculatedAverageLoad;

    final rawInverterKw =
        peak *
        (1 + margin) /
        1000;

    final selectedInverter =
        standardInverterSize(
          rawInverterKw,
        );

    final backupEnergyWh =
        calculatedBackupLoad *
        autonomy;

    final requiredBattery =
        backupEnergyWh /
        dod /
        efficiency /
        1000;

    final batteryAh =
        requiredBattery *
        1000 /
        voltage;

    final pvKw =
        energy /
        (sun * pvPerformance) /
        1000;

    final panels =
        (pvKw * 1000 / panelW).ceil();

    final modules =
        (requiredBattery /
                batteryKwh)
            .ceil();

    setState(() {
      errorMessage = null;

      dailyEnergy = energy;
      peakLoad = peak;
      averageLoad = calculatedAverageLoad;
      backupLoad = calculatedBackupLoad;

      inverterRequiredRaw = rawInverterKw;
      recommendedInverter = selectedInverter;

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
    backupLoadController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'حساب النظام الكامل',
        ),
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

          const SizedBox(height: 6),

          Text(
            'أدخل عدد كل جهاز وساعات تشغيله الفعلية في اليوم.',
            style: TextStyle(
              color: Colors.grey.shade700,
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
            'عمق التفريغ DoD',
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
            'حجم البطارية الواحدة',
            'kWh',
          ),

          _numberField(
            inverterMarginController,
            'هامش أمان الإنفرتر',
            '%',
          ),

          _numberField(
            backupLoadController,
            'حمل فترة الاحتياط',
            'W',
          ),

          Card(
            color: Colors.blue.shade50,
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'حمل فترة الاحتياط هو الحمل الذي تريد تشغيله أثناء الليل أو انقطاع الكهرباء. '
                      'مثال: إذا كان الحمل الليلي 800 W أدخل 800. '
                      'إذا تركته 0 سيستخدم التطبيق متوسط الحمل اليومي تلقائياً.',
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 15),

          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: calculate,
              icon: const Icon(
                Icons.calculate,
              ),
              label: const Text(
                'احسب النظام',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          if (errorMessage != null) ...[
            const SizedBox(height: 15),
            Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

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

  Widget _resultCard() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const Text(
              'نتيجة التصميم',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'الحسابات مبنية على البيانات التي أدخلتها',
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 15),

            _sectionTitle('الأحمال'),

            _resultRow(
              'الاستهلاك اليومي',
              '${formatNumber(dailyEnergy / 1000)} kWh/day',
            ),

            _resultRow(
              'متوسط الحمل',
              '${formatNumber(averageLoad / 1000)} kW',
            ),

            _resultRow(
              'الحمل الأقصى',
              '${formatNumber(peakLoad / 1000)} kW',
            ),

            _resultRow(
              'حمل فترة الاحتياط',
              '${formatNumber(backupLoad / 1000)} kW',
            ),

            const SizedBox(height: 10),

            _sectionTitle('الإنفرتر'),

            _resultRow(
              'القدرة المطلوبة قبل التقريب',
              '${formatNumber(inverterRequiredRaw)} kW',
            ),

            _resultRow(
              'الإنفرتر المقترح',
              '${formatNumber(recommendedInverter)} kW',
            ),

            const SizedBox(height: 10),

            _sectionTitle('الألواح الشمسية'),

            _resultRow(
              'قدرة الألواح المطلوبة',
              '${formatNumber(requiredPvKw)} kWp',
            ),

            _resultRow(
              'عدد الألواح',
              '$numberOfPanels لوح',
            ),

            const SizedBox(height: 10),

            _sectionTitle('البطاريات'),

            _resultRow(
              'الطاقة الاسمية المطلوبة',
              '${formatNumber(requiredBatteryKwh)} kWh',
            ),

            _resultRow(
              'السعة المطلوبة',
              '${formatNumber(requiredBatteryAh)} Ah',
            ),

            _resultRow(
              'عدد البطاريات',
              '$batteryModules بطارية',
            ),

            const SizedBox(height: 15),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: const Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'الحمل الأقصى يستخدم لتحديد الإنفرتر، '
                      'الاستهلاك اليومي يستخدم لتحديد الألواح، '
                      'وحمل فترة الاحتياط يستخدم لتحديد البطارية.',
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

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade800,
          ),
        ),
      ),
    );
  }

  Widget _resultRow(
    String title,
    String value,
  ) {
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
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(title),
          ),
          const SizedBox(width: 10),
          Text(
            value,
            textAlign: TextAlign.left,
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

class _ApplianceEditorState
    extends State<ApplianceEditor> {
  late TextEditingController quantityController;
  late TextEditingController hoursController;

  @override
  void initState() {
    super.initState();

    quantityController =
        TextEditingController(
      text:
          widget.appliance.quantity == 0
              ? ''
              : formatNumber(
                  widget.appliance.quantity,
                ),
    );

    hoursController =
        TextEditingController(
      text:
          widget.appliance.hours == 0
              ? ''
              : formatNumber(
                  widget.appliance.hours,
                ),
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
        parseNumber(
      quantityController.text,
    );

    widget.appliance.hours =
        parseNumber(
      hoursController.text,
    );

    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 9),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
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
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius:
                        BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${formatNumber(widget.appliance.watts)} W',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller:
                        quantityController,
                    onChanged: (_) => update(),
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration:
                        const InputDecoration(
                      labelText: 'العدد',
                      hintText: 'مثال: 2',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: TextField(
                    controller:
                        hoursController,
                    onChanged: (_) => update(),
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration:
                        const InputDecoration(
                      labelText:
                          'ساعات التشغيل/اليوم',
                      hintText: 'مثال: 8',
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

class BatteryCalculatorPage
    extends StatefulWidget {
  const BatteryCalculatorPage({
    super.key,
  });

  @override
  State<BatteryCalculatorPage> createState() =>
      _BatteryCalculatorPageState();
}

class _BatteryCalculatorPageState
    extends State<BatteryCalculatorPage> {
  final loadController =
      TextEditingController();

  final hoursController =
      TextEditingController();

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
    final load =
        parseNumber(loadController.text);

    final hours =
        parseNumber(hoursController.text);

    final voltage =
        parseNumber(
          voltageController.text,
        );

    final dod =
        parseNumber(
              dodController.text,
            ) /
            100;

    final efficiency =
        parseNumber(
              efficiencyController.text,
            ) /
            100;

    if (load <= 0 ||
        hours <= 0 ||
        voltage <= 0 ||
        dod <= 0 ||
        efficiency <= 0 ||
        dod > 1 ||
        efficiency > 1) {
      return;
    }

    final wh =
        load * hours;

    final reqWh =
        wh / dod / efficiency;

    final ah =
        reqWh / voltage;

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
        title: const Text(
          'حاسبة البطارية',
        ),
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
      padding: const EdgeInsets.only(
        bottom: 10,
      ),
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

  Widget _resultBox(
    String title,
    String value,
  ) {
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

class InverterCalculatorPage
    extends StatefulWidget {
  const InverterCalculatorPage({
    super.key,
  });

  @override
  State<InverterCalculatorPage> createState() =>
      _InverterCalculatorPageState();
}

class _InverterCalculatorPageState
    extends State<InverterCalculatorPage> {
  final loadController =
      TextEditingController();

  final marginController =
      TextEditingController(
    text: '25',
  );

  double? result;

  void calculate() {
    final load =
        parseNumber(
          loadController.text,
        );

    final margin =
        parseNumber(
              marginController.text,
            ) /
            100;

    if (load <= 0 ||
        margin < 0) {
      return;
    }

    final kw =
        load / 1000;

    final required =
        kw * (1 + margin);

    setState(() {
      result =
          standardInverterSize(
        required,
      );
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
        title:
            const Text('حاسبة الإنفرتر'),
      ),
      body: ListView(
        padding:
            const EdgeInsets.all(16),
        children: [
          TextField(
            controller:
                loadController,
            keyboardType:
                const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration:
                const InputDecoration(
              labelText:
                  'إجمالي الحمل الأقصى',
              suffixText: 'W',
              border:
                  OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 10),

          TextField(
            controller:
                marginController,
            keyboardType:
                const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration:
                const InputDecoration(
              labelText:
                  'هامش الأمان',
              suffixText: '%',
              border:
                  OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 15),

          FilledButton(
            onPressed: calculate,
            child: const Text(
              'احسب الإنفرتر',
            ),
          ),

          if (result != null) ...[
            const SizedBox(height: 20),

            Card(
              child: ListTile(
                title: const Text(
                  'الإنفرتر المقترح',
                ),
                trailing: Text(
                  '${formatNumber(result!)} kW',
                  style:
                      const TextStyle(
                    color: Colors.green,
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
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

class PanelCalculatorPage
    extends StatefulWidget {
  const PanelCalculatorPage({
    super.key,
  });

  @override
  State<PanelCalculatorPage> createState() =>
      _PanelCalculatorPageState();
}

class _PanelCalculatorPageState
    extends State<PanelCalculatorPage> {
  final energyController =
      TextEditingController();

  final sunController =
      TextEditingController(
    text: '5.5',
  );

  final performanceController =
      TextEditingController(
    text: '80',
  );

  final panelController =
      TextEditingController(
    text: '550',
  );

  double? pvKw;
  int? panels;

  void calculate() {
    final energy =
        parseNumber(
              energyController.text,
            ) *
            1000;

    final sun =
        parseNumber(
      sunController.text,
    );

    final performance =
        parseNumber(
              performanceController.text,
            ) /
            100;

    final panel =
        parseNumber(
      panelController.text,
    );

    if (energy <= 0 ||
        sun <= 0 ||
        performance <= 0 ||
        performance > 1 ||
        panel <= 0) {
      return;
    }

    final kw =
        energy /
        (sun * performance) /
        1000;

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
        title:
            const Text('حاسبة الألواح'),
      ),
      body: ListView(
        padding:
            const EdgeInsets.all(16),
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
            child:
                const Text('احسب'),
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
      padding:
          const EdgeInsets.only(
        bottom: 10,
      ),
      child: TextField(
        controller: controller,
        keyboardType:
            const TextInputType.numberWithOptions(
          decimal: true,
        ),
        decoration:
            InputDecoration(
          labelText: label,
          suffixText: suffix,
          border:
              const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _resultBox(
    String title,
    String value,
  ) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Text(
          value,
          style:
              const TextStyle(
            fontWeight:
                FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ),
    );
  }
}

// ===============================================================
// BRAND MODEL
// ===============================================================

class Brand {
  final String name;
  final String description;
  final IconData icon;
  final List<BrandProduct> products;

  const Brand({
    required this.name,
    required this.description,
    required this.icon,
    required this.products,
  });
}

// ===============================================================
// BRAND PRODUCT
// ===============================================================

class BrandProduct {
  final String name;
  final String category;
  final String specification;
  final String price;
  final String status;

  const BrandProduct({
    required this.name,
    required this.category,
    required this.specification,
    required this.price,
    required this.status,
  });
}

// ===============================================================
// BRANDS DATABASE
// ===============================================================

final List<Brand> brands = [
  Brand(
    name: 'Deye',
    description:
        'إنفرترات وبطاريات وحلول تخزين الطاقة الشمسية.',
    icon: Icons.bolt,
    products: [
      BrandProduct(
        name: 'Deye Hybrid Inverter 5kW',
        category: 'إنفرتر',
        specification:
            '5kW - Hybrid - 48V',
        price: 'السعر عند الطلب',
        status: 'متوفر',
      ),
      BrandProduct(
        name: 'Deye Hybrid Inverter 8kW',
        category: 'إنفرتر',
        specification:
            '8kW - Hybrid - Single Phase',
        price: 'السعر عند الطلب',
        status: 'متوفر',
      ),
      BrandProduct(
        name: 'Deye Hybrid Inverter 12kW',
        category: 'إنفرتر',
        specification:
            '12kW - Hybrid - 48V',
        price: 'السعر عند الطلب',
        status: 'متوفر',
      ),
      BrandProduct(
        name: 'Deye Lithium Battery',
        category: 'بطارية',
        specification:
            'LiFePO4 - High Voltage',
        price: 'السعر عند الطلب',
        status: 'متوفر',
      ),
    ],
  ),

  Brand(
    name: 'MUST',
    description:
        'حلول الإنفرترات والبطاريات وأنظمة الطاقة الشمسية.',
    icon: Icons.battery_charging_full,
    products: [
      BrandProduct(
        name: 'MUST Hybrid Inverter 3.6kW',
        category: 'إنفرتر',
        specification:
            '3.6kW - 48V',
        price: 'السعر عند الطلب',
        status: 'متوفر',
      ),
      BrandProduct(
        name: 'MUST Hybrid Inverter 5kW',
        category: 'إنفرتر',
        specification:
            '5kW - 48V',
        price: 'السعر عند الطلب',
        status: 'متوفر',
      ),
      BrandProduct(
        name: 'MUST Lithium Battery',
        category: 'بطارية',
        specification:
            'LiFePO4 - 5.12kWh',
        price: 'السعر عند الطلب',
        status: 'متوفر',
      ),
    ],
  ),

  Brand(
    name: 'Growatt',
    description:
        'إنفرترات هجينة وأجهزة تخزين وحلول الطاقة الشمسية.',
    icon: Icons.solar_power,
    products: [
      BrandProduct(
        name: 'Growatt SPF 5000 ES',
        category: 'إنفرتر',
        specification:
            '5kW - 48V',
        price: 'السعر عند الطلب',
        status: 'متوفر',
      ),
      BrandProduct(
        name: 'Growatt 6kW Hybrid',
        category: 'إنفرتر',
        specification:
            '6kW - Hybrid',
        price: 'السعر عند الطلب',
        status: 'متوفر',
      ),
      BrandProduct(
        name: 'Growatt Lithium Battery',
        category: 'بطارية',
        specification:
            'LiFePO4',
        price: 'السعر عند الطلب',
        status: 'متوفر',
      ),
    ],
  ),

  Brand(
    name: 'Voltronic',
    description:
        'إنفرترات وحلول الطاقة الشمسية وأنظمة UPS.',
    icon: Icons.electrical_services,
    products: [
      BrandProduct(
        name: 'Voltronic Axpert 5kW',
        category: 'إنفرتر',
        specification:
            '5kW - 48V',
        price: 'السعر عند الطلب',
        status: 'متوفر',
      ),
      BrandProduct(
        name: 'Voltronic Axpert 6kW',
        category: 'إنفرتر',
        specification:
            '6kW - 48V',
        price: 'السعر عند الطلب',
        status: 'متوفر',
      ),
    ],
  ),

  Brand(
    name: 'Felicity Solar',
    description:
        'إنفرترات وبطاريات وأنظمة تخزين الطاقة.',
    icon: Icons.battery_full,
    products: [
      BrandProduct(
        name: 'Felicity Solar 5kW',
        category: 'إنفرتر',
        specification:
            '5kW - 48V',
        price: 'السعر عند الطلب',
        status: 'متوفر',
      ),
      BrandProduct(
        name: 'Felicity Solar Battery',
        category: 'بطارية',
        specification:
            'LiFePO4 - 5kWh',
        price: 'السعر عند الطلب',
        status: 'متوفر',
      ),
    ],
  ),

  Brand(
    name: 'Jinko Solar',
    description:
        'ألواح شمسية عالية الكفاءة للاستخدامات المنزلية والتجارية.',
    icon: Icons.grid_view,
    products: [
      BrandProduct(
        name: 'Jinko Solar 550W',
        category: 'لوح شمسي',
        specification:
            '550W - Mono - High Efficiency',
        price: 'السعر عند الطلب',
        status: 'متوفر',
      ),
      BrandProduct(
        name: 'Jinko Solar 580W',
        category: 'لوح شمسي',
        specification:
            '580W - Mono',
        price: 'السعر عند الطلب',
        status: 'متوفر',
      ),
      BrandProduct(
        name: 'Jinko Solar 600W',
        category: 'لوح شمسي',
        specification:
            '600W - Mono',
        price: 'السعر عند الطلب',
        status: 'متوفر',
      ),
    ],
  ),

  Brand(
    name: 'LONGi',
    description:
        'ألواح شمسية عالية الكفاءة وتقنيات الطاقة الشمسية الحديثة.',
    icon: Icons.view_module,
    products: [
      BrandProduct(
        name: 'LONGi Solar 550W',
        category: 'لوح شمسي',
        specification:
            '550W - Mono',
        price: 'السعر عند الطلب',
        status: 'متوفر',
      ),
      BrandProduct(
        name: 'LONGi Solar 580W',
        category: 'لوح شمسي',
        specification:
            '580W - High Efficiency',
        price: 'السعر عند الطلب',
        status: 'متوفر',
      ),
      BrandProduct(
        name: 'LONGi Solar 600W',
        category: 'لوح شمسي',
        specification:
            '600W - Mono',
        price: 'السعر عند الطلب',
        status: 'متوفر',
      ),
    ],
  ),

  Brand(
    name: 'Huawei',
    description:
        'حلول الطاقة الشمسية والإنفرترات الذكية وأنظمة التخزين.',
    icon: Icons.memory,
    products: [
      BrandProduct(
        name: 'Huawei SUN2000',
        category: 'إنفرتر',
        specification:
            'Hybrid Solar Inverter',
        price: 'السعر عند الطلب',
        status: 'متوفر',
      ),
      BrandProduct(
        name: 'Huawei LUNA Battery',
        category: 'بطارية',
        specification:
            'Smart Lithium Battery',
        price: 'السعر عند الطلب',
        status: 'متوفر',
      ),
    ],
  ),

  Brand(
    name: 'Solis',
    description:
        'إنفرترات الطاقة الشمسية وأنظمة التخزين.',
    icon: Icons.energy_savings_leaf,
    products: [
      BrandProduct(
        name: 'Solis Hybrid 5kW',
        category: 'إنفرتر',
        specification:
            '5kW - Hybrid',
        price: 'السعر عند الطلب',
        status: 'متوفر',
      ),
      BrandProduct(
        name: 'Solis Hybrid 10kW',
        category: 'إنفرتر',
        specification:
            '10kW - Hybrid',
        price: 'السعر عند الطلب',
        status: 'متوفر',
      ),
    ],
  ),

  Brand(
    name: 'SRNE',
    description:
        'إنفرترات ومنظمات شحن وحلول الطاقة الشمسية.',
    icon: Icons.settings_input_component,
    products: [
      BrandProduct(
        name: 'SRNE Hybrid Inverter',
        category: 'إنفرتر',
        specification:
            'Hybrid - 48V',
        price: 'السعر عند الطلب',
        status: 'متوفر',
      ),
      BrandProduct(
        name: 'SRNE MPPT',
        category: 'منظم شحن',
        specification:
            'MPPT Solar Charge Controller',
        price: 'السعر عند الطلب',
        status: 'متوفر',
      ),
    ],
  ),
];

// ===============================================================
// MARKET PAGE - BRANDS
// ===============================================================

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() =>
      _MarketPageState();
}

class _MarketPageState
    extends State<MarketPage> {
  String search = '';

  List<Brand> get filteredBrands {
    final query =
        search.trim().toLowerCase();

    if (query.isEmpty) {
      return brands;
    }

    return brands.where((brand) {
      return brand.name
              .toLowerCase()
              .contains(query) ||
          brand.description
              .toLowerCase()
              .contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'سوق البراندات',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          _marketHeader(),

          const SizedBox(height: 14),

          TextField(
            onChanged: (value) {
              setState(() {
                search = value;
              });
            },
            decoration: InputDecoration(
              hintText:
                  'ابحث عن البراند...',
              prefixIcon:
                  const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(15),
              ),
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'البراندات',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          ...filteredBrands.map(
            (brand) =>
                _brandCard(brand),
          ),

          if (filteredBrands.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                child: Text(
                  'لا يوجد براند بهذا الاسم',
                  style: TextStyle(
                    fontSize: 17,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _marketHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Colors.green.shade800,
            Colors.green.shade500,
          ],
        ),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.storefront,
              size: 34,
              color: Colors.green,
            ),
          ),

          SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'سوق البراندات',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'اختر البراند لعرض منتجاته وصفحة البيع',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _brandCard(Brand brand) {
    return Card(
      elevation: 1,
      margin:
          const EdgeInsets.only(bottom: 11),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  BrandPage(brand: brand),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius:
                      BorderRadius.circular(16),
                  border: Border.all(
                    color:
                        Colors.green.shade100,
                  ),
                ),
                child: Icon(
                  brand.icon,
                  size: 32,
                  color:
                      Colors.green.shade800,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      brand.name,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      brand.description,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        color:
                            Colors.grey.shade700,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Text(
                      '${brand.products.length} منتجات',
                      style: TextStyle(
                        color:
                            Colors.green.shade700,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              const Icon(
                Icons.arrow_back_ios_new,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===============================================================
// BRAND PAGE
// ===============================================================

class BrandPage extends StatelessWidget {
  final Brand brand;

  const BrandPage({
    super.key,
    required this.brand,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          brand.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          _brandHeader(),

          const SizedBox(height: 18),

          const Text(
            'منتجات البراند',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          ...brand.products.map(
            (product) =>
                _productCard(
              context,
              product,
            ),
          ),

          const SizedBox(height: 10),

          _sellerCard(context),
        ],
      ),
    );
  }

  Widget _brandHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Colors.green.shade900,
            Colors.green.shade600,
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(22),
            ),
            child: Icon(
              brand.icon,
              size: 48,
              color: Colors.green.shade800,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            brand.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            brand.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _productCard(
    BuildContext context,
    BrandProduct product,
  ) {
    return Card(
      margin:
          const EdgeInsets.only(bottom: 11),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color:
                        Colors.green.shade50,
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _categoryIcon(
                      product.category,
                    ),
                    color:
                        Colors.green.shade800,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style:
                            const TextStyle(
                          fontSize: 17,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        product.category,
                        style: TextStyle(
                          color:
                              Colors.green.shade700,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius:
                    BorderRadius.circular(10),
              ),
              child: Text(
                product.specification,
                style: TextStyle(
                  color:
                      Colors.grey.shade800,
                ),
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.price,
                        style:
                            const TextStyle(
                          color: Colors.green,
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Row(
                        children: [
                          const Icon(
                            Icons.circle,
                            size: 9,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            product.status,
                            style: TextStyle(
                              color: Colors
                                  .grey.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                FilledButton.icon(
                  onPressed: () {
                    _showOrderDialog(
                      context,
                      product,
                    );
                  },
                  icon: const Icon(
                    Icons.shopping_cart,
                  ),
                  label:
                      const Text('طلب'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _categoryIcon(
    String category,
  ) {
    if (category.contains('بطارية')) {
      return Icons.battery_full;
    }

    if (category.contains('لوح')) {
      return Icons.solar_power;
    }

    if (category.contains('منظم')) {
      return Icons.settings_input_component;
    }

    return Icons.electric_bolt;
  }

  Widget _sellerCard(
    BuildContext context,
  ) {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(
              Icons.storefront,
              size: 42,
              color: Colors.green,
            ),

            const SizedBox(height: 8),

            const Text(
              'هل تريد شراء هذا البراند؟',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'تواصل مع Sudan SO لمعرفة السعر والتوفر ومعلومات الطلب.',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            FilledButton.icon(
              onPressed: () {
                _showContactDialog(context);
              },
              icon: const Icon(
                Icons.phone,
              ),
              label: const Text(
                'تواصل معنا',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderDialog(
    BuildContext context,
    BrandProduct product,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'طلب المنتج',
          ),
          content: Text(
            'المنتج:\n'
            '${product.name}\n\n'
            'البراند:\n'
            '${brand.name}\n\n'
            'للطلب ومعرفة السعر والتوفر:\n'
            '+249 91 653 7047',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child:
                  const Text('إغلاق'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                _showContactDialog(context);
              },
              child:
                  const Text('تواصل'),
            ),
          ],
        );
      },
    );
  }

  void _showContactDialog(
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'التواصل والطلب',
          ),
          content: const Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Icon(
                Icons.contact_phone,
                size: 50,
                color: Colors.green,
              ),
              SizedBox(height: 12),
              Text(
                'Sudan SO',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'واتساب / هاتف',
                textAlign:
                    TextAlign.center,
              ),
              SizedBox(height: 5),
              Text(
                '+249 91 653 7047',
                style: TextStyle(
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child:
                  const Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }
}

// ===============================================================
// ABOUT
// ===============================================================

class AboutPage
    extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('عن Sudan SO'),
      ),
      body: ListView(
        padding:
            const EdgeInsets.all(20),
        children: [
          Container(
            padding:
                const EdgeInsets.all(25),
            decoration:
                BoxDecoration(
              borderRadius:
                  BorderRadius.circular(25),
              gradient:
                  LinearGradient(
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
                  style:
                      TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  'حلول الطاقة الشمسية',
                  style:
                      TextStyle(
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
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              fontSize: 24,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'خبرة واسعة في مجال الطاقة الشمسية',
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              fontSize: 17,
            ),
          ),

          const SizedBox(height: 25),

          Card(
            child: Padding(
              padding:
                  const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'خدماتنا',
                    style:
                        TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
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

                  _service(
                    Icons.storefront,
                    'سوق براندات الطاقة الشمسية',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Card(
            child: ListTile(
              leading:
                  const Icon(
                Icons.phone,
                color: Colors.green,
              ),
              title:
                  const Text(
                'واتساب',
              ),
              subtitle:
                  const Text(
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
      padding:
          const EdgeInsets.only(
        bottom: 12,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.green,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }
}
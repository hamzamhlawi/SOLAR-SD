import 'package:flutter/material.dart';

void main() {
  runApp(const SudanSOApp());
}

// ============================================================
// SUDAN SO
// Solar Energy Calculator & Global Solar Market
// ============================================================

class SudanSOApp extends StatelessWidget {
  const SudanSOApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sudan SO',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0B8F63),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F7F6),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: MainScreen(),
      ),
    );
  }
}

// ============================================================
// MAIN SCREEN
// ============================================================

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    HomePage(),
    CalculatorPage(),
    MarketPage(),
    AboutPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
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
            label: 'الحاسبة',
          ),
          NavigationDestination(
            icon: Icon(Icons.store_outlined),
            selectedIcon: Icon(Icons.store),
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

// ============================================================
// HOME PAGE
// ============================================================

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 25, 20, 10),
              child: Column(
                children: [
                  const Icon(
                    Icons.wb_sunny,
                    size: 55,
                    color: Color(0xFFF5A623),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Sudan SO',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF087F5B),
                    ),
                  ),
                  const Text(
                    'حلول أذكى للطاقة الشمسية',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // QUICK CALCULATOR
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _mainCalculatorCard(context),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.15,
              children: [
                HomeTile(
                  icon: Icons.battery_charging_full,
                  title: 'البطاريات',
                  subtitle: 'حساب السعة',
                  color: const Color(0xFF1877F2),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BatteryCalculator(),
                      ),
                    );
                  },
                ),
                HomeTile(
                  icon: Icons.bolt,
                  title: 'الإنفرتر',
                  subtitle: 'اختيار القدرة',
                  color: const Color(0xFFFFA000),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const InverterCalculator(),
                      ),
                    );
                  },
                ),
                HomeTile(
                  icon: Icons.solar_power,
                  title: 'الألواح',
                  subtitle: 'عدد وتوصيل الألواح',
                  color: const Color(0xFF0B8F63),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PanelCalculator(),
                      ),
                    );
                  },
                ),
                HomeTile(
                  icon: Icons.electrical_services,
                  title: 'الأحمال',
                  subtitle: 'حساب الاستهلاك',
                  color: const Color(0xFF7B61FF),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoadCalculator(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _sectionTitle('السوق العالمي'),

                  const SizedBox(height: 10),

                  _marketBanner(
                    context,
                    icon: Icons.store,
                    title: 'سوق الطاقة الشمسية',
                    subtitle:
                        'إنفرترات • بطاريات • ألواح • أسعار بالدولار',
                  ),

                  const SizedBox(height: 15),

                  _sectionTitle('الشركات المدعومة'),

                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _brand('DEYE'),
                      _brand('MOTOMA'),
                      _brand('FELICITY'),
                      _brand('GSB'),
                      _brand('MUST'),
                      _brand('GROWATT'),
                      _brand('LONGi'),
                      _brand('JINKO'),
                      _brand('TRINA'),
                    ],
                  ),

                  const SizedBox(height: 25),

                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(18),
                      child: Column(
                        children: [
                          Icon(
                            Icons.engineering,
                            size: 42,
                            color: Color(0xFF087F5B),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'باشمهندس حمزة الطيب',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'خبرة واسعة في مجال الطاقة الشمسية والاستشارات الهندسية والتركيب',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mainCalculatorCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF087F5B),
            Color(0xFF0B6E4F),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.solar_power,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 8),
          const Text(
            'حاسبة النظام الشمسي',
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'احسب الأحمال والألواح والبطاريات والإنفرتر',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF087F5B),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SolarSystemCalculator(),
                  ),
                );
              },
              child: const Text(
                'ابدأ الحساب',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _marketBanner(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: const CircleAvatar(
          radius: 28,
          backgroundColor: Color(0xFFE1F4ED),
          child: Icon(
            Icons.store,
            color: Color(0xFF087F5B),
            size: 28,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_back_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const MarketPage(),
            ),
          );
        },
      ),
    );
  }

  Widget _brand(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE0E5E3),
        ),
      ),
      child: Text(
        name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}

// ============================================================
// HOME TILE
// ============================================================

class HomeTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const HomeTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 38,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// CALCULATOR MAIN
// ============================================================

class CalculatorPage extends StatelessWidget {
  const CalculatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حاسبات الطاقة الشمسية'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _calcCard(
            context,
            Icons.solar_power,
            'حاسبة النظام الكامل',
            'الأحمال + الألواح + البطاريات + الإنفرتر',
            const SolarSystemCalculator(),
          ),
          _calcCard(
            context,
            Icons.battery_full,
            'حاسبة البطاريات',
            'حساب kWh و Ah ومدة التشغيل',
            const BatteryCalculator(),
          ),
          _calcCard(
            context,
            Icons.bolt,
            'حاسبة الإنفرتر',
            'اختيار قدرة الإنفرتر المناسبة',
            const InverterCalculator(),
          ),
          _calcCard(
            context,
            Icons.solar_power,
            'حاسبة الألواح',
            'عدد الألواح وقدرة النظام',
            const PanelCalculator(),
          ),
          _calcCard(
            context,
            Icons.electrical_services,
            'حاسبة الأحمال',
            'حساب استهلاك الأجهزة اليومي',
            const LoadCalculator(),
          ),
        ],
      ),
    );
  }

  Widget _calcCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Widget page,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(
          radius: 27,
          backgroundColor: const Color(0xFFE1F4ED),
          child: Icon(
            icon,
            color: const Color(0xFF087F5B),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_back_ios, size: 17),
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

// ============================================================
// FULL SYSTEM CALCULATOR
// ============================================================

class SolarSystemCalculator extends StatefulWidget {
  const SolarSystemCalculator({super.key});

  @override
  State<SolarSystemCalculator> createState() =>
      _SolarSystemCalculatorState();
}

class _SolarSystemCalculatorState
    extends State<SolarSystemCalculator> {
  final loadController = TextEditingController();
  final hoursController = TextEditingController(text: '8');
  final sunController = TextEditingController(text: '5');
  final panelController = TextEditingController(text: '550');
  final batteryController = TextEditingController(text: '10');

  String voltage = '48V';

  double dailyEnergy = 0;
  double pvPower = 0;
  int panels = 0;
  double battery = 0;
  double inverter = 0;

  void calculate() {
    final load = double.tryParse(loadController.text) ?? 0;
    final hours = double.tryParse(hoursController.text) ?? 0;
    final sun = double.tryParse(sunController.text) ?? 0;
    final panel = double.tryParse(panelController.text) ?? 0;

    if (load <= 0 || hours <= 0 || sun <= 0 || panel <= 0) {
      return;
    }

    final energy = load * hours;
    final pv = energy / (sun * 0.8);
    final count = (pv * 1000 / panel).ceil();

    final batteryKwh = energy * 0.5 / 0.8;
    final inverterW = load * 1.5;

    setState(() {
      dailyEnergy = energy;
      pvPower = pv;
      panels = count;
      battery = batteryKwh;
      inverter = inverterW / 1000;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حاسبة النظام الكامل'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _input(
            loadController,
            'متوسط الحمل W',
            Icons.power,
          ),
          _input(
            hoursController,
            'ساعات التشغيل يومياً',
            Icons.schedule,
          ),
          _input(
            sunController,
            'Peak Sun Hours',
            Icons.wb_sunny,
          ),
          _input(
            panelController,
            'قدرة اللوح W',
            Icons.solar_power,
          ),

          DropdownButtonFormField<String>(
            value: voltage,
            decoration: _decoration(
              'جهد النظام',
              Icons.battery_charging_full,
            ),
            items: const [
              DropdownMenuItem(
                value: '12V',
                child: Text('12V'),
              ),
              DropdownMenuItem(
                value: '24V',
                child: Text('24V'),
              ),
              DropdownMenuItem(
                value: '48V',
                child: Text('48V'),
              ),
              DropdownMenuItem(
                value: 'HV',
                child: Text('High Voltage'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                voltage = value!;
              });
            },
          ),

          const SizedBox(height: 15),

          FilledButton.icon(
            onPressed: calculate,
            icon: const Icon(Icons.calculate),
            label: const Text('احسب النظام'),
          ),

          const SizedBox(height: 20),

          ResultBox(
            title: 'الاستهلاك اليومي',
            value: '${dailyEnergy.toStringAsFixed(1)} Wh',
          ),
          ResultBox(
            title: 'قدرة الألواح المطلوبة',
            value: '${pvPower.toStringAsFixed(2)} kWp',
          ),
          ResultBox(
            title: 'عدد الألواح',
            value: '$panels لوح',
          ),
          ResultBox(
            title: 'البطارية المقترحة',
            value: '${battery.toStringAsFixed(2)} kWh',
          ),
          ResultBox(
            title: 'الإنفرتر المقترح',
            value: '${inverter.toStringAsFixed(2)} kW',
          ),
          ResultBox(
            title: 'جهد النظام',
            value: voltage,
          ),

          const SizedBox(height: 10),

          const Card(
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Text(
                'ملاحظة: هذه نتائج تقديرية أولية. يجب مراجعة مواصفات الإنفرتر والبطارية والألواح الفعلية قبل التنفيذ.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.orange,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// BATTERY CALCULATOR
// ============================================================

class BatteryCalculator extends StatefulWidget {
  const BatteryCalculator({super.key});

  @override
  State<BatteryCalculator> createState() =>
      _BatteryCalculatorState();
}

class _BatteryCalculatorState
    extends State<BatteryCalculator> {
  final load = TextEditingController();
  final hours = TextEditingController();
  final voltage = TextEditingController(text: '48');
  final dod = TextEditingController(text: '80');

  double kwh = 0;
  double ah = 0;

  void calculate() {
    final l = double.tryParse(load.text) ?? 0;
    final h = double.tryParse(hours.text) ?? 0;
    final v = double.tryParse(voltage.text) ?? 48;
    final d = (double.tryParse(dod.text) ?? 80) / 100;

    if (l <= 0 || h <= 0 || v <= 0 || d <= 0) return;

    final energy = l * h;
    final required = energy / d;
    final capacity = required * 1000 / v;

    setState(() {
      kwh = required / 1000;
      ah = capacity;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حاسبة البطاريات'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _input(load, 'الحمل W', Icons.power),
          _input(hours, 'ساعات التشغيل', Icons.schedule),
          _input(voltage, 'جهد البطارية V', Icons.battery_std),
          _input(dod, 'DoD %', Icons.percent),

          FilledButton(
            onPressed: calculate,
            child: const Text('احسب'),
          ),

          const SizedBox(height: 20),

          ResultBox(
            title: 'الطاقة المطلوبة',
            value: '${kwh.toStringAsFixed(2)} kWh',
          ),

          ResultBox(
            title: 'السعة المطلوبة',
            value: '${ah.toStringAsFixed(0)} Ah',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// INVERTER CALCULATOR
// ============================================================

class InverterCalculator extends StatefulWidget {
  const InverterCalculator({super.key});

  @override
  State<InverterCalculator> createState() =>
      _InverterCalculatorState();
}

class _InverterCalculatorState
    extends State<InverterCalculator> {
  final load = TextEditingController();
  final surge = TextEditingController(text: '1.5');

  double result = 0;

  void calculate() {
    final l = double.tryParse(load.text) ?? 0;
    final s = double.tryParse(surge.text) ?? 1.5;

    setState(() {
      result = l * s;
    });
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
          _input(load, 'الحمل الكلي W', Icons.power),
          _input(surge, 'معامل Surge', Icons.flash_on),

          FilledButton(
            onPressed: calculate,
            child: const Text('احسب'),
          ),

          const SizedBox(height: 20),

          ResultBox(
            title: 'القدرة المطلوبة',
            value: '${result.toStringAsFixed(0)} W',
          ),

          ResultBox(
            title: 'الإنفرتر المقترح',
            value: '${(result / 1000).toStringAsFixed(2)} kW',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PANEL CALCULATOR
// ============================================================

class PanelCalculator extends StatefulWidget {
  const PanelCalculator({super.key});

  @override
  State<PanelCalculator> createState() =>
      _PanelCalculatorState();
}

class _PanelCalculatorState
    extends State<PanelCalculator> {
  final requiredPower = TextEditingController();
  final panelPower = TextEditingController(text: '550');

  int panels = 0;
  double total = 0;

  void calculate() {
    final power =
        double.tryParse(requiredPower.text) ?? 0;
    final panel =
        double.tryParse(panelPower.text) ?? 0;

    if (power <= 0 || panel <= 0) return;

    setState(() {
      panels = (power * 1000 / panel).ceil();
      total = panels * panel / 1000;
    });
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
          _input(
            requiredPower,
            'قدرة النظام المطلوبة kW',
            Icons.bolt,
          ),
          _input(
            panelPower,
            'قدرة اللوح W',
            Icons.solar_power,
          ),

          FilledButton(
            onPressed: calculate,
            child: const Text('احسب'),
          ),

          const SizedBox(height: 20),

          ResultBox(
            title: 'عدد الألواح',
            value: '$panels لوح',
          ),

          ResultBox(
            title: 'إجمالي القدرة',
            value: '${total.toStringAsFixed(2)} kWp',
          ),

          const SizedBox(height: 10),

          const Text(
            'ملاحظة: حساب Series / Parallel يحتاج مواصفات Voc و Vmp و Isc و Imp للوح وحدود MPPT للإنفرتر.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.orange),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// LOAD CALCULATOR
// ============================================================

class LoadCalculator extends StatefulWidget {
  const LoadCalculator({super.key});

  @override
  State<LoadCalculator> createState() =>
      _LoadCalculatorState();
}

class _LoadCalculatorState
    extends State<LoadCalculator> {
  final power = TextEditingController();
  final quantity = TextEditingController(text: '1');
  final hours = TextEditingController();

  double daily = 0;

  void calculate() {
    final p = double.tryParse(power.text) ?? 0;
    final q = double.tryParse(quantity.text) ?? 1;
    final h = double.tryParse(hours.text) ?? 0;

    setState(() {
      daily = p * q * h;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حاسبة الأحمال'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _input(power, 'قدرة الجهاز W', Icons.power),
          _input(quantity, 'عدد الأجهزة', Icons.numbers),
          _input(hours, 'ساعات التشغيل يومياً', Icons.schedule),

          FilledButton(
            onPressed: calculate,
            child: const Text('أضف الحمل'),
          ),

          const SizedBox(height: 20),

          ResultBox(
            title: 'الاستهلاك اليومي',
            value: '${daily.toStringAsFixed(0)} Wh',
          ),

          ResultBox(
            title: 'بالكيلوواط ساعة',
            value: '${(daily / 1000).toStringAsFixed(2)} kWh',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// MARKET
// ============================================================

class Product {
  final String brand;
  final String category;
  final String model;
  final String specification;
  final double price;

  const Product({
    required this.brand,
    required this.category,
    required this.model,
    required this.specification,
    required this.price,
  });
}

// الأسعار = 0 في النسخة الأولية حتى لا نضع أسعاراً وهمية.
// سيتم ربطها لاحقاً بمصدر أسعار حقيقي.

const List<Product> products = [
  // INVERTERS
  Product(
    brand: 'Deye',
    category: 'إنفرترات',
    model: 'Deye',
    specification: 'Hybrid / On-Grid / Off-Grid',
    price: 0,
  ),
  Product(
    brand: 'Motoma',
    category: 'إنفرترات',
    model: 'Motoma',
    specification: 'Solar Inverter',
    price: 0,
  ),
  Product(
    brand: 'Felicity',
    category: 'إنفرترات',
    model: 'Felicity Solar',
    specification: 'Solar Inverter',
    price: 0,
  ),
  Product(
    brand: 'GSB',
    category: 'إنفرترات',
    model: 'GSB',
    specification: 'Solar Inverter',
    price: 0,
  ),
  Product(
    brand: 'MUST',
    category: 'إنفرترات',
    model: 'MUST',
    specification: 'Hybrid Inverter',
    price: 0,
  ),
  Product(
    brand: 'Growatt',
    category: 'إنفرترات',
    model: 'Growatt',
    specification: 'Hybrid / Off-Grid',
    price: 0,
  ),

  // BATTERIES
  Product(
    brand: 'Deye',
    category: 'بطاريات',
    model: 'Deye Lithium',
    specification: 'LiFePO4',
    price: 0,
  ),
  Product(
    brand: 'Motoma',
    category: 'بطاريات',
    model: 'Motoma Lithium',
    specification: 'LiFePO4',
    price: 0,
  ),
  Product(
    brand: 'Felicity',
    category: 'بطاريات',
    model: 'Felicity Lithium',
    specification: 'LiFePO4',
    price: 0,
  ),
  Product(
    brand: 'GSB',
    category: 'بطاريات',
    model: 'GSB Lithium',
    specification: 'LiFePO4',
    price: 0,
  ),
  Product(
    brand: 'MUST',
    category: 'بطاريات',
    model: 'MUST Lithium',
    specification: 'LiFePO4',
    price: 0,
  ),
  Product(
    brand: 'Growatt',
    category: 'بطاريات',
    model: 'Growatt Lithium',
    specification: 'LiFePO4',
    price: 0,
  ),

  // PANELS
  Product(
    brand: 'LONGi',
    category: 'ألواح',
    model: 'LONGi Solar',
    specification: 'Mono / N-Type',
    price: 0,
  ),
  Product(
    brand: 'Jinko',
    category: 'ألواح',
    model: 'Jinko Solar',
    specification: 'Mono / N-Type',
    price: 0,
  ),
  Product(
    brand: 'Trina',
    category: 'ألواح',
    model: 'Trina Solar',
    specification: 'Mono / N-Type',
    price: 0,
  ),
  Product(
    brand: 'GSB',
    category: 'ألواح',
    model: 'GSB Solar',
    specification: 'Mono',
    price: 0,
  ),
  Product(
    brand: 'Motoma',
    category: 'ألواح',
    model: 'Motoma Solar',
    specification: 'Mono',
    price: 0,
  ),
];

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  String selectedCategory = 'الكل';
  String search = '';

  final categories = [
    'الكل',
    'إنفرترات',
    'بطاريات',
    'ألواح',
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = products.where((product) {
      final categoryMatch =
          selectedCategory == 'الكل' ||
          product.category == selectedCategory;

      final searchMatch =
          search.isEmpty ||
          product.brand
              .toLowerCase()
              .contains(search.toLowerCase()) ||
          product.model
              .toLowerCase()
              .contains(search.toLowerCase());

      return categoryMatch && searchMatch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('السوق العالمي'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 5, 15, 8),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  search = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'ابحث عن شركة أو موديل...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.only(bottom: 5),
            child: Text(
              'الأسعار بالدولار الأمريكي USD',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF087F5B),
              ),
            ),
          ),

          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: categories.length,
              itemBuilder: (_, index) {
                final category = categories[index];

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(category),
                    selected:
                        selectedCategory == category,
                    onSelected: (_) {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                  ),
                );
              },
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filtered.length,
              itemBuilder: (_, index) {
                return ProductCard(
                  product: filtered[index],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PRODUCT CARD
// ============================================================

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;

    if (product.category == 'ألواح') {
      icon = Icons.solar_power;
    } else if (product.category == 'بطاريات') {
      icon = Icons.battery_full;
    } else {
      icon = Icons.bolt;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor:
                  const Color(0xFFE1F4ED),
              child: Icon(
                icon,
                color: const Color(0xFF087F5B),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    product.brand,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    product.model,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  Text(
                    product.specification,
                    style: const TextStyle(
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            Column(
              children: [
                if (product.price > 0)
                  Text(
                    '\$${product.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF087F5B),
                    ),
                  )
                else
                  const Text(
                    'السعر قريباً',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const Text(
                  'USD',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
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

// ============================================================
// ABOUT PAGE
// ============================================================

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('عن التطبيق'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 15),

            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: const Color(0xFFE1F4ED),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.solar_power,
                size: 60,
                color: Color(0xFF087F5B),
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              'Sudan SO',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Color(0xFF087F5B),
              ),
            ),

            const Text(
              'حلول أذكى للطاقة الشمسية',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 30),

            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.engineering,
                      size: 48,
                      color: Color(0xFF087F5B),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'باشمهندس حمزة الطيب',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'خبرة واسعة في مجال الطاقة الشمسية وأنظمة الطاقة، مع خبرة في تصميم الأنظمة واختيار المكونات المناسبة وتقديم الاستشارات الهندسية وحلول التركيب والتشغيل.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.7,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'خدماتنا',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 15),
                    ServiceRow(
                      icon: Icons.engineering,
                      text: 'الاستشارات الهندسية',
                    ),
                    ServiceRow(
                      icon: Icons.solar_power,
                      text: 'تصميم أنظمة الطاقة الشمسية',
                    ),
                    ServiceRow(
                      icon: Icons.battery_full,
                      text: 'اختيار البطاريات',
                    ),
                    ServiceRow(
                      icon: Icons.bolt,
                      text: 'اختيار الإنفرترات',
                    ),
                    ServiceRow(
                      icon: Icons.electrical_services,
                      text: 'حساب الأحمال والاستهلاك',
                    ),
                    ServiceRow(
                      icon: Icons.build,
                      text: 'إرشادات التركيب والتوصيل',
                    ),
                    ServiceRow(
                      icon: Icons.store,
                      text: 'مقارنة المنتجات والأسعار',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: const [
                    Text(
                      'للتواصل',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Icon(
                      Icons.chat,
                      color: Color(0xFF087F5B),
                      size: 38,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'واتساب',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '+249 91 653 7047',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Sudan SO — حلول أذكى للطاقة الشمسية.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              '© 2026 Sudan SO',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SERVICE ROW
// ============================================================

class ServiceRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const ServiceRow({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF087F5B),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// RESULT BOX
// ============================================================

class ResultBox extends StatelessWidget {
  final String title;
  final String value;

  const ResultBox({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF087F5B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// INPUT
// ============================================================

Widget _input(
  TextEditingController controller,
  String label,
  IconData icon,
) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 13),
    child: TextField(
      controller: controller,
      keyboardType:
          const TextInputType.numberWithOptions(
        decimal: true,
      ),
      decoration: _decoration(label, icon),
    ),
  );
}

InputDecoration _decoration(
  String label,
  IconData icon,
) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(
        color: Color(0xFFE0E5E3),
      ),
    ),
  );
}
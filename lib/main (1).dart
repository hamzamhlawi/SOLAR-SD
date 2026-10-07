import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

void main() => runApp(const SudanSOApp());

class SudanSOApp extends StatelessWidget {
  const SudanSOApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sudan SO',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF087F5B),
        scaffoldBackgroundColor: const Color(0xFFF6F8F7),
        appBarTheme: const AppBarTheme(centerTitle: true),
        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFF087F5B),
              width: 2,
            ),
          ),
        ),
      ),
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox(),
      ),
      home: const MainShell(),
    );
  }
}

enum BatteryType { lithium, agm, fld }

extension BatteryTypeInfo on BatteryType {
  String get label => switch (this) {
        BatteryType.lithium => 'Lithium',
        BatteryType.agm => 'AGM',
        BatteryType.fld => 'FLD',
      };

  double get efficiency => switch (this) {
        BatteryType.lithium => 0.95,
        BatteryType.agm => 0.90,
        BatteryType.fld => 0.85,
      };

  double get dod => switch (this) {
        BatteryType.lithium => 0.80,
        BatteryType.agm => 0.50,
        BatteryType.fld => 0.50,
      };

  String get description => switch (this) {
        BatteryType.lithium => 'كفاءة عالية وعمر دوري جيد، مع ضرورة توافق BMS.',
        BatteryType.agm => 'رصاص محكمة الإغلاق، مناسبة للتصميم المحافظ.',
        BatteryType.fld => 'رصاص مغمورة وتحتاج تهوية وصيانة مناسبة.',
      };
}

class SolarPanel {
  final String brand, model;
  final double watt, voc, vmp, isc, imp;
  const SolarPanel({
    required this.brand,
    required this.model,
    required this.watt,
    required this.voc,
    required this.vmp,
    required this.isc,
    required this.imp,
  });
  String get title => '$brand $model';
}

class Inverter {
  final String brand, model, tier, type, url;
  final double powerKw, batteryVoltage, maxPvPowerKw, maxPvVoc;
  final double mpptMin, mpptMax, maxPvCurrent, maxChargeCurrent;
  final double maxDischargeCurrent, efficiency;
  final int mpptCount;
  final String ipRating;

  const Inverter({
    required this.brand,
    required this.model,
    required this.tier,
    required this.type,
    required this.powerKw,
    required this.batteryVoltage,
    required this.maxPvPowerKw,
    required this.maxPvVoc,
    required this.mpptMin,
    required this.mpptMax,
    required this.mpptCount,
    required this.maxPvCurrent,
    required this.maxChargeCurrent,
    required this.maxDischargeCurrent,
    required this.efficiency,
    required this.ipRating,
    required this.url,
  });
  String get title => '$brand $model';
}

class LoadItem {
  String name;
  double power, hours;
  int quantity;
  LoadItem({
    required this.name,
    required this.power,
    required this.quantity,
    required this.hours,
  });
  double get dailyWh => power * quantity * hours;
  double get peakW => power * quantity;
}

class PvConfiguration {
  final int series, parallel, totalPanels;
  final double arrayKw, coldVoc, hotVmp, current;
  const PvConfiguration({
    required this.series,
    required this.parallel,
    required this.totalPanels,
    required this.arrayKw,
    required this.coldVoc,
    required this.hotVmp,
    required this.current,
  });
  String get text => '${series}S × ${parallel}P';
}

class CalculationResult {
  final double dailyWh, peakW, pvRequiredKw, batteryKwh, batteryAh;
  final double loadCurrent, chargeCurrent, actualPvKw, coldVoc, hotVmp, mpptCurrent;
  final int requiredPanels, actualPanels;
  final BatteryType batteryType;
  final bool peakOk, pvPowerOk, vocOk, vmpOk, currentOk;
  const CalculationResult({
    required this.dailyWh,
    required this.peakW,
    required this.pvRequiredKw,
    required this.requiredPanels,
    required this.batteryKwh,
    required this.batteryAh,
    required this.loadCurrent,
    required this.chargeCurrent,
    required this.actualPvKw,
    required this.actualPanels,
    required this.coldVoc,
    required this.hotVmp,
    required this.mpptCurrent,
    required this.batteryType,
    required this.peakOk,
    required this.pvPowerOk,
    required this.vocOk,
    required this.vmpOk,
    required this.currentOk,
  });
}

class SolarDatabase {
  static const panels = <SolarPanel>[
    SolarPanel(
      brand: 'Trina',
      model: 'Vertex 550W',
      watt: 550,
      voc: 49.8,
      vmp: 41.7,
      isc: 13.89,
      imp: 13.19,
    ),
    SolarPanel(
      brand: 'Jinko',
      model: 'Tiger 550W',
      watt: 550,
      voc: 49.62,
      vmp: 41.62,
      isc: 13.89,
      imp: 13.21,
    ),
    SolarPanel(
      brand: 'LONGi',
      model: 'Hi-MO 6 550W',
      watt: 550,
      voc: 49.8,
      vmp: 41.7,
      isc: 13.9,
      imp: 13.2,
    ),
  ];

  static const inverters = <Inverter>[
    Inverter(
      brand: 'Deye',
      model: 'SUN-5K',
      tier: 'الفئة العليا',
      type: 'Hybrid',
      powerKw: 5,
      batteryVoltage: 48,
      maxPvPowerKw: 6.5,
      maxPvVoc: 500,
      mpptMin: 150,
      mpptMax: 425,
      mpptCount: 2,
      maxPvCurrent: 13,
      maxChargeCurrent: 120,
      maxDischargeCurrent: 120,
      efficiency: 97.6,
      ipRating: 'IP65',
      url: 'https://www.deyeess.com/',
    ),
    Inverter(
      brand: 'Solis',
      model: 'S5-EH1P5K-L',
      tier: 'الفئة العليا',
      type: 'Hybrid',
      powerKw: 5,
      batteryVoltage: 48,
      maxPvPowerKw: 8,
      maxPvVoc: 600,
      mpptMin: 90,
      mpptMax: 520,
      mpptCount: 2,
      maxPvCurrent: 16,
      maxChargeCurrent: 100,
      maxDischargeCurrent: 100,
      efficiency: 97.7,
      ipRating: 'IP65',
      url: 'https://www.solisinverters.com/',
    ),
    Inverter(
      brand: 'FusionSolar',
      model: 'Huawei 5kW',
      tier: 'الفئة العليا',
      type: 'Hybrid',
      powerKw: 5,
      batteryVoltage: 48,
      maxPvPowerKw: 7.5,
      maxPvVoc: 600,
      mpptMin: 90,
      mpptMax: 560,
      mpptCount: 2,
      maxPvCurrent: 12.5,
      maxChargeCurrent: 100,
      maxDischargeCurrent: 100,
      efficiency: 98.4,
      ipRating: 'IP65',
      url: 'https://solar.huawei.com/',
    ),
    Inverter(
      brand: 'Growatt',
      model: 'SPF 5000 ES',
      tier: 'الفئة العليا',
      type: 'Off Grid',
      powerKw: 5,
      batteryVoltage: 48,
      maxPvPowerKw: 6,
      maxPvVoc: 450,
      mpptMin: 120,
      mpptMax: 430,
      mpptCount: 1,
      maxPvCurrent: 18,
      maxChargeCurrent: 100,
      maxDischargeCurrent: 100,
      efficiency: 93,
      ipRating: 'IP20',
      url: 'https://www.growatt.com/',
    ),
    Inverter(
      brand: 'GSB',
      model: '5kW 48V',
      tier: 'الفئة المتوسطة',
      type: 'Hybrid',
      powerKw: 5,
      batteryVoltage: 48,
      maxPvPowerKw: 6,
      maxPvVoc: 500,
      mpptMin: 120,
      mpptMax: 450,
      mpptCount: 1,
      maxPvCurrent: 18,
      maxChargeCurrent: 100,
      maxDischargeCurrent: 100,
      efficiency: 94,
      ipRating: 'IP21',
      url: 'https://gsbsolar.com/hybrid-inverter/',
    ),
    Inverter(
      brand: 'Motoma',
      model: 'Hybrid 5kW',
      tier: 'الفئة المتوسطة',
      type: 'Hybrid',
      powerKw: 5,
      batteryVoltage: 48,
      maxPvPowerKw: 6,
      maxPvVoc: 500,
      mpptMin: 120,
      mpptMax: 450,
      mpptCount: 2,
      maxPvCurrent: 15,
      maxChargeCurrent: 100,
      maxDischargeCurrent: 100,
      efficiency: 95,
      ipRating: 'IP65',
      url: 'https://motoma.com/product-category/hybrid-inverter/',
    ),
    Inverter(
      brand: 'MUST',
      model: 'PV18-5048',
      tier: 'الفئة المتوسطة',
      type: 'Off Grid',
      powerKw: 5,
      batteryVoltage: 48,
      maxPvPowerKw: 6,
      maxPvVoc: 500,
      mpptMin: 120,
      mpptMax: 450,
      mpptCount: 1,
      maxPvCurrent: 18,
      maxChargeCurrent: 100,
      maxDischargeCurrent: 100,
      efficiency: 93,
      ipRating: 'IP21',
      url: 'https://www.mustpower.com/',
    ),
    Inverter(
      brand: 'FelicitySolar',
      model: 'IVGM5KLP2G1',
      tier: 'الفئة المتوسطة',
      type: 'Hybrid',
      powerKw: 5,
      batteryVoltage: 48,
      maxPvPowerKw: 6.5,
      maxPvVoc: 500,
      mpptMin: 120,
      mpptMax: 450,
      mpptCount: 2,
      maxPvCurrent: 18,
      maxChargeCurrent: 100,
      maxDischargeCurrent: 100,
      efficiency: 95,
      ipRating: 'IP65',
      url: 'https://africa.felicitysolar.com/africa-ar/hybrid-inverter/',
    ),
    Inverter(
      brand: 'Vackson',
      model: '3.2kVA 24V',
      tier: 'الفئة الاقتصادية',
      type: 'Off Grid',
      powerKw: 2.56,
      batteryVoltage: 24,
      maxPvPowerKw: 3,
      maxPvVoc: 450,
      mpptMin: 120,
      mpptMax: 430,
      mpptCount: 1,
      maxPvCurrent: 18,
      maxChargeCurrent: 80,
      maxDischargeCurrent: 100,
      efficiency: 93,
      ipRating: 'IP21',
      url: 'https://alwansolar.com/en/products/%D9%85%D8%AD%D9%88%D9%84-3-2kva-24v-vackson',
    ),
    Inverter(
      brand: 'Megasun',
      model: '5kW 48V',
      tier: 'الفئة الاقتصادية',
      type: 'Hybrid',
      powerKw: 5,
      batteryVoltage: 48,
      maxPvPowerKw: 6,
      maxPvVoc: 500,
      mpptMin: 120,
      mpptMax: 450,
      mpptCount: 1,
      maxPvCurrent: 18,
      maxChargeCurrent: 100,
      maxDischargeCurrent: 100,
      efficiency: 93,
      ipRating: 'IP21',
      url: 'https://ms.bluefinsolarenergy.com/',
    ),
    Inverter(
      brand: 'Eruonet',
      model: 'Solar Inverter',
      tier: 'الفئة الاقتصادية',
      type: 'Hybrid',
      powerKw: 5,
      batteryVoltage: 48,
      maxPvPowerKw: 6,
      maxPvVoc: 500,
      mpptMin: 120,
      mpptMax: 450,
      mpptCount: 1,
      maxPvCurrent: 18,
      maxChargeCurrent: 100,
      maxDischargeCurrent: 100,
      efficiency: 93,
      ipRating: 'غير محدد',
      url: '',
    ),
    Inverter(
      brand: 'Restar',
      model: '5kW 48V',
      tier: 'الفئة الاقتصادية',
      type: 'Hybrid',
      powerKw: 5,
      batteryVoltage: 48,
      maxPvPowerKw: 6,
      maxPvVoc: 500,
      mpptMin: 120,
      mpptMax: 450,
      mpptCount: 1,
      maxPvCurrent: 18,
      maxChargeCurrent: 100,
      maxDischargeCurrent: 100,
      efficiency: 93,
      ipRating: 'IP21',
      url: '',
    ),
  ];
}

class SolarEngineering {
  static CalculationResult calculate({
    required List<LoadItem> loads,
    required SolarPanel panel,
    required Inverter inverter,
    required BatteryType batteryType,
    required double psh,
    required double systemEfficiency,
    required double batteryEfficiency,
    required double dod,
    required double safetyMargin,
    required int series,
    required int parallel,
  }) {
    double dailyWh = 0, peakW = 0;
    for (final load in loads) {
      dailyWh += load.dailyWh;
      peakW += load.peakW;
    }

    final ps = math.max(1.0, psh).toDouble();
    final se = math.max(0.50, math.min(systemEfficiency, 1.0)).toDouble();
    final be = math.max(0.70, math.min(batteryEfficiency, 1.0)).toDouble();
    final d = math.max(0.30, math.min(dod, 0.95)).toDouble();
    final sm = math.max(1.0, safetyMargin).toDouble();

    final pvRequiredKw = (dailyWh / ps / se / 1000.0).toDouble();
    final requiredPanels = math.max(
      1,
      (pvRequiredKw * 1000 / panel.watt).ceil(),
    ).toInt();

    final batteryKwh = (dailyWh / 1000 / d / be).toDouble();
    final batteryAh = (batteryKwh * 1000 / inverter.batteryVoltage).toDouble();
    final loadCurrent = (peakW * sm / inverter.batteryVoltage).toDouble();
    final chargeCurrent = (pvRequiredKw * 1000 / inverter.batteryVoltage).toDouble();

    final totalPanels = math.max(1, series).toInt() * math.max(1, parallel).toInt();
    final actualPvKw = (totalPanels * panel.watt / 1000).toDouble();
    final coldVoc = (series * panel.voc * 1.10).toDouble();
    final hotVmp = (series * panel.vmp * 0.85).toDouble();

    final stringsPerMppt = math.max(
      1,
      (parallel + inverter.mpptCount - 1) ~/ inverter.mpptCount,
    ).toInt();
    final mpptCurrent = (panel.isc * stringsPerMppt).toDouble();

    return CalculationResult(
      dailyWh: dailyWh,
      peakW: peakW,
      pvRequiredKw: pvRequiredKw,
      requiredPanels: requiredPanels,
      batteryKwh: batteryKwh,
      batteryAh: batteryAh,
      loadCurrent: loadCurrent,
      chargeCurrent: chargeCurrent,
      actualPvKw: actualPvKw,
      actualPanels: totalPanels,
      coldVoc: coldVoc,
      hotVmp: hotVmp,
      mpptCurrent: mpptCurrent,
      batteryType: batteryType,
      peakOk: peakW * sm <= inverter.powerKw * 1000,
      pvPowerOk: actualPvKw <= inverter.maxPvPowerKw,
      vocOk: coldVoc <= inverter.maxPvVoc,
      vmpOk: hotVmp >= inverter.mpptMin && hotVmp <= inverter.mpptMax,
      currentOk: mpptCurrent <= inverter.maxPvCurrent,
    );
  }

  static PvConfiguration? suggest({
    required SolarPanel panel,
    required Inverter inverter,
    required int minimumPanels,
  }) {
    PvConfiguration? best;

    for (int s = 1; s <= 24; s++) {
      for (int p = 1; p <= 12; p++) {
        final total = s * p;
        if (total < minimumPanels) continue;

        final kw = (total * panel.watt / 1000).toDouble();
        final voc = (s * panel.voc * 1.10).toDouble();
        final vmp = (s * panel.vmp * 0.85).toDouble();
        final strings = math.max(
          1,
          (p + inverter.mpptCount - 1) ~/ inverter.mpptCount,
        ).toInt();
        final current = (panel.isc * strings).toDouble();

        if (kw > inverter.maxPvPowerKw ||
            voc > inverter.maxPvVoc ||
            vmp < inverter.mpptMin ||
            vmp > inverter.mpptMax ||
            current > inverter.maxPvCurrent) {
          continue;
        }

        final candidate = PvConfiguration(
          series: s,
          parallel: p,
          totalPanels: total,
          arrayKw: kw,
          coldVoc: voc,
          hotVmp: vmp,
          current: current,
        );

        if (best == null || candidate.totalPanels < best.totalPanels) {
          best = candidate;
        }
      }
    }
    return best;
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;
  final pages = const [
    HomePage(),
    CalculatorPage(),
    MarketPage(),
    LocationPage(),
    MorePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (v) => setState(() => index = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.calculate_outlined), selectedIcon: Icon(Icons.calculate), label: 'الحاسبة'),
          NavigationDestination(icon: Icon(Icons.storefront_outlined), selectedIcon: Icon(Icons.storefront), label: 'السوق'),
          NavigationDestination(icon: Icon(Icons.location_on_outlined), selectedIcon: Icon(Icons.location_on), label: 'الموقع'),
          NavigationDestination(icon: Icon(Icons.menu), selectedIcon: Icon(Icons.menu), label: 'المزيد'),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sudan SO', style: TextStyle(fontWeight: FontWeight.bold))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF087F5B), Color(0xFF0B6E4F)]),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.solar_power, color: Colors.white, size: 52),
                SizedBox(height: 14),
                Text('Sudan SO', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('منصة لحساب وتصميم أنظمة الطاقة الشمسية.', style: TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionTitle(title: 'أدوات التطبيق', icon: Icons.build_circle_outlined),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              ToolCard(icon: Icons.calculate, title: 'الحاسبة', subtitle: 'تصميم النظام', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalculatorPage()))),
              ToolCard(icon: Icons.solar_power, title: 'الألواح', subtitle: 'Trina • Jinko • LONGi', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MarketPage()))),
              ToolCard(icon: Icons.electrical_services, title: 'الإنفرترات', subtitle: 'الفئات والمواصفات', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MarketPage()))),
              ToolCard(icon: Icons.battery_full, title: 'البطاريات', subtitle: 'Lithium • AGM • FLD', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalculatorPage()))),
            ],
          ),
          const SizedBox(height: 18),
          const AppCard(child: Text('ملاحظة: النتائج هندسية أولية ويجب مراجعة Datasheet الفعلي لكل جهاز والكابلات والحمايات ودرجات الحرارة وتيار الإقلاع قبل التنفيذ.')),
        ],
      ),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});
  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final loads = <LoadItem>[
    LoadItem(name: 'ثلاجة', power: 200, quantity: 1, hours: 12),
    LoadItem(name: 'مروحة', power: 70, quantity: 2, hours: 10),
    LoadItem(name: 'إضاءة', power: 20, quantity: 6, hours: 6),
  ];

  SolarPanel panel = SolarDatabase.panels.first;
  Inverter inverter = SolarDatabase.inverters.first;
  BatteryType battery = BatteryType.lithium;
  int series = 4, parallel = 2;

  final psh = TextEditingController(text: '5.5');
  final sysEff = TextEditingController(text: '80');
  final batEff = TextEditingController(text: '95');
  final dod = TextEditingController(text: '80');
  final safety = TextEditingController(text: '1.25');

  CalculationResult? result;
  PvConfiguration? suggestion;

  @override
  void dispose() {
    psh.dispose(); sysEff.dispose(); batEff.dispose(); dod.dispose(); safety.dispose();
    super.dispose();
  }

  void applyBattery(BatteryType t) {
    setState(() {
      battery = t;
      batEff.text = (t.efficiency * 100).toStringAsFixed(0);
      dod.text = (t.dod * 100).toStringAsFixed(0);
    });
  }

  void calculate() {
    final p = double.tryParse(psh.text.replaceAll(',', '.')) ?? 5.5;
    final se = (double.tryParse(sysEff.text.replaceAll(',', '.')) ?? 80) / 100;
    final be = (double.tryParse(batEff.text.replaceAll(',', '.')) ?? battery.efficiency * 100) / 100;
    final d = (double.tryParse(dod.text.replaceAll(',', '.')) ?? battery.dod * 100) / 100;
    final sm = double.tryParse(safety.text.replaceAll(',', '.')) ?? 1.25;

    setState(() {
      result = SolarEngineering.calculate(
        loads: loads,
        panel: panel,
        inverter: inverter,
        batteryType: battery,
        psh: p,
        systemEfficiency: se,
        batteryEfficiency: be,
        dod: d,
        safetyMargin: sm,
        series: series,
        parallel: parallel,
      );
      suggestion = SolarEngineering.suggest(
        panel: panel,
        inverter: inverter,
        minimumPanels: result!.requiredPanels,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الحاسبة الهندسية')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionTitle(title: 'الأحمال', icon: Icons.power),
          const SizedBox(height: 10),
          ...List.generate(loads.length, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AppCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(loads[i].name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${loads[i].power.toStringAsFixed(0)}W × ${loads[i].quantity} × ${loads[i].hours.toStringAsFixed(1)}h = ${loads[i].dailyWh.toStringAsFixed(0)}Wh/day'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editLoad(i),
                ),
              ),
            ),
          )),
          OutlinedButton.icon(onPressed: () => setState(() => loads.add(LoadItem(name: 'حمل جديد', power: 100, quantity: 1, hours: 5))), icon: const Icon(Icons.add), label: const Text('إضافة حمل')),
          const SizedBox(height: 20),

          const SectionTitle(title: 'الألواح والإنفرتر', icon: Icons.solar_power),
          const SizedBox(height: 10),
          AppCard(
            child: Column(
              children: [
                DropdownButtonFormField<SolarPanel>(
                  value: panel,
                  decoration: const InputDecoration(labelText: 'اللوح الشمسي', prefixIcon: Icon(Icons.solar_power)),
                  items: SolarDatabase.panels.map((p) => DropdownMenuItem(value: p, child: Text('${p.title} - ${p.watt.toStringAsFixed(0)}W'))).toList(),
                  onChanged: (v) => setState(() => panel = v!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<Inverter>(
                  value: inverter,
                  decoration: const InputDecoration(labelText: 'الإنفرتر', prefixIcon: Icon(Icons.electrical_services)),
                  items: SolarDatabase.inverters.map((i) => DropdownMenuItem(value: i, child: Text('${i.brand} ${i.model}'))).toList(),
                  onChanged: (v) => setState(() => inverter = v!),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const SectionTitle(title: 'نوع البطارية', icon: Icons.battery_full),
          const SizedBox(height: 10),
          AppCard(
            child: Column(
              children: [
                DropdownButtonFormField<BatteryType>(
                  value: battery,
                  decoration: const InputDecoration(labelText: 'البطارية', prefixIcon: Icon(Icons.battery_charging_full)),
                  items: BatteryType.values.map((b) => DropdownMenuItem(value: b, child: Text(b.label))).toList(),
                  onChanged: (v) { if (v != null) applyBattery(v); },
                ),
                const SizedBox(height: 8),
                Align(alignment: Alignment.centerRight, child: Text(battery.description)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const SectionTitle(title: 'إعدادات التصميم', icon: Icons.tune),
          const SizedBox(height: 10),
          AppCard(
            child: Column(
              children: [
                NumberField(controller: psh, label: 'Peak Sun Hours', suffix: 'ساعة'),
                const SizedBox(height: 10),
                NumberField(controller: sysEff, label: 'كفاءة النظام', suffix: '%'),
                const SizedBox(height: 10),
                NumberField(controller: batEff, label: 'كفاءة البطارية', suffix: '%'),
                const SizedBox(height: 10),
                NumberField(controller: dod, label: 'Depth of Discharge', suffix: '%'),
                const SizedBox(height: 10),
                NumberField(controller: safety, label: 'Safety Margin', suffix: '×'),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _intField('Series', series, (v) => setState(() => series = v))),
                    const SizedBox(width: 10),
                    Expanded(child: _intField('Parallel', parallel, (v) => setState(() => parallel = v))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(onPressed: calculate, icon: const Icon(Icons.calculate), label: const Padding(padding: EdgeInsets.all(12), child: Text('احسب النظام', style: TextStyle(fontSize: 17)))),

          if (result != null) ...[
            const SizedBox(height: 22),
            const SectionTitle(title: 'النتائج', icon: Icons.analytics),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.35,
              children: [
                MetricCard(title: 'الاستهلاك', value: '${result!.dailyWh.toStringAsFixed(0)} Wh', icon: Icons.bolt),
                MetricCard(title: 'الحمل الأقصى', value: '${result!.peakW.toStringAsFixed(0)} W', icon: Icons.power),
                MetricCard(title: 'PV المطلوبة', value: '${result!.pvRequiredKw.toStringAsFixed(2)} kW', icon: Icons.solar_power),
                MetricCard(title: 'عدد الألواح', value: '${result!.requiredPanels}', icon: Icons.grid_view),
                MetricCard(title: 'البطارية', value: '${result!.batteryKwh.toStringAsFixed(2)} kWh', icon: Icons.battery_full),
                MetricCard(title: 'البطارية', value: '${result!.batteryAh.toStringAsFixed(0)} Ah', icon: Icons.battery_charging_full),
              ],
            ),
            const SizedBox(height: 12),
            ResultCard(title: 'التكوين الحالي', child: Column(children: [
              SpecRow(label: 'البطارية', value: result!.batteryType.label),
              SpecRow(label: 'الألواح', value: '$series S × $parallel P = ${result!.actualPanels}'),
              SpecRow(label: 'قدرة PV', value: '${result!.actualPvKw.toStringAsFixed(2)} kW'),
              SpecRow(label: 'Cold Voc', value: '${result!.coldVoc.toStringAsFixed(1)} V'),
              SpecRow(label: 'Hot Vmp', value: '${result!.hotVmp.toStringAsFixed(1)} V'),
              SpecRow(label: 'تيار MPPT', value: '${result!.mpptCurrent.toStringAsFixed(1)} A'),
            ])),
            const SizedBox(height: 12),
            ResultCard(title: 'الفحوصات', child: Column(children: [
              CheckRow('قدرة الإنفرتر للحمل', result!.peakOk),
              CheckRow('قدرة PV ضمن الحد', result!.pvPowerOk),
              CheckRow('Cold Voc ضمن الحد', result!.vocOk),
              CheckRow('Hot Vmp داخل MPPT', result!.vmpOk),
              CheckRow('تيار MPPT ضمن الحد', result!.currentOk),
            ])),
            if (suggestion != null) ...[
              const SizedBox(height: 12),
              ResultCard(title: 'التكوين المقترح', child: Column(children: [
                Text(suggestion!.text, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                Text('${suggestion!.totalPanels} لوح • ${suggestion!.arrayKw.toStringAsFixed(2)} kW'),
                Text('Voc ${suggestion!.coldVoc.toStringAsFixed(1)}V • Vmp ${suggestion!.hotVmp.toStringAsFixed(1)}V'),
                const SizedBox(height: 8),
                FilledButton(onPressed: () => setState(() { series = suggestion!.series; parallel = suggestion!.parallel; }), child: const Text('استخدام التكوين')),
              ])),
            ],
          ],
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _intField(String label, int value, ValueChanged<int> onChanged) {
    return TextFormField(
      initialValue: value.toString(),
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
      onChanged: (v) {
        final n = int.tryParse(v);
        if (n != null && n > 0) onChanged(n);
      },
    );
  }

  void _editLoad(int index) {
    final l = loads[index];
    final n = TextEditingController(text: l.name);
    final p = TextEditingController(text: l.power.toString());
    final q = TextEditingController(text: l.quantity.toString());
    final h = TextEditingController(text: l.hours.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تعديل الحمل'),
        content: SingleChildScrollView(child: Column(children: [
          TextField(controller: n, decoration: const InputDecoration(labelText: 'الاسم')),
          const SizedBox(height: 8),
          TextField(controller: p, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'القدرة W')),
          const SizedBox(height: 8),
          TextField(controller: q, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'العدد')),
          const SizedBox(height: 8),
          TextField(controller: h, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'الساعات')),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          FilledButton(onPressed: () {
            setState(() {
              l.name = n.text.isEmpty ? 'حمل' : n.text;
              l.power = double.tryParse(p.text.replaceAll(',', '.')) ?? 100;
              l.quantity = int.tryParse(q.text) ?? 1;
              l.hours = double.tryParse(h.text.replaceAll(',', '.')) ?? 1;
            });
            Navigator.pop(context);
          }, child: const Text('حفظ')),
        ],
      ),
    );
  }
}

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});
  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  String search = '', type = 'الكل', tier = 'الكل';

  List<dynamic> get products {
    final all = <dynamic>[...SolarDatabase.panels, ...SolarDatabase.inverters];
    return all.where((x) {
      final title = x is SolarPanel ? x.title : (x as Inverter).title;
      if (!title.toLowerCase().contains(search.toLowerCase())) return false;
      if (type == 'الألواح') return x is SolarPanel;
      if (type == 'الإنفرترات') {
        return x is Inverter && (tier == 'الكل' || x.tier == tier);
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('السوق')),
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(16), child: TextField(onChanged: (v) => setState(() => search = v), decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'ابحث عن منتج...'))),
        SizedBox(height: 45, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), children: [
          _chip('الكل', type, (v) => setState(() { type = v; if (v != 'الإنفرترات') tier = 'الكل'; })),
          _chip('الألواح', type, (v) => setState(() => type = v)),
          _chip('الإنفرترات', type, (v) => setState(() => type = v)),
        ])),
        if (type == 'الإنفرترات')
          SizedBox(height: 48, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), children: [
            _chip('الكل', tier, (v) => setState(() => tier = v)),
            _chip('الفئة العليا', tier, (v) => setState(() => tier = v)),
            _chip('الفئة المتوسطة', tier, (v) => setState(() => tier = v)),
            _chip('الفئة الاقتصادية', tier, (v) => setState(() => tier = v)),
          ])),
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: products.length,
          itemBuilder: (_, i) {
            final x = products[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(child: ListTile(
                leading: CircleAvatar(child: Icon(x is SolarPanel ? Icons.solar_power : Icons.electrical_services)),
                title: Text(x is SolarPanel ? x.title : x.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: x is SolarPanel ? Text('${x.watt.toStringAsFixed(0)}W • Voc ${x.voc}V • Vmp ${x.vmp}V') : Text('${x.powerKw.toStringAsFixed(1)}kW • ${x.tier}'),
                trailing: const Icon(Icons.chevron_left),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsPage(panel: x is SolarPanel ? x : null, inverter: x is Inverter ? x : null))),
              )),
            );
          },
        )),
      ]),
    );
  }

  Widget _chip(String text, String selected, ValueChanged<String> onTap) => Padding(
    padding: const EdgeInsets.only(left: 8),
    child: ChoiceChip(label: Text(text), selected: text == selected, onSelected: (_) => onTap(text)),
  );
}

class ProductDetailsPage extends StatelessWidget {
  final SolarPanel? panel;
  final Inverter? inverter;
  const ProductDetailsPage({super.key, this.panel, this.inverter});

  Future<void> openUrl() async {
    final url = inverter?.url ?? '';
    if (url.isEmpty) return;
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل المنتج')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        AppCard(child: Column(children: [
          CircleAvatar(radius: 34, child: Icon(panel != null ? Icons.solar_power : Icons.electrical_services, size: 35)),
          const SizedBox(height: 10),
          Text(panel?.title ?? inverter!.title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
        ])),
        const SizedBox(height: 12),
        if (panel != null) ResultCard(title: 'مواصفات اللوح', child: Column(children: [
          SpecRow(label: 'القدرة', value: '${panel!.watt.toStringAsFixed(0)} W'),
          SpecRow(label: 'Voc', value: '${panel!.voc} V'),
          SpecRow(label: 'Vmp', value: '${panel!.vmp} V'),
          SpecRow(label: 'Isc', value: '${panel!.isc} A'),
          SpecRow(label: 'Imp', value: '${panel!.imp} A'),
        ])),
        if (inverter != null) ResultCard(title: 'مواصفات الإنفرتر', child: Column(children: [
          SpecRow(label: 'الفئة', value: inverter!.tier),
          SpecRow(label: 'النوع', value: inverter!.type),
          SpecRow(label: 'القدرة', value: '${inverter!.powerKw.toStringAsFixed(1)} kW'),
          SpecRow(label: 'البطارية', value: '${inverter!.batteryVoltage.toStringAsFixed(0)} V'),
          SpecRow(label: 'PV Max', value: '${inverter!.maxPvPowerKw.toStringAsFixed(1)} kW'),
          SpecRow(label: 'Max Voc', value: '${inverter!.maxPvVoc.toStringAsFixed(0)} V'),
          SpecRow(label: 'MPPT', value: '${inverter!.mpptMin.toStringAsFixed(0)}–${inverter!.mpptMax.toStringAsFixed(0)} V'),
          SpecRow(label: 'MPPT Count', value: '${inverter!.mpptCount}'),
          SpecRow(label: 'Max PV Current', value: '${inverter!.maxPvCurrent.toStringAsFixed(1)} A'),
        ])),
        if (inverter != null && inverter!.url.isNotEmpty) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(onPressed: openUrl, icon: const Icon(Icons.open_in_browser), label: const Text('فتح الرابط الرسمي')),
        ],
      ]),
    );
  }
}

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});
  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();

  bool loading = false;
  double? accuracy;
  String status = 'لم يتم تحديد الموقع بعد';
  double tilt = 15;
  String direction = 'جنوب';

  @override
  void dispose() {
    latitudeController.dispose();
    longitudeController.dispose();
    super.dispose();
  }

  Future<void> getCurrentLocation() async {
    setState(() {
      loading = true;
      status = 'جاري تحديد موقعك...';
    });

    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        setState(() {
          loading = false;
          status = 'خدمة الموقع GPS غير مفعلة.';
        });
        await _showMessage(
          'فعّل الموقع/GPS من إعدادات الهاتف ثم اضغط الزر مرة أخرى.',
          action: 'فتح إعدادات الموقع',
          onAction: () => Geolocator.openLocationSettings(),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        setState(() {
          loading = false;
          status = 'تم رفض إذن الموقع.';
        });
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          loading = false;
          status = 'إذن الموقع مرفوض نهائياً.';
        });
        await _showMessage(
          'تم رفض إذن الموقع نهائياً. افتح إعدادات التطبيق واسمح بالموقع أثناء استخدام التطبيق.',
          action: 'فتح إعدادات التطبيق',
          onAction: () => Geolocator.openAppSettings(),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
        ),
      );

      setState(() {
        latitudeController.text = position.latitude.toStringAsFixed(6);
        longitudeController.text = position.longitude.toStringAsFixed(6);
        accuracy = position.accuracy;
        tilt = _calculateTilt(position.latitude);
        status = 'تم تحديد الموقع بنجاح';
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        status = 'تعذر تحديد الموقع.';
      });
      await _showMessage('حدث خطأ أثناء قراءة GPS:\n$e');
    }
  }

  double _calculateTilt(double latitude) {
    return math.max(5.0, math.min(latitude.abs() + 5.0, 30.0)).toDouble();
  }

  Future<void> _showMessage(
    String message, {
    String? action,
    Future<bool> Function()? onAction,
  }) async {
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('الموقع'),
        content: Text(message),
        actions: [
          if (action != null && onAction != null)
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await onAction();
              },
              child: Text(action),
            ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الموقع GPS')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF087F5B), Color(0xFF0B6E4F)]),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Column(
              children: [
                Icon(Icons.location_on, color: Colors.white, size: 52),
                SizedBox(height: 8),
                Text('تحديد الموقع تلقائياً', style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Text('استخدم GPS لتعبئة خط العرض وخط الطول تلقائياً.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: loading ? null : getCurrentLocation,
              icon: loading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.my_location),
              label: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(loading ? 'جاري تحديد الموقع...' : 'تحديد موقعي الحالي GPS'),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(child: Text(status, style: TextStyle(fontWeight: FontWeight.w600, color: status.contains('نجاح') ? Colors.green : null))),
          const SizedBox(height: 16),
          AppCard(child: Column(children: [
            TextField(
              controller: latitudeController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              decoration: const InputDecoration(labelText: 'خط العرض Latitude', prefixIcon: Icon(Icons.north)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: longitudeController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              decoration: const InputDecoration(labelText: 'خط الطول Longitude', prefixIcon: Icon(Icons.east)),
            ),
            if (accuracy != null) ...[
              const SizedBox(height: 12),
              SpecRow(label: 'دقة GPS التقريبية', value: '${accuracy!.toStringAsFixed(1)} متر'),
            ],
          ])),
          const SizedBox(height: 16),
          ResultCard(title: 'إعداد الموقع الشمسي', child: Column(children: [
            SpecRow(label: 'الميل التقريبي', value: '${tilt.toStringAsFixed(1)}°'),
            SpecRow(label: 'الاتجاه', value: direction),
          ])),
          const SizedBox(height: 12),
          const AppCard(child: Text('ملاحظة: GPS يحتاج تفعيل خدمة الموقع ومنح التطبيق إذن الموقع. للحصول على أفضل دقة، استخدمه في مكان مفتوح. الميل والاتجاه هنا تقدير أولي وليس بديلاً عن دراسة الموقع.')),
        ],
      ),
    );
  }
}

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المزيد')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        AppCard(child: ListTile(
          leading: const CircleAvatar(child: Icon(Icons.info_outline)),
          title: const Text('عن التطبيق', style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: const Text('Sudan SO والمطور والتواصل'),
          trailing: const Icon(Icons.chevron_left),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutPage())),
        )),
      ]),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  Future<void> whatsapp() async {
    final text = Uri.encodeComponent('السلام عليكم، أريد التواصل بخصوص تطبيق Sudan SO.');
    await launchUrl(Uri.parse('https://wa.me/249916537047?text=$text'), mode: LaunchMode.externalApplication);
  }

  Future<void> email() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'SOLARSD2090@gmail.com',
      queryParameters: {'subject': 'Sudan SO', 'body': 'السلام عليكم،\n\nأرغب في التواصل بخصوص تطبيق Sudan SO.'},
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('عن التطبيق')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF087F5B), Color(0xFF0B6E4F)]),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Column(children: [
            CircleAvatar(radius: 40, backgroundColor: Colors.white, child: Icon(Icons.solar_power, size: 48, color: Color(0xFF087F5B))),
            SizedBox(height: 12),
            Text('Sudan SO', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Text('Solar Energy Calculator & Market', style: TextStyle(color: Colors.white)),
          ]),
        ),
        const SizedBox(height: 16),
        const AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('عن التطبيق', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('تطبيق متخصص في الحسابات الأولية لأنظمة الطاقة الشمسية، واختيار الألواح والإنفرترات والبطاريات ومراجعة التكوين الكهربائي.'),
        ])),
        const SizedBox(height: 16),
        const AppCard(child: Column(children: [
          CircleAvatar(radius: 38, child: Icon(Icons.engineering, size: 42)),
          SizedBox(height: 10),
          Text('حمزة الطيب', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('مهتم بالطاقة الشمسية وله خبرة واهتمام واسع في أنظمة الطاقة الشمسية وتطبيقاتها العملية.', textAlign: TextAlign.center),
        ])),
        const SizedBox(height: 16),
        AppCard(child: Column(children: [
          const Text('تواصل مباشر', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: whatsapp, icon: const Icon(Icons.chat), label: const Text('واتساب'))),
          const SizedBox(height: 8),
          SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: email, icon: const Icon(Icons.email_outlined), label: const Text('البريد الإلكتروني'))),
          const SizedBox(height: 10),
          const Text('SOLARSD2090@gmail.com'),
        ])),
      ]),
    );
  }
}

class AppCard extends StatelessWidget {
  final Widget child;
  const AppCard({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(16), child: child));
}

class SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  const SectionTitle({super.key, required this.title, required this.icon});
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, color: Theme.of(context).colorScheme.primary),
    const SizedBox(width: 8),
    Expanded(child: Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold))),
  ]);
}

class ToolCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  const ToolCard({super.key, required this.icon, required this.title, required this.subtitle, required this.onTap});
  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 34, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
        ]),
      ),
    ),
  );
}

class NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? suffix;
  const NumberField({super.key, required this.controller, required this.label, this.suffix});
  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(labelText: label, suffixText: suffix),
  );
}

class MetricCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  const MetricCard({super.key, required this.title, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) => Card(child: Padding(
    padding: const EdgeInsets.all(10),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, color: Theme.of(context).colorScheme.primary),
      const SizedBox(height: 5),
      Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
      const SizedBox(height: 3),
      Text(value, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    ]),
  ));
}

class ResultCard extends StatelessWidget {
  final String title;
  final Widget child;
  const ResultCard({super.key, required this.title, required this.child});
  @override
  Widget build(BuildContext context) => AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    const SizedBox(height: 10),
    child,
  ]));
}

class SpecRow extends StatelessWidget {
  final String label, value;
  const SpecRow({super.key, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      Expanded(child: Text(label)),
      Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
    ]),
  );
}

class CheckRow extends StatelessWidget {
  final String title;
  final bool ok;
  const CheckRow(this.title, this.ok, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      Icon(ok ? Icons.check_circle : Icons.cancel, color: ok ? Colors.green : Colors.red),
      const SizedBox(width: 8),
      Expanded(child: Text(title)),
      Text(ok ? 'مناسب' : 'غير مناسب', style: TextStyle(fontWeight: FontWeight.bold, color: ok ? Colors.green : Colors.red)),
    ]),
  );
}

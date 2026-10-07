import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const SudanSOApp());
}

// ============================================================================
// SUDAN SO
// Professional Solar System Engineering Calculator + Solar Market
// ============================================================================

class SudanSOApp extends StatelessWidget {
  const SudanSOApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF087F5B);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sudan SO',
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F8F7),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
            borderSide: BorderSide(color: Color(0xFFE1E7E4)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
            borderSide: BorderSide(color: seed, width: 1.5),
          ),
        ),
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
        ),
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox(),
        );
      },
      home: const MainShell(),
    );
  }
}

// ============================================================================
// DATA MODELS
// ============================================================================

class SolarPanel {
  final String brand;
  final String model;
  final double watt;
  final double voc;
  final double vmp;
  final double isc;
  final double imp;

  const SolarPanel({
    required this.brand,
    required this.model,
    required this.watt,
    required this.voc,
    required this.vmp,
    required this.isc,
    required this.imp,
  });

  String get name => '$brand $model';
}

class Inverter {
  final String brand;
  final String model;
  final String category;
  final String type;

  final double powerKw;
  final double batteryVoltage;

  final double maxPvPowerKw;
  final double maxPvVoc;

  final double mpptMin;
  final double mpptMax;
  final int mpptCount;

  final double maxPvCurrent;
  final double maxChargeCurrent;
  final double maxDischargeCurrent;

  final double efficiency;
  final String ipRating;
  final String officialUrl;

  const Inverter({
    required this.brand,
    required this.model,
    required this.category,
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
    required this.officialUrl,
  });

  String get name => '$brand $model';
}

class LoadItem {
  String name;
  double power;
  int quantity;
  double hours;

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
  final int series;
  final int parallel;
  final int totalPanels;

  final double arrayPowerKw;
  final double vmp;
  final double voc;
  final double coldVoc;
  final double hotVmp;

  final double arrayIsc;
  final double currentPerMppt;

  const PvConfiguration({
    required this.series,
    required this.parallel,
    required this.totalPanels,
    required this.arrayPowerKw,
    required this.vmp,
    required this.voc,
    required this.coldVoc,
    required this.hotVmp,
    required this.arrayIsc,
    required this.currentPerMppt,
  });
}

class CalculationResult {
  final double dailyWh;
  final double peakW;

  final double pvRequiredKw;
  final int requiredPanels;

  final double batteryKwh;
  final double batteryAh;

  final double batteryLoadCurrent;
  final double estimatedChargeCurrent;

  final PvConfiguration pv;

  final bool pvPowerOk;
  final bool coldVocOk;
  final bool mpptLowOk;
  final bool mpptHighOk;
  final bool mpptCurrentOk;
  final bool panelCountOk;
  final bool inverterPowerOk;
  final bool batteryVoltageOk;

  const CalculationResult({
    required this.dailyWh,
    required this.peakW,
    required this.pvRequiredKw,
    required this.requiredPanels,
    required this.batteryKwh,
    required this.batteryAh,
    required this.batteryLoadCurrent,
    required this.estimatedChargeCurrent,
    required this.pv,
    required this.pvPowerOk,
    required this.coldVocOk,
    required this.mpptLowOk,
    required this.mpptHighOk,
    required this.mpptCurrentOk,
    required this.panelCountOk,
    required this.inverterPowerOk,
    required this.batteryVoltageOk,
  });

  bool get allOk =>
      pvPowerOk &&
      coldVocOk &&
      mpptLowOk &&
      mpptHighOk &&
      mpptCurrentOk &&
      panelCountOk &&
      inverterPowerOk &&
      batteryVoltageOk;
}

// ============================================================================
// DATABASE
// IMPORTANT: These are design-reference values.
// Always verify the exact device datasheet before installation.
// ============================================================================

const List<SolarPanel> solarPanels = [
  SolarPanel(
    brand: 'Generic',
    model: '550W',
    watt: 550,
    voc: 52.4,
    vmp: 42.3,
    isc: 14.0,
    imp: 13.0,
  ),
  SolarPanel(
    brand: 'Generic',
    model: '590W',
    watt: 590,
    voc: 49.8,
    vmp: 41.7,
    isc: 14.8,
    imp: 14.1,
  ),
];

const List<Inverter> inverters = [
  Inverter(
    brand: 'Huawei',
    model: 'SUN2000-5KTL-L1',
    category: 'ممتازة',
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
    efficiency: 0.984,
    ipRating: 'IP65',
    officialUrl: 'https://solar.huawei.com/',
  ),
  Inverter(
    brand: 'Deye',
    model: 'SUN-5K-SG04LP1',
    category: 'ممتازة',
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
    efficiency: 0.976,
    ipRating: 'IP65',
    officialUrl: 'https://www.deyeess.com/',
  ),
  Inverter(
    brand: 'Growatt',
    model: 'SPF 5000 ES',
    category: 'متوسطة',
    type: 'Off-Grid',
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
    efficiency: 0.93,
    ipRating: 'IP20',
    officialUrl: 'https://www.growatt.com/',
  ),
  Inverter(
    brand: 'Solis',
    model: 'S5-EH1P5K-L',
    category: 'ممتازة',
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
    efficiency: 0.977,
    ipRating: 'IP65',
    officialUrl: 'https://www.solisinverters.com/',
  ),
  Inverter(
    brand: 'MUST',
    model: 'PV18-5048',
    category: 'اقتصادية',
    type: 'Off-Grid',
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
    efficiency: 0.93,
    ipRating: 'IP21',
    officialUrl: 'https://www.mustpower.com/',
  ),
  Inverter(
    brand: 'Motoma',
    model: 'Hybrid 5kW',
    category: 'متوسطة',
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
    efficiency: 0.95,
    ipRating: 'IP65',
    officialUrl: 'https://www.motoma.com/',
  ),
  Inverter(
    brand: 'FelicitySolar',
    model: 'IVGM5KLP2G1',
    category: 'متوسطة',
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
    efficiency: 0.95,
    ipRating: 'IP65',
    officialUrl: 'https://www.felicitysolar.com/',
  ),
  Inverter(
    brand: 'GSB',
    model: '5kW 48V',
    category: 'اقتصادية',
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
    efficiency: 0.94,
    ipRating: 'IP21',
    officialUrl: '',
  ),
  Inverter(
    brand: 'Vackson',
    model: '5kW 48V',
    category: 'اقتصادية',
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
    efficiency: 0.93,
    ipRating: 'IP21',
    officialUrl: '',
  ),
  Inverter(
    brand: 'Megasun',
    model: '5kW 48V',
    category: 'اقتصادية',
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
    efficiency: 0.93,
    ipRating: 'IP21',
    officialUrl: '',
  ),
  Inverter(
    brand: 'Restar',
    model: '5kW 48V',
    category: 'اقتصادية',
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
    efficiency: 0.93,
    ipRating: 'IP21',
    officialUrl: '',
  ),
];

// ============================================================================
// ENGINEERING CALCULATOR
// ============================================================================

class SolarEngineering {
  static CalculationResult calculate({
    required List<LoadItem> loads,
    required SolarPanel panel,
    required Inverter inverter,
    required double psh,
    required double systemEfficiency,
    required double batteryEfficiency,
    required double dod,
    required double batteryVoltage,
    required double safetyMargin,
    required int series,
    required int parallel,
    required double coldVocFactor,
    required double hotVmpFactor,
  }) {
    final dailyWh = loads.fold<double>(
      0,
      (sum, load) => sum + load.dailyWh,
    );

    final peakW = loads.fold<double>(
      0,
      (sum, load) => sum + load.peakW,
    );

    final pvRequiredKw = dailyWh <= 0
        ? 0
        : dailyWh / (psh * 1000 * systemEfficiency);

    final requiredPanels = pvRequiredKw <= 0
        ? 0
        : (pvRequiredKw * 1000 / panel.watt).ceil();

    final batteryKwh = dailyWh <= 0
        ? 0
        : (dailyWh / 1000) /
            (dod * batteryEfficiency) *
            1.0;

    final batteryAh = batteryKwh <= 0
        ? 0
        : batteryKwh * 1000 / batteryVoltage;

    final batteryLoadCurrent = peakW <= 0
        ? 0
        : peakW / batteryVoltage / inverter.efficiency;

    final pvArrayKw = panel.watt * series * parallel / 1000;

    final vmp = panel.vmp * series;
    final voc = panel.voc * series;

    // Conservative engineering margins:
    // cold Voc may rise above STC Voc.
    // hot Vmp may fall below STC Vmp.
    final coldVoc = voc * coldVocFactor;
    final hotVmp = vmp * hotVmpFactor;

    final arrayIsc = panel.isc * parallel;

    final stringsPerMppt =
        math.max(1, (parallel + inverter.mpptCount - 1) ~/ inverter.mpptCount);

    final currentPerMppt = panel.isc * stringsPerMppt;

    final estimatedChargeCurrent = pvArrayKw <= 0
        ? 0
        : pvArrayKw * 1000 / batteryVoltage * inverter.efficiency;

    final pvPowerOk =
        requiredPanels == 0 || pvArrayKw <= inverter.maxPvPowerKw;

    final coldVocOk =
        requiredPanels == 0 || coldVoc <= inverter.maxPvVoc;

    final mpptLowOk =
        requiredPanels == 0 || hotVmp >= inverter.mpptMin;

    final mpptHighOk =
        requiredPanels == 0 || vmp <= inverter.mpptMax;

    final mpptCurrentOk =
        requiredPanels == 0 || currentPerMppt <= inverter.maxPvCurrent;

    final panelCountOk =
        requiredPanels == 0 || series * parallel >= requiredPanels;

    final inverterPowerOk =
        peakW <= 0 ||
        peakW * safetyMargin <= inverter.powerKw * 1000;

    final batteryVoltageOk =
        (batteryVoltage - inverter.batteryVoltage).abs() < 0.1;

    return CalculationResult(
      dailyWh: dailyWh,
      peakW: peakW,
      pvRequiredKw: pvRequiredKw,
      requiredPanels: requiredPanels,
      batteryKwh: batteryKwh,
      batteryAh: batteryAh,
      batteryLoadCurrent: batteryLoadCurrent,
      estimatedChargeCurrent: estimatedChargeCurrent,
      pv: PvConfiguration(
        series: series,
        parallel: parallel,
        totalPanels: series * parallel,
        arrayPowerKw: pvArrayKw,
        vmp: vmp,
        voc: voc,
        coldVoc: coldVoc,
        hotVmp: hotVmp,
        arrayIsc: arrayIsc,
        currentPerMppt: currentPerMppt,
      ),
      pvPowerOk: pvPowerOk,
      coldVocOk: coldVocOk,
      mpptLowOk: mpptLowOk,
      mpptHighOk: mpptHighOk,
      mpptCurrentOk: mpptCurrentOk,
      panelCountOk: panelCountOk,
      inverterPowerOk: inverterPowerOk,
      batteryVoltageOk: batteryVoltageOk,
    );
  }

  static PvConfiguration? suggestPvConfiguration({
    required SolarPanel panel,
    required Inverter inverter,
    required int requiredPanels,
    required double coldVocFactor,
    required double hotVmpFactor,
  }) {
    if (requiredPanels <= 0) return null;

    PvConfiguration? best;

    for (int series = 1; series <= 24; series++) {
      final vmp = panel.vmp * series;
      final voc = panel.voc * series;

      final coldVoc = voc * coldVocFactor;
      final hotVmp = vmp * hotVmpFactor;

      if (coldVoc > inverter.maxPvVoc) continue;
      if (hotVmp < inverter.mpptMin) continue;
      if (vmp > inverter.mpptMax) continue;

      for (int parallel = 1; parallel <= 12; parallel++) {
        final totalPanels = series * parallel;

        if (totalPanels < requiredPanels) continue;

        final powerKw =
            panel.watt * totalPanels / 1000;

        if (powerKw > inverter.maxPvPowerKw) continue;

        final stringsPerMppt =
            math.max(
              1,
              (parallel + inverter.mpptCount - 1) ~/
                  inverter.mpptCount,
            );

        final currentPerMppt =
            panel.isc * stringsPerMppt;

        if (currentPerMppt > inverter.maxPvCurrent) continue;

        final candidate = PvConfiguration(
          series: series,
          parallel: parallel,
          totalPanels: totalPanels,
          arrayPowerKw: powerKw,
          vmp: vmp,
          voc: voc,
          coldVoc: coldVoc,
          hotVmp: hotVmp,
          arrayIsc: panel.isc * parallel,
          currentPerMppt: currentPerMppt,
        );

        if (best == null) {
          best = candidate;
        } else {
          final bestExcess =
              best.totalPanels - requiredPanels;

          final candidateExcess =
              candidate.totalPanels - requiredPanels;

          if (candidateExcess < bestExcess) {
            best = candidate;
          } else if (candidateExcess == bestExcess &&
              candidate.totalPanels < best.totalPanels) {
            best = candidate;
          }
        }
      }
    }

    return best;
  }
}

// ============================================================================
// MAIN SHELL
// ============================================================================

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;

  late final List<Widget> pages = [
    HomePage(
      onCalculator: () => setState(() => index = 1),
      onMarket: () => setState(() => index = 2),
      onLocation: () => setState(() => index = 3),
    ),
    const CalculatorPage(),
    const MarketPage(),
    const LocationPage(),
    const MorePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: index,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) {
          setState(() => index = value);
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
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'السوق',
          ),
          NavigationDestination(
            icon: Icon(Icons.location_on_outlined),
            selectedIcon: Icon(Icons.location_on),
            label: 'الموقع',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz),
            selectedIcon: Icon(Icons.more),
            label: 'المزيد',
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// HOME
// ============================================================================

class HomePage extends StatelessWidget {
  final VoidCallback onCalculator;
  final VoidCallback onMarket;
  final VoidCallback onLocation;

  const HomePage({
    super.key,
    required this.onCalculator,
    required this.onMarket,
    required this.onLocation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sudan SO',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primaryContainer,
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.solar_power,
                  size: 42,
                  color: theme.colorScheme.onPrimary,
                ),
                const SizedBox(height: 18),
                Text(
                  'صمّم نظامك الشمسي بثقة',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'حساب الطاقة، الألواح، البطاريات والعاكسات مع فحوصات هندسية للتوافق.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimary.withValues(alpha: .9),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: onCalculator,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('ابدأ التصميم'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: MetricCard(
                  icon: Icons.solar_power,
                  title: 'ألواح',
                  value: '${solarPanels.length}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MetricCard(
                  icon: Icons.battery_charging_full,
                  title: 'عاكسات',
                  value: '${inverters.length}',
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          const SectionTitle(
            title: 'الأدوات الرئيسية',
            subtitle: 'كل ما تحتاجه للتصميم المبدئي',
          ),

          const SizedBox(height: 10),

          ToolCard(
            icon: Icons.calculate,
            title: 'حاسبة النظام الشمسي',
            subtitle: 'الأحمال • PV • البطاريات • MPPT',
            onTap: onCalculator,
          ),

          const SizedBox(height: 10),

          ToolCard(
            icon: Icons.storefront,
            title: 'سوق الطاقة الشمسية',
            subtitle: 'الألواح والعاكسات والمواصفات',
            onTap: onMarket,
          ),

          const SizedBox(height: 10),

          ToolCard(
            icon: Icons.location_on,
            title: 'حساب الميل والاتجاه',
            subtitle: 'تقدير الميل حسب خط العرض',
            onTap: onLocation,
          ),

          const SizedBox(height: 20),

          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SectionTitle(
                  title: 'منهجية الحساب',
                  subtitle: 'مصممة لتقليل أخطاء التصميم',
                ),
                SizedBox(height: 12),
                InfoBullet(
                  text: 'فحص جهد Voc مع هامش للبرد.',
                ),
                InfoBullet(
                  text: 'فحص Vmp عند انخفاض الجهد بسبب الحرارة.',
                ),
                InfoBullet(
                  text: 'فحص تيار الـMPPT لكل مدخل بشكل تقريبي.',
                ),
                InfoBullet(
                  text: 'فحص قدرة العاكس مع معامل أمان للحمل.',
                ),
                InfoBullet(
                  text: 'إظهار التحذيرات بدلاً من إعطاء نتيجة مضللة.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// CALCULATOR
// ============================================================================

class CalculatorPage extends StatefulWidget {
  final Inverter? initialInverter;
  final SolarPanel? initialPanel;

  const CalculatorPage({
    super.key,
    this.initialInverter,
    this.initialPanel,
  });

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  late SolarPanel selectedPanel;
  late Inverter selectedInverter;

  final List<LoadItem> loads = [];

  late final TextEditingController pshController;
  late final TextEditingController efficiencyController;
  late final TextEditingController batteryEfficiencyController;
  late final TextEditingController dodController;
  late final TextEditingController batteryVoltageController;
  late final TextEditingController safetyController;
  late final TextEditingController seriesController;
  late final TextEditingController parallelController;

  static const double coldVocFactor = 1.10;
  static const double hotVmpFactor = 0.85;

  @override
  void initState() {
    super.initState();

    selectedPanel =
        widget.initialPanel ?? solarPanels.first;

    selectedInverter =
        widget.initialInverter ?? inverters.first;

    pshController =
        TextEditingController(text: '5.5');

    efficiencyController =
        TextEditingController(text: '80');

    batteryEfficiencyController =
        TextEditingController(text: '95');

    dodController =
        TextEditingController(text: '80');

    batteryVoltageController =
        TextEditingController(
          text: selectedInverter.batteryVoltage.toStringAsFixed(0),
        );

    safetyController =
        TextEditingController(text: '1.25');

    seriesController =
        TextEditingController(text: '5');

    parallelController =
        TextEditingController(text: '2');
  }

  @override
  void dispose() {
    pshController.dispose();
    efficiencyController.dispose();
    batteryEfficiencyController.dispose();
    dodController.dispose();
    batteryVoltageController.dispose();
    safetyController.dispose();
    seriesController.dispose();
    parallelController.dispose();
    super.dispose();
  }

  double _number(
    TextEditingController controller,
    double fallback,
  ) {
    return double.tryParse(
          controller.text.trim().replaceAll(',', '.'),
        ) ??
        fallback;
  }

  int _integer(
    TextEditingController controller,
    int fallback,
  ) {
    return int.tryParse(controller.text.trim()) ??
        fallback;
  }

  double get psh =>
      _number(pshController, 5.5).clamp(1, 10);

  double get systemEfficiency =>
      (_number(efficiencyController, 80) / 100)
          .clamp(.5, .98);

  double get batteryEfficiency =>
      (_number(batteryEfficiencyController, 95) / 100)
          .clamp(.7, .99);

  double get dod =>
      (_number(dodController, 80) / 100)
          .clamp(.5, .95);

  double get batteryVoltage =>
      _number(
        batteryVoltageController,
        selectedInverter.batteryVoltage,
      );

  double get safetyMargin =>
      _number(safetyController, 1.25)
          .clamp(1, 2);

  int get series =>
      _integer(seriesController, 1).clamp(1, 24);

  int get parallel =>
      _integer(parallelController, 1).clamp(1, 12);

  CalculationResult get result {
    return SolarEngineering.calculate(
      loads: loads,
      panel: selectedPanel,
      inverter: selectedInverter,
      psh: psh,
      systemEfficiency: systemEfficiency,
      batteryEfficiency: batteryEfficiency,
      dod: dod,
      batteryVoltage: batteryVoltage,
      safetyMargin: safetyMargin,
      series: series,
      parallel: parallel,
      coldVocFactor: coldVocFactor,
      hotVmpFactor: hotVmpFactor,
    );
  }

  void _recalculate() {
    setState(() {});
  }

  void _autoConfigure() {
    final current = result;

    final suggested =
        SolarEngineering.suggestPvConfiguration(
      panel: selectedPanel,
      inverter: selectedInverter,
      requiredPanels: current.requiredPanels,
      coldVocFactor: coldVocFactor,
      hotVmpFactor: hotVmpFactor,
    );

    if (suggested == null) {
      _showMessage(
        'لم يتم العثور على توصيل PV متوافق بالكامل مع حدود هذا العاكس واللوح.',
        error: true,
      );
      return;
    }

    seriesController.text =
        suggested.series.toString();

    parallelController.text =
        suggested.parallel.toString();

    setState(() {});

    _showMessage(
      'تم اقتراح ${suggested.series}S × ${suggested.parallel}P = ${suggested.totalPanels} لوح.',
    );
  }

  void _showMessage(
    String message, {
    bool error = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            error ? Colors.red.shade700 : null,
      ),
    );
  }

  void _addLoad() {
    _showLoadDialog();
  }

  void _editLoad(int index) {
    _showLoadDialog(
      index: index,
      existing: loads[index],
    );
  }

  void _deleteLoad(int index) {
    setState(() {
      loads.removeAt(index);
    });
  }

  Future<void> _showLoadDialog({
    int? index,
    LoadItem? existing,
  }) async {
    final nameController = TextEditingController(
      text: existing?.name ?? '',
    );

    final powerController = TextEditingController(
      text: existing?.power.toString() ?? '',
    );

    final quantityController = TextEditingController(
      text: existing?.quantity.toString() ?? '1',
    );

    final hoursController = TextEditingController(
      text: existing?.hours.toString() ?? '1',
    );

    String? error;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                index == null
                    ? 'إضافة حمل'
                    : 'تعديل الحمل',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: null,
                      decoration: const InputDecoration(
                        labelText: 'قالب سريع',
                        prefixIcon: Icon(Icons.flash_on),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'ثلاجة',
                          child: Text('ثلاجة - 150W'),
                        ),
                        DropdownMenuItem(
                          value: 'مروحة',
                          child: Text('مروحة - 80W'),
                        ),
                        DropdownMenuItem(
                          value: 'مكيف',
                          child: Text('مكيف - 1200W'),
                        ),
                        DropdownMenuItem(
                          value: 'تلفزيون',
                          child: Text('تلفزيون - 120W'),
                        ),
                        DropdownMenuItem(
                          value: 'إضاءة',
                          child: Text('إضاءة - 20W'),
                        ),
                        DropdownMenuItem(
                          value: 'غسالة',
                          child: Text('غسالة - 500W'),
                        ),
                        DropdownMenuItem(
                          value: 'مضخة',
                          child: Text('مضخة - 750W'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;

                        final presets = {
                          'ثلاجة': 150,
                          'مروحة': 80,
                          'مكيف': 1200,
                          'تلفزيون': 120,
                          'إضاءة': 20,
                          'غسالة': 500,
                          'مضخة': 750,
                        };

                        nameController.text = value;
                        powerController.text =
                            presets[value]!.toString();
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'اسم الحمل',
                        prefixIcon: Icon(Icons.devices),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: powerController,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'قدرة الجهاز W',
                        prefixIcon: Icon(Icons.bolt),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'العدد',
                        prefixIcon: Icon(Icons.numbers),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: hoursController,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'ساعات التشغيل يومياً',
                        prefixIcon: Icon(Icons.schedule),
                      ),
                    ),
                    if (error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        error!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(dialogContext, false),
                  child: const Text('إلغاء'),
                ),
                FilledButton(
                  onPressed: () {
                    final name =
                        nameController.text.trim();

                    final power = double.tryParse(
                      powerController.text
                          .trim()
                          .replaceAll(',', '.'),
                    );

                    final quantity =
                        int.tryParse(
                          quantityController.text.trim(),
                        );

                    final hours =
                        double.tryParse(
                          hoursController.text
                              .trim()
                              .replaceAll(',', '.'),
                        );

                    if (name.isEmpty ||
                        power == null ||
                        power <= 0 ||
                        quantity == null ||
                        quantity <= 0 ||
                        hours == null ||
                        hours <= 0 ||
                        hours > 24) {
                      setDialogState(() {
                        error =
                            'تحقق من البيانات. الساعات يجب أن تكون بين 0 و24.';
                      });
                      return;
                    }

                    final item = LoadItem(
                      name: name,
                      power: power,
                      quantity: quantity,
                      hours: hours,
                    );

                    if (index == null) {
                      loads.add(item);
                    } else {
                      loads[index] = item;
                    }

                    Navigator.pop(
                      dialogContext,
                      true,
                    );
                  },
                  child: const Text('حفظ'),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    powerController.dispose();
    quantityController.dispose();
    hoursController.dispose();

    if (saved == true) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = result;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'التصميم الشمسي',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'اقتراح تلقائي',
            onPressed: _autoConfigure,
            icon: const Icon(Icons.auto_awesome),
          ),
          IconButton(
            tooltip: 'إعادة ضبط',
            onPressed: () {
              setState(() {
                loads.clear();
                seriesController.text = '5';
                parallelController.text = '2';
              });
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle(
                  title: '1. مواصفات النظام',
                  subtitle:
                      'اختر اللوح والعاكس وحدد ظروف التصميم',
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<SolarPanel>(
                  initialValue: selectedPanel,
                  decoration: const InputDecoration(
                    labelText: 'اللوح الشمسي',
                    prefixIcon: Icon(Icons.solar_power),
                  ),
                  items: solarPanels.map((panel) {
                    return DropdownMenuItem(
                      value: panel,
                      child: Text(
                        '${panel.name} — ${panel.watt.toStringAsFixed(0)}W',
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      selectedPanel = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<Inverter>(
                  initialValue: selectedInverter,
                  decoration: const InputDecoration(
                    labelText: 'العاكس',
                    prefixIcon: Icon(Icons.electrical_services),
                  ),
                  items: inverters.map((inverter) {
                    return DropdownMenuItem(
                      value: inverter,
                      child: Text(
                        '${inverter.name} — ${inverter.powerKw.toStringAsFixed(1)}kW',
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      selectedInverter = value;
                      batteryVoltageController.text =
                          value.batteryVoltage
                              .toStringAsFixed(0);
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle(
                  title: '2. ظروف التصميم',
                  subtitle:
                      'القيم الافتراضية مناسبة كبداية ويجب تعديلها حسب الموقع',
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: NumberField(
                        controller: pshController,
                        label: 'PSH',
                        suffix: 'ساعة',
                        onChanged: (_) => _recalculate(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: NumberField(
                        controller: efficiencyController,
                        label: 'كفاءة النظام',
                        suffix: '%',
                        onChanged: (_) => _recalculate(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: NumberField(
                        controller:
                            batteryEfficiencyController,
                        label: 'كفاءة البطارية',
                        suffix: '%',
                        onChanged: (_) => _recalculate(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: NumberField(
                        controller: dodController,
                        label: 'DoD',
                        suffix: '%',
                        onChanged: (_) => _recalculate(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: NumberField(
                        controller:
                            batteryVoltageController,
                        label: 'جهد البطارية',
                        suffix: 'V',
                        onChanged: (_) => _recalculate(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: NumberField(
                        controller: safetyController,
                        label: 'معامل أمان الحمل',
                        suffix: '×',
                        onChanged: (_) => _recalculate(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withValues(alpha: .35),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'فحص الجهد يستخدم تقريباً +10% لـVoc في البرودة '
                    'و-15% لـVmp في الحرارة. هذه قيم محافظة وليست بديلاً عن معاملات الحرارة الموجودة في Datasheet.',
                    style: TextStyle(height: 1.5),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionTitle(
                  title: '3. الأحمال',
                  subtitle:
                      '${loads.length} حمل • ${r.dailyWh.toStringAsFixed(0)} Wh/day',
                  trailing: FilledButton.icon(
                    onPressed: _addLoad,
                    icon: const Icon(Icons.add),
                    label: const Text('إضافة'),
                  ),
                ),
                const SizedBox(height: 12),
                if (loads.isEmpty)
                  EmptyState(
                    icon: Icons.electrical_services,
                    title: 'لم تتم إضافة أحمال',
                    subtitle:
                        'أضف الأحمال الفعلية للحصول على تصميم صحيح.',
                    action: FilledButton.icon(
                      onPressed: _addLoad,
                      icon: const Icon(Icons.add),
                      label: const Text('إضافة أول حمل'),
                    ),
                  )
                else
                  Column(
                    children: [
                      ...List.generate(
                        loads.length,
                        (index) {
                          final load = loads[index];

                          return Padding(
                            padding:
                                const EdgeInsets.only(bottom: 8),
                            child: Container(
                              padding:
                                  const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context)
                                      .dividerColor,
                                ),
                                borderRadius:
                                    BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    child: const Icon(
                                      Icons.bolt,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          load.name,
                                          style:
                                              const TextStyle(
                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          '${load.power.toStringAsFixed(0)}W × ${load.quantity} × ${load.hours.toStringAsFixed(1)}h = ${load.dailyWh.toStringAsFixed(0)}Wh/day',
                                          style:
                                              Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () =>
                                        _editLoad(index),
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () =>
                                        _deleteLoad(index),
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionTitle(
                  title: '4. توصيل الألواح',
                  subtitle:
                      'المقترح تلقائياً أدق من اختيار أرقام عشوائية',
                  trailing: OutlinedButton.icon(
                    onPressed:
                        r.requiredPanels == 0
                            ? null
                            : _autoConfigure,
                    icon: const Icon(
                      Icons.auto_awesome,
                    ),
                    label: const Text('اقتراح'),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: NumberField(
                        controller: seriesController,
                        label: 'Series',
                        suffix: 'ألواح',
                        onChanged: (_) => _recalculate(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: NumberField(
                        controller: parallelController,
                        label: 'Parallel',
                        suffix: 'مسارات',
                        onChanged: (_) => _recalculate(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          const SectionTitle(
            title: '5. النتائج',
            subtitle:
                'نتائج التصميم المبدئي بناءً على المدخلات الحالية',
          ),

          const SizedBox(height: 10),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.55,
            children: [
              ResultCard(
                icon: Icons.bolt,
                title: 'الطاقة اليومية',
                value:
                    '${r.dailyWh.toStringAsFixed(0)} Wh',
              ),
              ResultCard(
                icon: Icons.speed,
                title: 'الحمل الأقصى',
                value:
                    '${r.peakW.toStringAsFixed(0)} W',
              ),
              ResultCard(
                icon: Icons.solar_power,
                title: 'PV المطلوبة',
                value:
                    '${r.pvRequiredKw.toStringAsFixed(2)} kW',
              ),
              ResultCard(
                icon: Icons.grid_view,
                title: 'عدد الألواح',
                value:
                    '${r.requiredPanels}',
              ),
              ResultCard(
                icon: Icons.battery_full,
                title: 'البطارية',
                value:
                    '${r.batteryKwh.toStringAsFixed(2)} kWh',
              ),
              ResultCard(
                icon: Icons.battery_charging_full,
                title: 'البنك',
                value:
                    '${r.batteryAh.toStringAsFixed(0)} Ah',
              ),
            ],
          ),

          const SizedBox(height: 14),

          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle(
                  title: '6. تحليل المصفوفة الشمسية',
                  subtitle:
                      'الفولت والتيار والقدرة بعد تطبيق التوصيل',
                ),
                const SizedBox(height: 12),
                SpecRow(
                  label: 'التوصيل',
                  value:
                      '${r.pv.series}S × ${r.pv.parallel}P',
                ),
                SpecRow(
                  label: 'إجمالي الألواح',
                  value:
                      '${r.pv.totalPanels} لوح',
                ),
                SpecRow(
                  label: 'قدرة المصفوفة',
                  value:
                      '${r.pv.arrayPowerKw.toStringAsFixed(2)} kW',
                ),
                SpecRow(
                  label: 'Vmp عند STC',
                  value:
                      '${r.pv.vmp.toStringAsFixed(1)} V',
                ),
                SpecRow(
                  label: 'Vmp تقديري في الحرارة',
                  value:
                      '${r.pv.hotVmp.toStringAsFixed(1)} V',
                ),
                SpecRow(
                  label: 'Voc عند STC',
                  value:
                      '${r.pv.voc.toStringAsFixed(1)} V',
                ),
                SpecRow(
                  label: 'Voc محافظ للبرد',
                  value:
                      '${r.pv.coldVoc.toStringAsFixed(1)} V',
                ),
                SpecRow(
                  label: 'Isc للمصفوفة',
                  value:
                      '${r.pv.arrayIsc.toStringAsFixed(1)} A',
                ),
                SpecRow(
                  label: 'Isc تقديري / MPPT',
                  value:
                      '${r.pv.currentPerMppt.toStringAsFixed(1)} A',
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle(
                  title: '7. البطارية والعاكس',
                  subtitle:
                      'التيارات المطلوبة تقديرية لأغراض التصميم',
                ),
                const SizedBox(height: 12),
                SpecRow(
                  label: 'تيار البطارية عند الحمل',
                  value:
                      '${r.batteryLoadCurrent.toStringAsFixed(1)} A',
                ),
                SpecRow(
                  label: 'تيار الشحن التقديري',
                  value:
                      '${r.estimatedChargeCurrent.toStringAsFixed(1)} A',
                ),
                SpecRow(
                  label: 'أقصى شحن للعاكس',
                  value:
                      '${selectedInverter.maxChargeCurrent.toStringAsFixed(0)} A',
                ),
                SpecRow(
                  label: 'أقصى تفريغ للعاكس',
                  value:
                      '${selectedInverter.maxDischargeCurrent.toStringAsFixed(0)} A',
                ),
                SpecRow(
                  label: 'كفاءة العاكس',
                  value:
                      '${(selectedInverter.efficiency * 100).toStringAsFixed(1)}%',
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionTitle(
                  title: '8. فحص التوافق الهندسي',
                  subtitle: r.allOk
                      ? 'التوصيل الحالي يجتاز الفحوصات الأساسية'
                      : 'يوجد بند أو أكثر يحتاج إلى تعديل',
                  trailing: Icon(
                    r.allOk
                        ? Icons.verified
                        : Icons.warning_amber_rounded,
                    color: r.allOk
                        ? Colors.green
                        : Colors.orange,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 12),

                CheckRow(
                  label: 'قدرة PV ضمن حد العاكس',
                  ok: r.pvPowerOk,
                  detail:
                      '${r.pv.arrayPowerKw.toStringAsFixed(2)} / ${selectedInverter.maxPvPowerKw.toStringAsFixed(2)} kW',
                ),

                CheckRow(
                  label: 'Voc البارد ضمن الحد',
                  ok: r.coldVocOk,
                  detail:
                      '${r.pv.coldVoc.toStringAsFixed(1)} / ${selectedInverter.maxPvVoc.toStringAsFixed(0)} V',
                ),

                CheckRow(
                  label: 'Vmp عند الحرارة فوق MPPT الأدنى',
                  ok: r.mpptLowOk,
                  detail:
                      '${r.pv.hotVmp.toStringAsFixed(1)} / ${selectedInverter.mpptMin.toStringAsFixed(0)} V',
                ),

                CheckRow(
                  label: 'Vmp ضمن MPPT الأعلى',
                  ok: r.mpptHighOk,
                  detail:
                      '${r.pv.vmp.toStringAsFixed(1)} / ${selectedInverter.mpptMax.toStringAsFixed(0)} V',
                ),

                CheckRow(
                  label: 'تيار MPPT',
                  ok: r.mpptCurrentOk,
                  detail:
                      '${r.pv.currentPerMppt.toStringAsFixed(1)} / ${selectedInverter.maxPvCurrent.toStringAsFixed(1)} A',
                ),

                CheckRow(
                  label: 'عدد الألواح يحقق الطاقة المطلوبة',
                  ok: r.panelCountOk,
                  detail:
                      '${r.pv.totalPanels} / ${r.requiredPanels} لوح',
                ),

                CheckRow(
                  label: 'قدرة العاكس مع معامل الأمان',
                  ok: r.inverterPowerOk,
                  detail:
                      '${(r.peakW * safetyMargin).toStringAsFixed(0)} / ${(selectedInverter.powerKw * 1000).toStringAsFixed(0)} W',
                ),

                CheckRow(
                  label: 'جهد البطارية مطابق للعاكس',
                  ok: r.batteryVoltageOk,
                  detail:
                      '${batteryVoltage.toStringAsFixed(0)} / ${selectedInverter.batteryVoltage.toStringAsFixed(0)} V',
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          AppCard(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const SectionTitle(
                  title: 'ملاحظة هندسية',
                  subtitle: 'قبل التنفيذ الفعلي',
                ),
                const SizedBox(height: 10),
                Text(
                  'هذه الحاسبة أداة تصميم مبدئي. يجب قبل التنفيذ مراجعة '
                  'Datasheet الفعلي للعاكس واللوح والبطارية، معاملات الحرارة، '
                  'أقصى تيار لكل MPPT، توزيع السلاسل على MPPTs، مقاطع الكابلات، '
                  'هبوط الجهد، الحمايات DC/AC، التأريض، وخصائص الأحمال الحركية.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(height: 1.6),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

// ============================================================================
// MARKET
// ============================================================================

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  final TextEditingController searchController =
      TextEditingController();

  String category = 'الكل';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<Inverter> get filtered {
    final search =
        searchController.text.trim().toLowerCase();

    return inverters.where((item) {
      final categoryMatch =
          category == 'الكل' ||
          item.category == category;

      final searchMatch =
          search.isEmpty ||
          item.name.toLowerCase().contains(search) ||
          item.brand.toLowerCase().contains(search) ||
          item.model.toLowerCase().contains(search);

      return categoryMatch && searchMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final products = filtered;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'السوق',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'ابحث عن العاكس أو الماركة...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchController.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        searchController.clear();
                        setState(() {});
                      },
                      icon: const Icon(Icons.clear),
                    ),
            ),
          ),

          const SizedBox(height: 12),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                'الكل',
                'ممتازة',
                'متوسطة',
                'اقتصادية',
              ].map((item) {
                return Padding(
                  padding:
                      const EdgeInsets.only(left: 8),
                  child: ChoiceChip(
                    label: Text(item),
                    selected: category == item,
                    onSelected: (_) {
                      setState(() {
                        category = item;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            '${products.length} منتج',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          if (products.isEmpty)
            const EmptyState(
              icon: Icons.search_off,
              title: 'لا توجد نتائج',
              subtitle:
                  'جرّب تغيير البحث أو التصنيف.',
            )
          else
            ...products.map(
              (product) => Padding(
                padding:
                    const EdgeInsets.only(bottom: 10),
                child: ProductCard(
                  inverter: product,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Inverter inverter;

  const ProductCard({
    super.key,
    required this.inverter,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ProductDetailsPage(
                inverter: inverter,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer,
                  borderRadius:
                      BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.electrical_services,
                  color: Theme.of(context)
                      .colorScheme
                      .primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      inverter.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${inverter.powerKw.toStringAsFixed(1)}kW • ${inverter.batteryVoltage.toStringAsFixed(0)}V • ${inverter.mpptCount} MPPT',
                    ),
                    const SizedBox(height: 5),
                    Text(
                      inverter.category,
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_left,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// PRODUCT DETAILS
// ============================================================================

class ProductDetailsPage extends StatelessWidget {
  final Inverter inverter;

  const ProductDetailsPage({
    super.key,
    required this.inverter,
  });

  Future<void> _openOfficial() async {
    if (inverter.officialUrl.isEmpty) return;

    final uri = Uri.parse(inverter.officialUrl);

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل المنتج'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 38,
                  child: const Icon(
                    Icons.electrical_services,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  inverter.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${inverter.type} • ${inverter.category}',
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  CalculatorPage(
                                initialInverter:
                                    inverter,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.calculate,
                        ),
                        label:
                            const Text('استخدم في الحاسبة'),
                      ),
                    ),
                  ],
                ),
                if (inverter.officialUrl.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _openOfficial,
                    icon: const Icon(
                      Icons.open_in_new,
                    ),
                    label: const Text(
                      'الموقع الرسمي',
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 14),

          AppCard(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const SectionTitle(
                  title: 'المواصفات الكهربائية',
                  subtitle: 'بيانات مرجعية للتصميم',
                ),
                const SizedBox(height: 12),
                SpecRow(
                  label: 'قدرة العاكس',
                  value:
                      '${inverter.powerKw.toStringAsFixed(1)} kW',
                ),
                SpecRow(
                  label: 'جهد البطارية',
                  value:
                      '${inverter.batteryVoltage.toStringAsFixed(0)} V',
                ),
                SpecRow(
                  label: 'أقصى PV',
                  value:
                      '${inverter.maxPvPowerKw.toStringAsFixed(1)} kW',
                ),
                SpecRow(
                  label: 'أقصى Voc',
                  value:
                      '${inverter.maxPvVoc.toStringAsFixed(0)} V',
                ),
                SpecRow(
                  label: 'MPPT',
                  value:
                      '${inverter.mpptMin.toStringAsFixed(0)}–${inverter.mpptMax.toStringAsFixed(0)} V',
                ),
                SpecRow(
                  label: 'عدد MPPT',
                  value:
                      '${inverter.mpptCount}',
                ),
                SpecRow(
                  label: 'تيار PV',
                  value:
                      '${inverter.maxPvCurrent.toStringAsFixed(1)} A',
                ),
                SpecRow(
                  label: 'أقصى شحن',
                  value:
                      '${inverter.maxChargeCurrent.toStringAsFixed(0)} A',
                ),
                SpecRow(
                  label: 'أقصى تفريغ',
                  value:
                      '${inverter.maxDischargeCurrent.toStringAsFixed(0)} A',
                ),
                SpecRow(
                  label: 'الكفاءة',
                  value:
                      '${(inverter.efficiency * 100).toStringAsFixed(1)}%',
                ),
                SpecRow(
                  label: 'الحماية',
                  value: inverter.ipRating,
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          AppCard(
            child: Text(
              'تنبيه: لا تعتمد هذه البيانات وحدها في التنفيذ. '
              'يجب مطابقة رقم الموديل والمواصفات مع Datasheet '
              'النسخة الموجودة فعلياً قبل تحديد السلاسل والحمايات والكابلات.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                    height: 1.6,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// LOCATION / TILT
// ============================================================================

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() =>
      _LocationPageState();
}

class _LocationPageState
    extends State<LocationPage> {
  late final TextEditingController latitudeController;

  @override
  void initState() {
    super.initState();

    latitudeController =
        TextEditingController(text: '15.5007');
  }

  @override
  void dispose() {
    latitudeController.dispose();
    super.dispose();
  }

  double get latitude =>
      (double.tryParse(
            latitudeController.text
                .trim()
                .replaceAll(',', '.'),
          ) ??
          15.5007)
          .clamp(-90, 90);

  double get annualTilt =>
      latitude.abs();

  double get summerTilt =>
      math.max(0, latitude.abs() - 15);

  double get winterTilt =>
      latitude.abs() + 15;

  String get direction =>
      latitude >= 0 ? 'الجنوب' : 'الشمال';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الموقع والميل',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const SectionTitle(
                  title: 'خط العرض',
                  subtitle:
                      'أدخل خط العرض بالموجب للشمال والسالب للجنوب',
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: latitudeController,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'خط العرض',
                    suffixText: '°',
                    prefixIcon:
                        Icon(Icons.location_on),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.5,
            children: [
              ResultCard(
                icon: Icons.explore,
                title: 'الاتجاه التقريبي',
                value: direction,
              ),
              ResultCard(
                icon: Icons.solar_power,
                title: 'الميل السنوي',
                value:
                    '${annualTilt.toStringAsFixed(1)}°',
              ),
              ResultCard(
                icon: Icons.wb_sunny,
                title: 'ميل الصيف',
                value:
                    '${summerTilt.toStringAsFixed(1)}°',
              ),
              ResultCard(
                icon: Icons.ac_unit,
                title: 'ميل الشتاء',
                value:
                    '${winterTilt.toStringAsFixed(1)}°',
              ),
            ],
          ),

          const SizedBox(height: 14),

          AppCard(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const SectionTitle(
                  title: 'قاعدة هندسية تقريبية',
                  subtitle:
                      'ليست بديلاً عن تحليل الشمس والظلال',
                ),
                const SizedBox(height: 12),
                Text(
                  'للمواقع في النصف الشمالي يكون الاتجاه العام للألواح نحو الجنوب، '
                  'وفي النصف الجنوبي نحو الشمال. الميل السنوي الثابت يمكن تقديره '
                  'مبدئياً من قيمة خط العرض.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(height: 1.6),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          AppCard(
            child: Text(
              'للتصميم الاحترافي النهائي يجب دراسة الظلال، '
              'مسار الشمس، زاوية السطح، المساحة المتاحة، '
              'اتجاه السطح، ودرجة الحرارة المحلية.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                    height: 1.6,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// MORE
// ============================================================================

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'المزيد',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ToolCard(
            icon: Icons.person_outline,
            title: 'عن التطبيق',
            subtitle:
                'Sudan SO والمطور والفكرة',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AboutPage(),
                ),
              );
            },
          ),

          const SizedBox(height: 10),

          ToolCard(
            icon: Icons.calculate_outlined,
            title: 'الحاسبة',
            subtitle:
                'فتح حاسبة التصميم مباشرة',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const CalculatorPage(),
                ),
              );
            },
          ),

          const SizedBox(height: 10),

          ToolCard(
            icon: Icons.storefront_outlined,
            title: 'السوق',
            subtitle:
                'استعراض العاكسات المتوفرة',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const MarketPage(),
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          AppCard(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sudan SO',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Solar Engineering & Design',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  'نسخة احترافية للحسابات الشمسية المبدئية.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// ABOUT
// ============================================================================

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  Future<void> _openWhatsApp() async {
    final uri = Uri.parse(
      'https://wa.me/249916537047?text=${Uri.encodeComponent(
        'السلام عليكم، أريد الاستفسار عن تصميم نظام شمسي.',
      )}',
    );

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('عن التطبيق'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .primaryContainer,
                  child: Icon(
                    Icons.solar_power,
                    size: 45,
                    color: Theme.of(context)
                        .colorScheme
                        .primary,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Sudan SO',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Solar Engineering Calculator',
                ),
                const SizedBox(height: 20),
                const Text(
                  'تطبيق متخصص في الحسابات والتصميمات '
                  'المبدئية لأنظمة الطاقة الشمسية، '
                  'مع أدوات لحساب الأحمال، الألواح، '
                  'البطاريات والعاكسات وفحص التوافق الكهربائي.',
                  textAlign: TextAlign.center,
                  style: TextStyle(height: 1.7),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          AppCard(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const SectionTitle(
                  title: 'المهندس',
                  subtitle: 'تطوير ومحتوى التطبيق',
                ),
                const SizedBox(height: 12),
                const Text(
                  'حمزة الطيب',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'مهتم بالطاقة الشمسية ولديه خبرة واسعة '
                  'في مجال أنظمة الطاقة الشمسية والحلول '
                  'الكهربائية المرتبطة بها.',
                  style: TextStyle(height: 1.6),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _openWhatsApp,
                    icon: const Icon(
                      Icons.chat,
                    ),
                    label: const Text(
                      'تواصل عبر واتساب',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    '+249 91 653 7047',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          AppCard(
            child: const Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                SectionTitle(
                  title: 'تنبيه',
                  subtitle: 'الاستخدام الهندسي',
                ),
                SizedBox(height: 10),
                Text(
                  'نتائج التطبيق هي نتائج تصميم مبدئي. '
                  'أي تنفيذ فعلي يجب أن يعتمد على Datasheet '
                  'الأجهزة الحقيقية، القياسات الميدانية، '
                  'الكود الكهربائي المحلي، ومتطلبات الحماية.',
                  style: TextStyle(height: 1.6),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Center(
            child: Text(
              'Sudan SO © 2026',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// REUSABLE UI
// ============================================================================

class AppCard extends StatelessWidget {
  final Widget child;

  const AppCard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const SectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                        height: 1.4,
                      ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class MetricCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const MetricCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Theme.of(context)
                .colorScheme
                .primary,
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(title),
        ],
      ),
    );
  }
}

class ResultCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const ResultCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 22,
              color: Theme.of(context)
                  .colorScheme
                  .primary,
            ),
            const Spacer(),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class ToolCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const ToolCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer,
                  borderRadius:
                      BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context)
                      .colorScheme
                      .primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left),
            ],
          ),
        ),
      ),
    );
  }
}

class NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String suffix;
  final ValueChanged<String>? onChanged;

  const NumberField({
    super.key,
    required this.controller,
    required this.label,
    required this.suffix,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType:
          const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
      ),
    );
  }
}

class SpecRow extends StatelessWidget {
  final String label;
  final String value;

  const SpecRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CheckRow extends StatelessWidget {
  final String label;
  final bool ok;
  final String detail;

  const CheckRow({
    super.key,
    required this.label,
    required this.ok,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        ok ? Colors.green : Colors.red;

    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            ok
                ? Icons.check_circle
                : Icons.cancel,
            color: color,
            size: 23,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 42,
            color: Theme.of(context)
                .colorScheme
                .primary,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[
            const SizedBox(height: 14),
            action!,
          ],
        ],
      ),
    );
  }
}

class InfoBullet extends StatelessWidget {
  final String text;

  const InfoBullet({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 20,
            color: Theme.of(context)
                .colorScheme
                .primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
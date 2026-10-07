import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const SudanSOApp());
}

// ============================================================
// SUDAN SO
// Solar Energy Calculator + Solar Market
// Engineering Edition
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
        colorSchemeSeed: const Color(0xFF087F5B),
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF6F8F7),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
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
            borderSide: BorderSide(
              color: Color(0xFF087F5B),
              width: 2,
            ),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(18),
            ),
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

// ============================================================
// ENUMS
// ============================================================

enum BatteryType {
  lithium,
  agm,
  fld,
}

extension BatteryTypeExtension on BatteryType {
  String get label {
    switch (this) {
      case BatteryType.lithium:
        return 'Lithium';
      case BatteryType.agm:
        return 'AGM';
      case BatteryType.fld:
        return 'FLD';
    }
  }

  double get defaultEfficiency {
    switch (this) {
      case BatteryType.lithium:
        return 0.95;
      case BatteryType.agm:
        return 0.90;
      case BatteryType.fld:
        return 0.85;
    }
  }

  double get defaultDod {
    switch (this) {
      case BatteryType.lithium:
        return 0.80;
      case BatteryType.agm:
        return 0.50;
      case BatteryType.fld:
        return 0.50;
    }
  }

  String get description {
    switch (this) {
      case BatteryType.lithium:
        return 'كفاءة أعلى وعمر دوري أفضل، مع ضرورة توافق BMS.';
      case BatteryType.agm:
        return 'بطارية رصاص محكمة، مناسبة للأنظمة التي تتطلب عمق تفريغ محافظ.';
      case BatteryType.fld:
        return 'بطارية رصاص مغمورة، تحتاج تهوية وصيانة مناسبة.';
    }
  }
}

// ============================================================
// MODELS
// ============================================================

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

  String get title => '$brand $model - ${watt.toStringAsFixed(0)}W';
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

  String get title => '$brand $model';
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

  double get dailyWh {
    return (power * quantity.toDouble() * hours).toDouble();
  }

  double get peakW {
    return (power * quantity.toDouble()).toDouble();
  }
}

class PvConfiguration {
  final int series;
  final int parallel;
  final int totalPanels;
  final double arrayPowerKw;
  final double coldVoc;
  final double hotVmp;
  final double currentPerMppt;

  const PvConfiguration({
    required this.series,
    required this.parallel,
    required this.totalPanels,
    required this.arrayPowerKw,
    required this.coldVoc,
    required this.hotVmp,
    required this.currentPerMppt,
  });

  String get text => '${series}S × ${parallel}P';
}

class CalculationResult {
  final double dailyWh;
  final double peakW;
  final double pvRequiredKw;
  final int requiredPanels;

  final BatteryType batteryType;
  final double batteryEfficiency;
  final double dod;
  final double batteryKwh;
  final double batteryAh;
  final double batteryLoadCurrent;
  final double estimatedChargeCurrent;

  final double actualPvKw;
  final int actualPanels;
  final double coldVoc;
  final double hotVmp;
  final double currentPerMppt;

  final bool peakOk;
  final bool batteryVoltageOk;
  final bool pvPowerOk;
  final bool vocOk;
  final bool vmpOk;
  final bool currentOk;

  final PvConfiguration? configuration;

  const CalculationResult({
    required this.dailyWh,
    required this.peakW,
    required this.pvRequiredKw,
    required this.requiredPanels,
    required this.batteryType,
    required this.batteryEfficiency,
    required this.dod,
    required this.batteryKwh,
    required this.batteryAh,
    required this.batteryLoadCurrent,
    required this.estimatedChargeCurrent,
    required this.actualPvKw,
    required this.actualPanels,
    required this.coldVoc,
    required this.hotVmp,
    required this.currentPerMppt,
    required this.peakOk,
    required this.batteryVoltageOk,
    required this.pvPowerOk,
    required this.vocOk,
    required this.vmpOk,
    required this.currentOk,
    required this.configuration,
  });
}

// ============================================================
// DATABASE
// ============================================================

class SolarDatabase {
  // ----------------------------------------------------------
  // SOLAR PANELS
  // ----------------------------------------------------------

  static const List<SolarPanel> panels = [
    SolarPanel(
      brand: 'Trina',
      model: 'Vertex 550W',
      watt: 550.0,
      voc: 49.8,
      vmp: 41.7,
      isc: 13.89,
      imp: 13.19,
    ),
    SolarPanel(
      brand: 'Jinko',
      model: 'Tiger 550W',
      watt: 550.0,
      voc: 49.62,
      vmp: 41.62,
      isc: 13.89,
      imp: 13.21,
    ),
    SolarPanel(
      brand: 'LONGi',
      model: 'Hi-MO 6 550W',
      watt: 550.0,
      voc: 49.8,
      vmp: 41.7,
      isc: 13.9,
      imp: 13.2,
    ),
  ];

  // ----------------------------------------------------------
  // INVERTERS
  // ----------------------------------------------------------

  static const List<Inverter> inverters = [

    // ========================================================
    // الفئة العليا
    // ========================================================

    Inverter(
      brand: 'Deye',
      model: 'SUN-5K-SG04LP1',
      category: 'الفئة العليا',
      type: 'Hybrid',
      powerKw: 5.0,
      batteryVoltage: 48.0,
      maxPvPowerKw: 6.5,
      maxPvVoc: 500.0,
      mpptMin: 150.0,
      mpptMax: 425.0,
      mpptCount: 2,
      maxPvCurrent: 13.0,
      maxChargeCurrent: 120.0,
      maxDischargeCurrent: 120.0,
      efficiency: 97.6,
      ipRating: 'IP65',
      officialUrl: 'https://www.deyeess.com/',
    ),

    Inverter(
      brand: 'Solis',
      model: 'S5-EH1P5K-L',
      category: 'الفئة العليا',
      type: 'Hybrid',
      powerKw: 5.0,
      batteryVoltage: 48.0,
      maxPvPowerKw: 8.0,
      maxPvVoc: 600.0,
      mpptMin: 90.0,
      mpptMax: 520.0,
      mpptCount: 2,
      maxPvCurrent: 16.0,
      maxChargeCurrent: 100.0,
      maxDischargeCurrent: 100.0,
      efficiency: 97.7,
      ipRating: 'IP65',
      officialUrl: 'https://www.solisinverters.com/',
    ),

    Inverter(
      brand: 'FusionSolar',
      model: 'Huawei 5kW',
      category: 'الفئة العليا',
      type: 'Hybrid',
      powerKw: 5.0,
      batteryVoltage: 48.0,
      maxPvPowerKw: 7.5,
      maxPvVoc: 600.0,
      mpptMin: 90.0,
      mpptMax: 560.0,
      mpptCount: 2,
      maxPvCurrent: 12.5,
      maxChargeCurrent: 100.0,
      maxDischargeCurrent: 100.0,
      efficiency: 98.4,
      ipRating: 'IP65',
      officialUrl: 'https://solar.huawei.com/',
    ),

    Inverter(
      brand: 'Growatt',
      model: 'SPF 5000 ES',
      category: 'الفئة العليا',
      type: 'Off Grid',
      powerKw: 5.0,
      batteryVoltage: 48.0,
      maxPvPowerKw: 6.0,
      maxPvVoc: 450.0,
      mpptMin: 120.0,
      mpptMax: 430.0,
      mpptCount: 1,
      maxPvCurrent: 18.0,
      maxChargeCurrent: 100.0,
      maxDischargeCurrent: 100.0,
      efficiency: 93.0,
      ipRating: 'IP20',
      officialUrl: 'https://www.growatt.com/',
    ),

    // ========================================================
    // الفئة المتوسطة
    // ========================================================

    Inverter(
      brand: 'GSB',
      model: '5kW 48V',
      category: 'الفئة المتوسطة',
      type: 'Hybrid',
      powerKw: 5.0,
      batteryVoltage: 48.0,
      maxPvPowerKw: 6.0,
      maxPvVoc: 500.0,
      mpptMin: 120.0,
      mpptMax: 450.0,
      mpptCount: 1,
      maxPvCurrent: 18.0,
      maxChargeCurrent: 100.0,
      maxDischargeCurrent: 100.0,
      efficiency: 94.0,
      ipRating: 'IP21',
      officialUrl: 'https://gsbsolar.com/hybrid-inverter/',
    ),

    Inverter(
      brand: 'Motoma',
      model: 'Hybrid 5kW',
      category: 'الفئة المتوسطة',
      type: 'Hybrid',
      powerKw: 5.0,
      batteryVoltage: 48.0,
      maxPvPowerKw: 6.0,
      maxPvVoc: 500.0,
      mpptMin: 120.0,
      mpptMax: 450.0,
      mpptCount: 2,
      maxPvCurrent: 15.0,
      maxChargeCurrent: 100.0,
      maxDischargeCurrent: 100.0,
      efficiency: 95.0,
      ipRating: 'IP65',
      officialUrl:
          'https://motoma.com/product-category/hybrid-inverter/',
    ),

    Inverter(
      brand: 'MUST',
      model: 'PV18-5048',
      category: 'الفئة المتوسطة',
      type: 'Off Grid',
      powerKw: 5.0,
      batteryVoltage: 48.0,
      maxPvPowerKw: 6.0,
      maxPvVoc: 500.0,
      mpptMin: 120.0,
      mpptMax: 450.0,
      mpptCount: 1,
      maxPvCurrent: 18.0,
      maxChargeCurrent: 100.0,
      maxDischargeCurrent: 100.0,
      efficiency: 93.0,
      ipRating: 'IP21',
      officialUrl: 'https://www.mustpower.com/',
    ),

    Inverter(
      brand: 'FelicitySolar',
      model: 'IVGM5KLP2G1',
      category: 'الفئة المتوسطة',
      type: 'Hybrid',
      powerKw: 5.0,
      batteryVoltage: 48.0,
      maxPvPowerKw: 6.5,
      maxPvVoc: 500.0,
      mpptMin: 120.0,
      mpptMax: 450.0,
      mpptCount: 2,
      maxPvCurrent: 18.0,
      maxChargeCurrent: 100.0,
      maxDischargeCurrent: 100.0,
      efficiency: 95.0,
      ipRating: 'IP65',
      officialUrl:
          'https://africa.felicitysolar.com/africa-ar/hybrid-inverter/',
    ),

    // ========================================================
    // الفئة الاقتصادية
    // ========================================================

    Inverter(
      brand: 'Vackson',
      model: '3.2kVA 24V',
      category: 'الفئة الاقتصادية',
      type: 'Off Grid',
      powerKw: 2.56,
      batteryVoltage: 24.0,
      maxPvPowerKw: 3.0,
      maxPvVoc: 450.0,
      mpptMin: 120.0,
      mpptMax: 430.0,
      mpptCount: 1,
      maxPvCurrent: 18.0,
      maxChargeCurrent: 80.0,
      maxDischargeCurrent: 100.0,
      efficiency: 93.0,
      ipRating: 'IP21',
      officialUrl:
          'https://alwansolar.com/en/products/%D9%85%D8%AD%D9%88%D9%84-3-2kva-24v-vackson',
    ),

    Inverter(
      brand: 'Megasun',
      model: '5kW 48V',
      category: 'الفئة الاقتصادية',
      type: 'Hybrid',
      powerKw: 5.0,
      batteryVoltage: 48.0,
      maxPvPowerKw: 6.0,
      maxPvVoc: 500.0,
      mpptMin: 120.0,
      mpptMax: 450.0,
      mpptCount: 1,
      maxPvCurrent: 18.0,
      maxChargeCurrent: 100.0,
      maxDischargeCurrent: 100.0,
      efficiency: 93.0,
      ipRating: 'IP21',
      officialUrl: 'https://ms.bluefinsolarenergy.com/',
    ),

    Inverter(
      brand: 'Eruonet',
      model: 'Solar Inverter',
      category: 'الفئة الاقتصادية',
      type: 'Hybrid',
      powerKw: 5.0,
      batteryVoltage: 48.0,
      maxPvPowerKw: 6.0,
      maxPvVoc: 500.0,
      mpptMin: 120.0,
      mpptMax: 450.0,
      mpptCount: 1,
      maxPvCurrent: 18.0,
      maxChargeCurrent: 100.0,
      maxDischargeCurrent: 100.0,
      efficiency: 93.0,
      ipRating: 'غير محدد',
      officialUrl: '',
    ),

    Inverter(
      brand: 'Restar',
      model: '5kW 48V',
      category: 'الفئة الاقتصادية',
      type: 'Hybrid',
      powerKw: 5.0,
      batteryVoltage: 48.0,
      maxPvPowerKw: 6.0,
      maxPvVoc: 500.0,
      mpptMin: 120.0,
      mpptMax: 450.0,
      mpptCount: 1,
      maxPvCurrent: 18.0,
      maxChargeCurrent: 100.0,
      maxDischargeCurrent: 100.0,
      efficiency: 93.0,
      ipRating: 'IP21',
      officialUrl: '',
    ),
  ];
}

// ============================================================
// ENGINEERING CALCULATOR
// ============================================================

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
    double dailyWh = 0.0;
    double peakW = 0.0;

    for (final load in loads) {
      dailyWh += load.dailyWh;
      peakW += load.peakW;
    }

    final double usablePsh =
        math.max(1.0, psh).toDouble();

    final double usableSystemEfficiency =
        math.max(
          0.50,
          math.min(systemEfficiency, 1.0),
        ).toDouble();

    final double usableBatteryEfficiency =
        math.max(
          0.70,
          math.min(batteryEfficiency, 1.0),
        ).toDouble();

    final double usableDod =
        math.max(
          0.30,
          math.min(dod, 0.95),
        ).toDouble();

    final double usableSafety =
        math.max(1.0, safetyMargin).toDouble();

    final double pvRequiredKw =
        (
          dailyWh /
          (
            usablePsh *
            usableSystemEfficiency
          ) /
          1000.0
        ).toDouble();

    final int requiredPanels = math.max(
      1,
      (
        pvRequiredKw *
        1000.0 /
        panel.watt
      ).ceil(),
    ).toInt();

    final double batteryKwh =
        (
          dailyWh /
          1000.0 /
          usableDod /
          usableBatteryEfficiency
        ).toDouble();

    final double batteryAh =
        (
          batteryKwh *
          1000.0 /
          inverter.batteryVoltage
        ).toDouble();

    final double batteryLoadCurrent =
        (
          peakW *
          usableSafety /
          inverter.batteryVoltage
        ).toDouble();

    final double estimatedChargeCurrent =
        (
          pvRequiredKw *
          1000.0 /
          inverter.batteryVoltage
        ).toDouble();

    final int safeSeries = math.max(1, series).toInt();
    final int safeParallel = math.max(1, parallel).toInt();

    final int totalPanels =
        safeSeries * safeParallel;

    final double actualPvKw =
        (
          totalPanels *
          panel.watt /
          1000.0
        ).toDouble();

    final double coldVoc =
        (
          safeSeries *
          panel.voc *
          1.10
        ).toDouble();

    final double hotVmp =
        (
          safeSeries *
          panel.vmp *
          0.85
        ).toDouble();

    final int stringsPerMppt = math.max(
      1,
      (
        safeParallel +
        inverter.mpptCount -
        1
      ) ~/
      inverter.mpptCount,
    ).toInt();

    final double currentPerMppt =
        (
          panel.isc *
          stringsPerMppt
        ).toDouble();

    final bool peakOk =
        (
          peakW *
          usableSafety
        ) <= (
          inverter.powerKw *
          1000.0
        );

    final bool batteryVoltageOk =
        inverter.batteryVoltage > 0.0;

    final bool pvPowerOk =
        actualPvKw <=
        inverter.maxPvPowerKw;

    final bool vocOk =
        coldVoc <= inverter.maxPvVoc;

    final bool vmpOk =
        hotVmp >= inverter.mpptMin &&
        hotVmp <= inverter.mpptMax;

    final bool currentOk =
        currentPerMppt <=
        inverter.maxPvCurrent;

    final PvConfiguration config =
        PvConfiguration(
      series: safeSeries,
      parallel: safeParallel,
      totalPanels: totalPanels,
      arrayPowerKw: actualPvKw,
      coldVoc: coldVoc,
      hotVmp: hotVmp,
      currentPerMppt: currentPerMppt,
    );

    return CalculationResult(
      dailyWh: dailyWh,
      peakW: peakW,
      pvRequiredKw: pvRequiredKw,
      requiredPanels: requiredPanels,
      batteryType: batteryType,
      batteryEfficiency: usableBatteryEfficiency,
      dod: usableDod,
      batteryKwh: batteryKwh,
      batteryAh: batteryAh,
      batteryLoadCurrent: batteryLoadCurrent,
      estimatedChargeCurrent: estimatedChargeCurrent,
      actualPvKw: actualPvKw,
      actualPanels: totalPanels,
      coldVoc: coldVoc,
      hotVmp: hotVmp,
      currentPerMppt: currentPerMppt,
      peakOk: peakOk,
      batteryVoltageOk: batteryVoltageOk,
      pvPowerOk: pvPowerOk,
      vocOk: vocOk,
      vmpOk: vmpOk,
      currentOk: currentOk,
      configuration: config,
    );
  }

  static PvConfiguration? suggestConfiguration({
    required SolarPanel panel,
    required Inverter inverter,
    required int minimumPanels,
  }) {
    PvConfiguration? best;

    for (int series = 1; series <= 24; series++) {
      for (int parallel = 1; parallel <= 12; parallel++) {
        final int totalPanels =
            series * parallel;

        if (totalPanels < minimumPanels) {
          continue;
        }

        final double pvKw =
            (
              totalPanels *
              panel.watt /
              1000.0
            ).toDouble();

        final double coldVoc =
            (
              series *
              panel.voc *
              1.10
            ).toDouble();

        final double hotVmp =
            (
              series *
              panel.vmp *
              0.85
            ).toDouble();

        final int stringsPerMppt =
            math.max(
              1,
              (
                parallel +
                inverter.mpptCount -
                1
              ) ~/
              inverter.mpptCount,
            ).toInt();

        final double currentPerMppt =
            (
              panel.isc *
              stringsPerMppt
            ).toDouble();

        if (pvKw > inverter.maxPvPowerKw) {
          continue;
        }

        if (coldVoc > inverter.maxPvVoc) {
          continue;
        }

        if (hotVmp < inverter.mpptMin ||
            hotVmp > inverter.mpptMax) {
          continue;
        }

        if (currentPerMppt >
            inverter.maxPvCurrent) {
          continue;
        }

        final candidate = PvConfiguration(
          series: series,
          parallel: parallel,
          totalPanels: totalPanels,
          arrayPowerKw: pvKw,
          coldVoc: coldVoc,
          hotVmp: hotVmp,
          currentPerMppt: currentPerMppt,
        );

        if (best == null) {
          best = candidate;
        } else {
          final int panelDifference =
              candidate.totalPanels -
              minimumPanels;

          final int bestDifference =
              best.totalPanels -
              minimumPanels;

          if (panelDifference <
              bestDifference) {
            best = candidate;
          } else if (
              panelDifference ==
              bestDifference &&
              candidate.arrayPowerKw <
              best.arrayPowerKw) {
            best = candidate;
          }
        }
      }
    }

    return best;
  }
}

// ============================================================
// MAIN SHELL
// ============================================================

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() =>
      _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;

  final List<Widget> pages = const [
    HomePage(),
    CalculatorPage(),
    MarketPage(),
    LocationPage(),
    MorePage(),
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
            icon: Icon(Icons.menu),
            selectedIcon: Icon(Icons.menu),
            label: 'المزيد',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// HOME
// ============================================================

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sudan SO',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF087F5B),
                  Color(0xFF0B6E4F),
                ],
              ),
              borderRadius:
                  BorderRadius.circular(24),
            ),
            child: const Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.solar_power,
                  color: Colors.white,
                  size: 52,
                ),
                SizedBox(height: 16),
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
                  'منصة متخصصة في حساب وتصميم أنظمة الطاقة الشمسية.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const SectionTitle(
            title: 'أدوات التطبيق',
            icon: Icons.build_circle_outlined,
          ),

          const SizedBox(height: 12),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: [
              ToolCard(
                icon: Icons.calculate,
                title: 'الحاسبة الشمسية',
                subtitle: 'تصميم النظام',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          const CalculatorPage(),
                    ),
                  );
                },
              ),
              ToolCard(
                icon: Icons.solar_power,
                title: 'الألواح',
                subtitle: 'Trina • Jinko • LONGi',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          const MarketPage(),
                    ),
                  );
                },
              ),
              ToolCard(
                icon:
                    Icons.electrical_services,
                title: 'الإنفرترات',
                subtitle: 'الفئات والأسعار',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          const MarketPage(),
                    ),
                  );
                },
              ),
              ToolCard(
                icon: Icons.battery_full,
                title: 'البطاريات',
                subtitle:
                    'Lithium • AGM • FLD',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          const CalculatorPage(),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          const AppCard(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'ملاحظة هندسية',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'نتائج الحاسبة نتائج تصميمية أولية. قبل التنفيذ يجب مراجعة Datasheet الفعلي لكل جهاز ودرجات الحرارة والكابلات والحمايات وهبوط الجهد وتيار الإقلاع للأحمال الحركية ونظام البطاريات.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CALCULATOR
// ============================================================

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() =>
      _CalculatorPageState();
}

class _CalculatorPageState
    extends State<CalculatorPage> {
  final List<LoadItem> loads = [
    LoadItem(
      name: 'ثلاجة',
      power: 200.0,
      quantity: 1,
      hours: 12.0,
    ),
    LoadItem(
      name: 'مروحة',
      power: 70.0,
      quantity: 2,
      hours: 10.0,
    ),
    LoadItem(
      name: 'إضاءة',
      power: 20.0,
      quantity: 6,
      hours: 6.0,
    ),
  ];

  SolarPanel selectedPanel =
      SolarDatabase.panels.first;

  Inverter selectedInverter =
      SolarDatabase.inverters.first;

  BatteryType selectedBattery =
      BatteryType.lithium;

  double psh = 5.5;
  double systemEfficiency = 0.80;
  double batteryEfficiency = 0.95;
  double dod = 0.80;
  double safetyMargin = 1.25;

  int series = 4;
  int parallel = 2;

  CalculationResult? result;
  PvConfiguration? suggested;

  final pshController =
      TextEditingController(text: '5.5');

  final efficiencyController =
      TextEditingController(text: '80');

  final batteryEfficiencyController =
      TextEditingController(text: '95');

  final dodController =
      TextEditingController(text: '80');

  final safetyController =
      TextEditingController(text: '1.25');

  @override
  void dispose() {
    pshController.dispose();
    efficiencyController.dispose();
    batteryEfficiencyController.dispose();
    dodController.dispose();
    safetyController.dispose();
    super.dispose();
  }

  void updateBatteryDefaults(
    BatteryType type,
  ) {
    setState(() {
      selectedBattery = type;

      batteryEfficiency =
          type.defaultEfficiency;

      dod = type.defaultDod;

      batteryEfficiencyController.text =
          (type.defaultEfficiency * 100)
              .toStringAsFixed(0);

      dodController.text =
          (type.defaultDod * 100)
              .toStringAsFixed(0);
    });
  }

  void calculate() {
    setState(() {
      psh =
          double.tryParse(
                pshController.text
                    .replaceAll(',', '.'),
              ) ??
              5.5;

      systemEfficiency =
          (
            double.tryParse(
                  efficiencyController.text
                      .replaceAll(',', '.'),
                ) ??
                80.0
          ) /
          100.0;

      batteryEfficiency =
          (
            double.tryParse(
                  batteryEfficiencyController
                      .text
                      .replaceAll(',', '.'),
                ) ??
                (
                  selectedBattery
                      .defaultEfficiency *
                  100.0
                )
          ) /
          100.0;

      dod =
          (
            double.tryParse(
                  dodController.text
                      .replaceAll(',', '.'),
                ) ??
                (
                  selectedBattery
                      .defaultDod *
                  100.0
                )
          ) /
          100.0;

      safetyMargin =
          double.tryParse(
                safetyController.text
                    .replaceAll(',', '.'),
              ) ??
              1.25;

      result =
          SolarEngineering.calculate(
        loads: loads,
        panel: selectedPanel,
        inverter: selectedInverter,
        batteryType: selectedBattery,
        psh: psh,
        systemEfficiency:
            systemEfficiency,
        batteryEfficiency:
            batteryEfficiency,
        dod: dod,
        safetyMargin:
            safetyMargin,
        series: series,
        parallel: parallel,
      );

      suggested =
          SolarEngineering
              .suggestConfiguration(
        panel: selectedPanel,
        inverter: selectedInverter,
        minimumPanels:
            result!.requiredPanels,
      );
    });
  }

  void addLoad() {
    setState(() {
      loads.add(
        LoadItem(
          name: 'حمل جديد',
          power: 100.0,
          quantity: 1,
          hours: 5.0,
        ),
      );
    });
  }

  void removeLoad(int index) {
    setState(() {
      if (loads.length > 1) {
        loads.removeAt(index);
      }
    });
  }

  void showLoadEditor(int index) {
    final load = loads[index];

    final nameController =
        TextEditingController(
      text: load.name,
    );

    final powerController =
        TextEditingController(
      text: load.power.toString(),
    );

    final quantityController =
        TextEditingController(
      text: load.quantity.toString(),
    );

    final hoursController =
        TextEditingController(
      text: load.hours.toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'تعديل الحمل',
          ),
          content:
              SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller:
                      nameController,
                  decoration:
                      const InputDecoration(
                    labelText: 'اسم الحمل',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller:
                      powerController,
                  keyboardType:
                      const TextInputType
                          .numberWithOptions(
                    decimal: true,
                  ),
                  decoration:
                      const InputDecoration(
                    labelText: 'القدرة W',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller:
                      quantityController,
                  keyboardType:
                      TextInputType.number,
                  decoration:
                      const InputDecoration(
                    labelText: 'العدد',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller:
                      hoursController,
                  keyboardType:
                      const TextInputType
                          .numberWithOptions(
                    decimal: true,
                  ),
                  decoration:
                      const InputDecoration(
                    labelText:
                        'ساعات التشغيل يومياً',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child:
                  const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  load.name =
                      nameController.text
                              .trim()
                              .isEmpty
                          ? 'حمل'
                          : nameController.text
                              .trim();

                  load.power =
                      double.tryParse(
                            powerController.text
                                .replaceAll(
                              ',',
                              '.',
                            ),
                          ) ??
                          100.0;

                  load.quantity =
                      int.tryParse(
                            quantityController
                                .text,
                          ) ??
                          1;

                  load.hours =
                      double.tryParse(
                            hoursController.text
                                .replaceAll(
                              ',',
                              '.',
                            ),
                          ) ??
                          1.0;
                });

                Navigator.pop(context);
              },
              child:
                  const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  void useSuggested() {
    if (suggested == null) return;

    setState(() {
      series = suggested!.series;
      parallel = suggested!.parallel;
    });

    calculate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الحاسبة الهندسية',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding:
            const EdgeInsets.all(16),
        children: [
          const SectionTitle(
            title: 'الأحمال الكهربائية',
            icon: Icons.power,
          ),
          const SizedBox(height: 10),

          ...List.generate(
            loads.length,
            (index) {
              final load = loads[index];

              return Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 10,
                ),
                child: AppCard(
                  child: ListTile(
                    contentPadding:
                        EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor:
                          Theme.of(context)
                              .colorScheme
                              .primaryContainer,
                      child: const Icon(
                        Icons
                            .electrical_services,
                      ),
                    ),
                    title: Text(
                      load.name,
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${load.power.toStringAsFixed(0)} W × '
                      '${load.quantity} × '
                      '${load.hours.toStringAsFixed(1)} ساعة = '
                      '${load.dailyWh.toStringAsFixed(0)} Wh/day',
                    ),
                    trailing:
                        PopupMenuButton<
                            String>(
                      onSelected:
                          (value) {
                        if (value ==
                            'edit') {
                          showLoadEditor(
                              index);
                        } else if (
                            value ==
                            'delete') {
                          removeLoad(
                              index);
                        }
                      },
                      itemBuilder:
                          (_) =>
                              const [
                        PopupMenuItem(
                          value: 'edit',
                          child:
                              Text(
                            'تعديل',
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child:
                              Text(
                            'حذف',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          OutlinedButton.icon(
            onPressed: addLoad,
            icon: const Icon(
              Icons.add,
            ),
            label:
                const Text(
              'إضافة حمل',
            ),
          ),

          const SizedBox(height: 24),

          const SectionTitle(
            title:
                'الألواح والإنفرتر',
            icon: Icons.solar_power,
          ),

          const SizedBox(height: 12),

          AppCard(
            child: Column(
              children: [
                DropdownButtonFormField<
                    SolarPanel>(
                  value:
                      selectedPanel,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'اللوح الشمسي',
                    prefixIcon:
                        Icon(
                      Icons.solar_power,
                    ),
                  ),
                  items: SolarDatabase
                      .panels
                      .map(
                    (panel) {
                      return DropdownMenuItem(
                        value: panel,
                        child:
                            Text(
                          panel.title,
                        ),
                      );
                    },
                  ).toList(),
                  onChanged:
                      (value) {
                    if (value !=
                        null) {
                      setState(() {
                        selectedPanel =
                            value;
                      });
                    }
                  },
                ),

                const SizedBox(
                    height: 14),

                DropdownButtonFormField<
                    Inverter>(
                  value:
                      selectedInverter,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'الإنفرتر',
                    prefixIcon:
                        Icon(
                      Icons
                          .electrical_services,
                    ),
                  ),
                  items:
                      SolarDatabase
                          .inverters
                          .map(
                    (inverter) {
                      return DropdownMenuItem(
                        value:
                            inverter,
                        child:
                            Text(
                          '${inverter.brand} '
                          '${inverter.model}',
                        ),
                      );
                    },
                  ).toList(),
                  onChanged:
                      (value) {
                    if (value !=
                        null) {
                      setState(() {
                        selectedInverter =
                            value;
                      });
                    }
                  },
                ),

                const SizedBox(
                    height: 10),

                if (selectedInverter
                    .category
                    .isNotEmpty)
                  Align(
                    alignment:
                        Alignment
                            .centerRight,
                    child: Chip(
                      avatar:
                          const Icon(
                        Icons
                            .verified,
                        size: 18,
                      ),
                      label:
                          Text(
                        selectedInverter
                            .category,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ====================================================
          // BATTERY
          // ====================================================

          const SectionTitle(
            title: 'البطارية',
            icon: Icons.battery_full,
          ),

          const SizedBox(height: 12),

          AppCard(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                DropdownButtonFormField<
                    BatteryType>(
                  value:
                      selectedBattery,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'نوع البطارية',
                    prefixIcon:
                        Icon(
                      Icons
                          .battery_charging_full,
                    ),
                  ),
                  items: BatteryType
                      .values
                      .map(
                    (type) {
                      return DropdownMenuItem<
                          BatteryType>(
                        value: type,
                        child:
                            Text(
                          type.label,
                        ),
                      );
                    },
                  ).toList(),
                  onChanged:
                      (value) {
                    if (value !=
                        null) {
                      updateBatteryDefaults(
                          value);
                    }
                  },
                ),

                const SizedBox(
                    height: 12),

                Text(
                  selectedBattery
                      .description,
                  style:
                      const TextStyle(
                    fontSize: 13,
                  ),
                ),

                const SizedBox(
                    height: 12),

                Row(
                  children: [
                    Expanded(
                      child:
                          MetricCard(
                        title:
                            'الكفاءة الافتراضية',
                        value:
                            '${(selectedBattery.defaultEfficiency * 100).toStringAsFixed(0)}%',
                        icon: Icons
                            .speed,
                      ),
                    ),
                    const SizedBox(
                        width: 10),
                    Expanded(
                      child:
                          MetricCard(
                        title:
                            'DoD الافتراضي',
                        value:
                            '${(selectedBattery.defaultDod * 100).toStringAsFixed(0)}%',
                        icon: Icons
                            .battery_std,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const SectionTitle(
            title:
                'افتراضات التصميم',
            icon: Icons.tune,
          ),

          const SizedBox(height: 12),

          AppCard(
            child: Column(
              children: [
                NumberField(
                  controller:
                      pshController,
                  label:
                      'Peak Sun Hours',
                  suffix:
                      'ساعة',
                ),
                const SizedBox(
                    height: 12),
                NumberField(
                  controller:
                      efficiencyController,
                  label:
                      'كفاءة النظام',
                  suffix: '%',
                ),
                const SizedBox(
                    height: 12),
                NumberField(
                  controller:
                      batteryEfficiencyController,
                  label:
                      'كفاءة البطارية',
                  suffix: '%',
                ),
                const SizedBox(
                    height: 12),
                NumberField(
                  controller:
                      dodController,
                  label:
                      'Depth of Discharge',
                  suffix: '%',
                ),
                const SizedBox(
                    height: 12),
                NumberField(
                  controller:
                      safetyController,
                  label:
                      'Safety Margin',
                  suffix: '×',
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const SectionTitle(
            title:
                'تكوين الألواح',
            icon: Icons.grid_view,
          ),

          const SizedBox(height: 12),

          AppCard(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child:
                          NumberField(
                        controller:
                            TextEditingController(
                          text:
                              series.toString(),
                        ),
                        label:
                            'Series',
                        suffix:
                            'لوح',
                        onChanged:
                            (value) {
                          final parsed =
                              int.tryParse(
                            value,
                          );

                          if (parsed !=
                                  null &&
                              parsed >
                                  0) {
                            setState(() {
                              series =
                                  parsed;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(
                        width: 12),
                    Expanded(
                      child:
                          NumberField(
                        controller:
                            TextEditingController(
                          text:
                              parallel
                                  .toString(),
                        ),
                        label:
                            'Parallel',
                        suffix:
                            'String',
                        onChanged:
                            (value) {
                          final parsed =
                              int.tryParse(
                            value,
                          );

                          if (parsed !=
                                  null &&
                              parsed >
                                  0) {
                            setState(() {
                              parallel =
                                  parsed;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                    height: 14),
                Text(
                  'الإجمالي: '
                  '${series * parallel} لوح',
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          FilledButton.icon(
            onPressed: calculate,
            icon: const Icon(
              Icons.calculate,
            ),
            label:
                const Padding(
              padding:
                  EdgeInsets.all(12),
              child: Text(
                'احسب النظام',
                style: TextStyle(
                  fontSize: 17,
                ),
              ),
            ),
          ),

          // ====================================================
          // RESULTS
          // ====================================================

          if (result != null) ...[
            const SizedBox(
                height: 26),

            const SectionTitle(
              title:
                  'نتائج التصميم',
              icon:
                  Icons.analytics,
            ),

            const SizedBox(
                height: 12),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.3,
              children: [
                MetricCard(
                  title:
                      'الاستهلاك اليومي',
                  value:
                      '${result!.dailyWh.toStringAsFixed(0)} Wh',
                  icon:
                      Icons.bolt,
                ),
                MetricCard(
                  title:
                      'الحمل الأقصى',
                  value:
                      '${result!.peakW.toStringAsFixed(0)} W',
                  icon:
                      Icons.power,
                ),
                MetricCard(
                  title:
                      'PV المطلوبة',
                  value:
                      '${result!.pvRequiredKw.toStringAsFixed(2)} kW',
                  icon:
                      Icons.solar_power,
                ),
                MetricCard(
                  title:
                      'عدد الألواح',
                  value:
                      '${result!.requiredPanels}',
                  icon:
                      Icons.grid_view,
                ),
                MetricCard(
                  title:
                      'البطارية',
                  value:
                      '${result!.batteryKwh.toStringAsFixed(2)} kWh',
                  icon:
                      Icons.battery_full,
                ),
                MetricCard(
                  title:
                      'البطارية Ah',
                  value:
                      '${result!.batteryAh.toStringAsFixed(0)} Ah',
                  icon:
                      Icons.battery_charging_full,
                ),
                MetricCard(
                  title:
                      'تيار الحمل DC',
                  value:
                      '${result!.batteryLoadCurrent.toStringAsFixed(1)} A',
                  icon:
                      Icons.electric_bolt,
                ),
                MetricCard(
                  title:
                      'تيار الشحن التقريبي',
                  value:
                      '${result!.estimatedChargeCurrent.toStringAsFixed(1)} A',
                  icon:
                      Icons.battery_charging_full,
                ),
              ],
            ),

            const SizedBox(
                height: 18),

            ResultCard(
              title:
                  'نوع البطارية',
              child: Column(
                children: [
                  SpecRow(
                    label:
                        'النوع',
                    value:
                        result!.batteryType.label,
                  ),
                  SpecRow(
                    label:
                        'الكفاءة المستخدمة',
                    value:
                        '${(result!.batteryEfficiency * 100).toStringAsFixed(0)}%',
                  ),
                  SpecRow(
                    label:
                        'DoD المستخدم',
                    value:
                        '${(result!.dod * 100).toStringAsFixed(0)}%',
                  ),
                  SpecRow(
                    label:
                        'السعة المطلوبة',
                    value:
                        '${result!.batteryKwh.toStringAsFixed(2)} kWh',
                  ),
                  SpecRow(
                    label:
                        'السعة النظرية',
                    value:
                        '${result!.batteryAh.toStringAsFixed(0)} Ah',
                  ),
                ],
              ),
            ),

            const SizedBox(
                height: 18),

            ResultCard(
              title:
                  'التكوين الحالي',
              child: Column(
                children: [
                  SpecRow(
                    label:
                        'Series',
                    value:
                        '${series}S',
                  ),
                  SpecRow(
                    label:
                        'Parallel',
                    value:
                        '${parallel}P',
                  ),
                  SpecRow(
                    label:
                        'إجمالي الألواح',
                    value:
                        '${result!.actualPanels}',
                  ),
                  SpecRow(
                    label:
                        'قدرة المصفوفة',
                    value:
                        '${result!.actualPvKw.toStringAsFixed(2)} kW',
                  ),
                  SpecRow(
                    label:
                        'Cold Voc',
                    value:
                        '${result!.coldVoc.toStringAsFixed(1)} V',
                  ),
                  SpecRow(
                    label:
                        'Hot Vmp',
                    value:
                        '${result!.hotVmp.toStringAsFixed(1)} V',
                  ),
                  SpecRow(
                    label:
                        'Current / MPPT',
                    value:
                        '${result!.currentPerMppt.toStringAsFixed(1)} A',
                  ),
                ],
              ),
            ),

            const SizedBox(
                height: 18),

            ResultCard(
              title:
                  'الفحوصات الهندسية',
              child: Column(
                children: [
                  CheckRow(
                    title:
                        'قدرة الإنفرتر مناسبة للحمل',
                    ok:
                        result!.peakOk,
                  ),
                  CheckRow(
                    title:
                        'جهد البطارية',
                    ok:
                        result!.batteryVoltageOk,
                  ),
                  CheckRow(
                    title:
                        'قدرة PV ضمن حد الإنفرتر',
                    ok:
                        result!.pvPowerOk,
                  ),
                  CheckRow(
                    title:
                        'Cold Voc ضمن الحد',
                    ok:
                        result!.vocOk,
                  ),
                  CheckRow(
                    title:
                        'Hot Vmp داخل نطاق MPPT',
                    ok:
                        result!.vmpOk,
                  ),
                  CheckRow(
                    title:
                        'تيار MPPT ضمن الحد',
                    ok:
                        result!.currentOk,
                  ),
                ],
              ),
            ),

            const SizedBox(
                height: 18),

            if (suggested != null)
              ResultCard(
                title:
                    'التكوين المقترح تلقائياً',
                child: Column(
                  children: [
                    Text(
                      suggested!.text,
                      style:
                          const TextStyle(
                        fontSize: 26,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                        height: 8),
                    Text(
                      '${suggested!.totalPanels} لوح • '
                      '${suggested!.arrayPowerKw.toStringAsFixed(2)} kW',
                    ),
                    const SizedBox(
                        height: 6),
                    Text(
                      'Voc: '
                      '${suggested!.coldVoc.toStringAsFixed(1)} V',
                    ),
                    Text(
                      'Vmp: '
                      '${suggested!.hotVmp.toStringAsFixed(1)} V',
                    ),
                    Text(
                      'Current/MPPT: '
                      '${suggested!.currentPerMppt.toStringAsFixed(1)} A',
                    ),
                    const SizedBox(
                        height: 12),
                    FilledButton.icon(
                      onPressed:
                          useSuggested,
                      icon:
                          const Icon(
                        Icons.check,
                      ),
                      label:
                          const Text(
                        'استخدام التكوين المقترح',
                      ),
                    ),
                  ],
                ),
              ),
          ],

          const SizedBox(
              height: 30),

          const AppCard(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'تنبيه هندسي مهم',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'الحسابات داخل التطبيق تساعد في التصميم الأولي. لا تعتبر بديلاً عن مراجعة Datasheet الأصلي، درجات حرارة الموقع، معاملات الحرارة الفعلية للوح، تيارات MPPT الفعلية، مقاطع الكابلات، هبوط الجهد، الحمايات DC/AC، التأريض، وتيار الإقلاع للمحركات.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// MARKET
// ============================================================

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() =>
      _MarketPageState();
}

class _MarketPageState
    extends State<MarketPage> {
  String search = '';
  String category = 'الكل';
  String inverterClass = 'الكل';

  List<dynamic> get products {
    final List<dynamic> all = [
      ...SolarDatabase.panels,
      ...SolarDatabase.inverters,
    ];

    return all.where((item) {
      final String title =
          item is SolarPanel
              ? item.title
              : (item as Inverter).title;

      final bool matchesSearch =
          title
              .toLowerCase()
              .contains(
                search.toLowerCase(),
              );

      if (!matchesSearch) {
        return false;
      }

      if (category == 'الألواح') {
        return item is SolarPanel;
      }

      if (category == 'الإنفرترات') {
        if (item is! Inverter) {
          return false;
        }

        if (inverterClass == 'الكل') {
          return true;
        }

        return item.category ==
            inverterClass;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'السوق',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  search = value;
                });
              },
              decoration:
                  const InputDecoration(
                prefixIcon:
                    Icon(Icons.search),
                hintText:
                    'ابحث عن منتج...',
              ),
            ),
          ),

          SizedBox(
            height: 45,
            child: ListView(
              scrollDirection:
                  Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              children: [
                _categoryButton(
                  'الكل',
                ),
                _categoryButton(
                  'الألواح',
                ),
                _categoryButton(
                  'الإنفرترات',
                ),
              ],
            ),
          ),

          if (category ==
              'الإنفرترات')
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection:
                    Axis.horizontal,
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 16,
                ),
                children: [
                  _classButton('الكل'),
                  _classButton(
                    'الفئة العليا',
                  ),
                  _classButton(
                    'الفئة المتوسطة',
                  ),
                  _classButton(
                    'الفئة الاقتصادية',
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          Expanded(
            child: products.isEmpty
                ? const EmptyState(
                    icon:
                        Icons.search_off,
                    title:
                        'لا توجد نتائج',
                  )
                : ListView.builder(
                    padding:
                        const EdgeInsets.all(
                      16,
                    ),
                    itemCount:
                        products.length,
                    itemBuilder:
                        (context, index) {
                      final item =
                          products[index];

                      if (item
                          is SolarPanel) {
                        return _panelCard(
                            item);
                      }

                      return _inverterCard(
                        item as Inverter,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _categoryButton(
      String value) {
    final selected =
        category == value;

    return Padding(
      padding:
          const EdgeInsets.only(
        left: 8,
      ),
      child: ChoiceChip(
        selected: selected,
        label: Text(value),
        onSelected: (_) {
          setState(() {
            category = value;

            if (value !=
                'الإنفرترات') {
              inverterClass =
                  'الكل';
            }
          });
        },
      ),
    );
  }

  Widget _classButton(
      String value) {
    final selected =
        inverterClass == value;

    return Padding(
      padding:
          const EdgeInsets.only(
        left: 8,
      ),
      child: ChoiceChip(
        selected: selected,
        label: Text(value),
        onSelected: (_) {
          setState(() {
            inverterClass =
                value;
          });
        },
      ),
    );
  }

  Widget _panelCard(
      SolarPanel panel) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 12,
      ),
      child: AppCard(
        child: ListTile(
          leading:
              const CircleAvatar(
            child: Icon(
              Icons.solar_power,
            ),
          ),
          title: Text(
            panel.title,
            style:
                const TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          subtitle: Text(
            'Voc ${panel.voc}V • '
            'Vmp ${panel.vmp}V • '
            'Isc ${panel.isc}A',
          ),
          trailing:
              const Icon(
            Icons.chevron_left,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ProductDetailsPage(
                  panel: panel,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _inverterCard(
      Inverter inverter) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 12,
      ),
      child: AppCard(
        child: ListTile(
          leading:
              const CircleAvatar(
            child: Icon(
              Icons
                  .electrical_services,
            ),
          ),
          title: Text(
            inverter.title,
            style:
                const TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              Text(
                '${inverter.powerKw.toStringAsFixed(1)} kW • '
                '${inverter.batteryVoltage.toStringAsFixed(0)}V • '
                '${inverter.mpptCount} MPPT',
              ),
              const SizedBox(
                  height: 4),
              Chip(
                visualDensity:
                    VisualDensity
                        .compact,
                label: Text(
                  inverter.category,
                ),
              ),
            ],
          ),
          trailing:
              const Icon(
            Icons.chevron_left,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ProductDetailsPage(
                  inverter:
                      inverter,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ============================================================
// PRODUCT DETAILS
// ============================================================

class ProductDetailsPage
    extends StatelessWidget {
  final SolarPanel? panel;
  final Inverter? inverter;

  const ProductDetailsPage({
    super.key,
    this.panel,
    this.inverter,
  });

  Future<void>
      openOfficialWebsite() async {
    if (inverter == null ||
        inverter!.officialUrl
            .trim()
            .isEmpty) {
      return;
    }

    final uri = Uri.parse(
      inverter!.officialUrl,
    );

    await launchUrl(
      uri,
      mode:
          LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final String title =
        panel != null
            ? panel!.title
            : inverter!.title;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'تفاصيل المنتج',
        ),
      ),
      body: ListView(
        padding:
            const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  child: Icon(
                    panel != null
                        ? Icons
                            .solar_power
                        : Icons
                            .electrical_services,
                    size: 36,
                  ),
                ),
                const SizedBox(
                    height: 12),
                Text(
                  title,
                  textAlign:
                      TextAlign.center,
                  style:
                      const TextStyle(
                    fontSize: 21,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
              height: 16),

          if (panel != null)
            AppCard(
              child: Column(
                children: [
                  const SectionTitle(
                    title:
                        'مواصفات اللوح',
                    icon:
                        Icons.info_outline,
                  ),
                  const SizedBox(
                      height: 10),
                  SpecRow(
                    label: 'القدرة',
                    value:
                        '${panel!.watt.toStringAsFixed(0)} W',
                  ),
                  SpecRow(
                    label: 'Voc',
                    value:
                        '${panel!.voc} V',
                  ),
                  SpecRow(
                    label: 'Vmp',
                    value:
                        '${panel!.vmp} V',
                  ),
                  SpecRow(
                    label: 'Isc',
                    value:
                        '${panel!.isc} A',
                  ),
                  SpecRow(
                    label: 'Imp',
                    value:
                        '${panel!.imp} A',
                  ),
                ],
              ),
            ),

          if (inverter != null)
            AppCard(
              child: Column(
                children: [
                  const SectionTitle(
                    title:
                        'مواصفات الإنفرتر',
                    icon:
                        Icons.info_outline,
                  ),
                  const SizedBox(
                      height: 10),
                  SpecRow(
                    label:
                        'الفئة',
                    value:
                        inverter!.category,
                  ),
                  SpecRow(
                    label:
                        'النوع',
                    value:
                        inverter!.type,
                  ),
                  SpecRow(
                    label:
                        'القدرة',
                    value:
                        '${inverter!.powerKw.toStringAsFixed(1)} kW',
                  ),
                  SpecRow(
                    label:
                        'البطارية',
                    value:
                        '${inverter!.batteryVoltage.toStringAsFixed(0)} V',
                  ),
                  SpecRow(
                    label:
                        'PV Max',
                    value:
                        '${inverter!.maxPvPowerKw.toStringAsFixed(1)} kW',
                  ),
                  SpecRow(
                    label:
                        'Max Voc',
                    value:
                        '${inverter!.maxPvVoc.toStringAsFixed(0)} V',
                  ),
                  SpecRow(
                    label:
                        'MPPT',
                    value:
                        '${inverter!.mpptMin.toStringAsFixed(0)}–'
                        '${inverter!.mpptMax.toStringAsFixed(0)} V',
                  ),
                  SpecRow(
                    label:
                        'عدد MPPT',
                    value:
                        '${inverter!.mpptCount}',
                  ),
                  SpecRow(
                    label:
                        'Max PV Current',
                    value:
                        '${inverter!.maxPvCurrent.toStringAsFixed(1)} A',
                  ),
                  SpecRow(
                    label:
                        'Max Charge',
                    value:
                        '${inverter!.maxChargeCurrent.toStringAsFixed(0)} A',
                  ),
                  SpecRow(
                    label:
                        'Max Discharge',
                    value:
                        '${inverter!.maxDischargeCurrent.toStringAsFixed(0)} A',
                  ),
                  SpecRow(
                    label:
                        'الكفاءة',
                    value:
                        '${inverter!.efficiency.toStringAsFixed(1)}%',
                  ),
                  SpecRow(
                    label:
                        'الحماية',
                    value:
                        inverter!.ipRating,
                  ),
                ],
              ),
            ),

          const SizedBox(
              height: 16),

          if (inverter != null &&
              inverter!.officialUrl
                  .isNotEmpty)
            OutlinedButton.icon(
              onPressed:
                  openOfficialWebsite,
              icon: const Icon(
                Icons.open_in_browser,
              ),
              label:
                  const Text(
                'فتح الرابط الرسمي',
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// LOCATION
// ============================================================

class LocationPage
    extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() =>
      _LocationPageState();
}

class _LocationPageState
    extends State<LocationPage> {
  final latitudeController =
      TextEditingController();

  final longitudeController =
      TextEditingController();

  double tilt = 15.0;
  String direction = 'جنوب';

  @override
  void dispose() {
    latitudeController.dispose();
    longitudeController.dispose();
    super.dispose();
  }

  double calculateApproxTilt() {
    final double? latitude =
        double.tryParse(
      latitudeController.text
          .replaceAll(',', '.'),
    );

    if (latitude == null) {
      return 15.0;
    }

    final double absLat =
        latitude.abs();

    return math.max(
      5.0,
      math.min(
        absLat + 5.0,
        30.0,
      ),
    ).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الموقع والميل',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding:
            const EdgeInsets.all(16),
        children: [
          const AppCard(
            child: Text(
              'أدخل إحداثيات الموقع للحصول على تقدير مبدئي لميل الألواح واتجاهها. هذه القيمة إرشادية ويجب تحسينها حسب الموقع الفعلي والظروف المحلية.',
            ),
          ),

          const SizedBox(
              height: 16),

          AppCard(
            child: Column(
              children: [
                TextField(
                  controller:
                      latitudeController,
                  keyboardType:
                      const TextInputType
                          .numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  decoration:
                      const InputDecoration(
                    labelText:
                        'خط العرض Latitude',
                    prefixIcon:
                        Icon(
                      Icons.location_on,
                    ),
                  ),
                ),

                const SizedBox(
                    height: 12),

                TextField(
                  controller:
                      longitudeController,
                  keyboardType:
                      const TextInputType
                          .numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  decoration:
                      const InputDecoration(
                    labelText:
                        'خط الطول Longitude',
                    prefixIcon:
                        Icon(
                      Icons.explore,
                    ),
                  ),
                ),

                const SizedBox(
                    height: 16),

                DropdownButtonFormField<
                    String>(
                  value: direction,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'الاتجاه',
                  ),
                  items:
                      const [
                    DropdownMenuItem(
                      value:
                          'جنوب',
                      child:
                          Text(
                        'جنوب',
                      ),
                    ),
                    DropdownMenuItem(
                      value:
                          'شمال',
                      child:
                          Text(
                        'شمال',
                      ),
                    ),
                    DropdownMenuItem(
                      value:
                          'شرق',
                      child:
                          Text(
                        'شرق',
                      ),
                    ),
                    DropdownMenuItem(
                      value:
                          'غرب',
                      child:
                          Text(
                        'غرب',
                      ),
                    ),
                  ],
                  onChanged:
                      (value) {
                    if (value !=
                        null) {
                      setState(() {
                        direction =
                            value;
                      });
                    }
                  },
                ),

                const SizedBox(
                    height: 18),

                FilledButton.icon(
                  onPressed: () {
                    setState(() {
                      tilt =
                          calculateApproxTilt();
                    });
                  },
                  icon:
                      const Icon(
                    Icons.calculate,
                  ),
                  label:
                      const Text(
                    'حساب الميل التقريبي',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
              height: 18),

          ResultCard(
            title:
                'النتيجة التقريبية',
            child: Column(
              children: [
                MetricCard(
                  title:
                      'الميل',
                  value:
                      '${tilt.toStringAsFixed(1)}°',
                  icon:
                      Icons.architecture,
                ),
                const SizedBox(
                    height: 12),
                MetricCard(
                  title:
                      'الاتجاه',
                  value:
                      direction,
                  icon:
                      Icons.explore,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// MORE
// ============================================================

class MorePage
    extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'المزيد',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding:
            const EdgeInsets.all(16),
        children: [
          AppCard(
            child: ListTile(
              leading:
                  const CircleAvatar(
                child: Icon(
                  Icons.info_outline,
                ),
              ),
              title: const Text(
                'عن التطبيق',
                style:
                    TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              subtitle:
                  const Text(
                'معلومات عن Sudan SO والمطور',
              ),
              trailing:
                  const Icon(
                Icons.chevron_left,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const AboutPage(),
                  ),
                );
              },
            ),
          ),

          const SizedBox(
              height: 12),

          const AppCard(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  'Sudan SO',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Solar Energy Calculator & Market',
                ),
                SizedBox(height: 8),
                Text(
                  'أداة مساعدة للمهندسين والفنيين والمستخدمين في تصميم وفهم أنظمة الطاقة الشمسية.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ABOUT
// ============================================================

class AboutPage
    extends StatelessWidget {
  const AboutPage({super.key});

  Future<void> openWhatsApp() async {
    final message =
        Uri.encodeComponent(
      'السلام عليكم، أريد التواصل بخصوص تطبيق Sudan SO.',
    );

    final uri = Uri.parse(
      'https://wa.me/249916537047?text=$message',
    );

    await launchUrl(
      uri,
      mode:
          LaunchMode.externalApplication,
    );
  }

  Future<void> openEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path:
          'SOLARSD2090@gmail.com',
      queryParameters: {
        'subject':
            'اقتراح / مشكلة في تطبيق Sudan SO',
        'body':
            'السلام عليكم،\n\n'
            'أرغب في إرسال اقتراح أو الإبلاغ عن مشكلة في تطبيق Sudan SO.\n\n'
            'نوع الرسالة:\n'
            'الاقتراح / المشكلة:\n\n'
            'تفاصيل إضافية:\n',
      },
    );

    await launchUrl(
      uri,
      mode:
          LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'عن التطبيق',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding:
            const EdgeInsets.all(16),
        children: [
          Container(
            padding:
                const EdgeInsets.all(24),
            decoration:
                BoxDecoration(
              gradient:
                  const LinearGradient(
                colors: [
                  Color(0xFF087F5B),
                  Color(0xFF0B6E4F),
                ],
              ),
              borderRadius:
                  BorderRadius.circular(
                24,
              ),
            ),
            child: const Column(
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor:
                      Colors.white,
                  child: Icon(
                    Icons.solar_power,
                    size: 48,
                    color:
                        Color(0xFF087F5B),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Sudan SO',
                  style: TextStyle(
                    color:
                        Colors.white,
                    fontSize: 28,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Solar Energy Calculator & Market',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    color:
                        Colors.white,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
              height: 20),

          const AppCard(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                SectionTitle(
                  title:
                      'عن تطبيق Sudan SO',
                  icon:
                      Icons.info_outline,
                ),
                SizedBox(
                    height: 12),
                Text(
                  'Sudan SO هو تطبيق متخصص في مجال الطاقة الشمسية، تم تصميمه ليكون أداة عملية تساعد المستخدم على إجراء الحسابات الأولية لأنظمة الطاقة الشمسية وفهم العلاقة بين الأحمال والألواح الشمسية والإنفرتر والبطاريات.',
                ),
                SizedBox(
                    height: 12),
                Text(
                  'يهدف التطبيق إلى تبسيط الحسابات الهندسية وتوفير أدوات تساعد المهندس والفني والمستخدم على الوصول إلى تصور مبدئي مناسب للنظام قبل مرحلة التنفيذ.',
                ),
              ],
            ),
          ),

          const SizedBox(
              height: 16),

          const AppCard(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                SectionTitle(
                  title:
                      'ماذا يوفر التطبيق؟',
                  icon: Icons.apps,
                ),
                SizedBox(
                    height: 12),
                InfoBullet(
                  text:
                      'حساب استهلاك الطاقة اليومي.',
                ),
                InfoBullet(
                  text:
                      'حساب الحمل الأقصى.',
                ),
                InfoBullet(
                  text:
                      'تقدير قدرة الألواح المطلوبة.',
                ),
                InfoBullet(
                  text:
                      'تقدير سعة البطاريات حسب نوع البطارية.',
                ),
                InfoBullet(
                  text:
                      'اختيار Lithium و AGM و FLD.',
                ),
                InfoBullet(
                  text:
                      'فحص تكوين Series و Parallel.',
                ),
                InfoBullet(
                  text:
                      'فحص Voc و Vmp ونطاق MPPT.',
                ),
                InfoBullet(
                  text:
                      'فحص تيار MPPT.',
                ),
                InfoBullet(
                  text:
                      'قاعدة بيانات للألواح والإنفرترات.',
                ),
                InfoBullet(
                  text:
                      'تصنيف الإنفرترات حسب الفئة.',
                ),
              ],
            ),
          ),

          const SizedBox(
              height: 16),

          const AppCard(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 38,
                  child: Icon(
                    Icons.engineering,
                    size: 42,
                  ),
                ),
                SizedBox(
                    height: 12),
                Text(
                  'مصمم ومطور التطبيق',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                SizedBox(
                    height: 5),
                Text(
                  'حمزة الطيب',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                SizedBox(
                    height: 12),
                Text(
                  'مهتم بمجال الطاقة الشمسية، وله خبرة واهتمام واسع في أنظمة الطاقة الشمسية وتصميمها وتطبيقاتها العملية.',
                  textAlign:
                      TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(
              height: 16),

          AppCard(
            child: Column(
              children: [
                const Text(
                  'تواصل مباشر',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                const SizedBox(
                    height: 14),

                SizedBox(
                  width:
                      double.infinity,
                  child:
                      FilledButton.icon(
                    onPressed:
                        openWhatsApp,
                    icon:
                        const Icon(
                      Icons.chat,
                    ),
                    label:
                        const Padding(
                      padding:
                          EdgeInsets.all(
                        12,
                      ),
                      child:
                          Text(
                        'تواصل عبر واتساب',
                        style:
                            TextStyle(
                          fontSize:
                              16,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                    height: 10),

                SizedBox(
                  width:
                      double.infinity,
                  child:
                      OutlinedButton.icon(
                    onPressed:
                        openEmail,
                    icon:
                        const Icon(
                      Icons
                          .email_outlined,
                    ),
                    label:
                        const Padding(
                      padding:
                          EdgeInsets.all(
                        12,
                      ),
                      child:
                          Text(
                        'اقتراح أو الإبلاغ عن مشكلة',
                        style:
                            TextStyle(
                          fontSize:
                              16,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                    height: 14),

                const Text(
                  'SOLARSD2090@gmail.com',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
              height: 16),

          const AppCard(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  'تنبيه هندسي',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                SizedBox(
                    height: 8),
                Text(
                  'نتائج التطبيق مخصصة للمساعدة في التصميم والحسابات الأولية. يجب دائماً مراجعة Datasheet الأصلي للمعدات وتنفيذ التصميم النهائي وفق متطلبات الموقع والكود الكهربائي والحمايات المناسبة.',
                ),
              ],
            ),
          ),

          const SizedBox(
              height: 24),

          const Center(
            child: Text(
              'Sudan SO • Solar Energy',
              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(
              height: 30),
        ],
      ),
    );
  }
}

// ============================================================
// REUSABLE WIDGETS
// ============================================================

class AppCard
    extends StatelessWidget {
  final Widget child;

  const AppCard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

class SectionTitle
    extends StatelessWidget {
  final String title;
  final IconData icon;

  const SectionTitle({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color:
              Theme.of(context)
                  .colorScheme
                  .primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style:
                const TextStyle(
              fontSize: 19,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class MetricCard
    extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color:
                  Theme.of(context)
                      .colorScheme
                      .primary,
              size: 28,
            ),
            const SizedBox(
                height: 7),
            Text(
              title,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                fontSize: 12,
              ),
            ),
            const SizedBox(
                height: 4),
            Text(
              value,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                fontSize: 17,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultCard
    extends StatelessWidget {
  final String title;
  final Widget child;

  const ResultCard({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .start,
          children: [
            Text(
              title,
              style:
                  const TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(
                height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class ToolCard
    extends StatelessWidget {
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
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        onTap: onTap,
        child: Padding(
          padding:
              const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment
                    .center,
            children: [
              Icon(
                icon,
                size: 34,
                color:
                    Theme.of(context)
                        .colorScheme
                        .primary,
              ),
              const SizedBox(
                  height: 10),
              Text(
                title,
                textAlign:
                    TextAlign.center,
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              const SizedBox(
                  height: 4),
              Text(
                subtitle,
                textAlign:
                    TextAlign.center,
                style:
                    const TextStyle(
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NumberField
    extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? suffix;
  final ValueChanged<String>?
      onChanged;

  const NumberField({
    super.key,
    required this.controller,
    required this.label,
    this.suffix,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType:
          const TextInputType
              .numberWithOptions(
        decimal: true,
      ),
      onChanged: onChanged,
      decoration:
          InputDecoration(
        labelText: label,
        suffixText: suffix,
      ),
    );
  }
}

class SpecRow
    extends StatelessWidget {
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
          const EdgeInsets.symmetric(
        vertical: 7,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style:
                const TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class CheckRow
    extends StatelessWidget {
  final String title;
  final bool ok;

  const CheckRow({
    super.key,
    required this.title,
    required this.ok,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 7,
      ),
      child: Row(
        children: [
          Icon(
            ok
                ? Icons.check_circle
                : Icons.cancel,
            color: ok
                ? Colors.green
                : Colors.red,
          ),
          const SizedBox(
              width: 10),
          Expanded(
            child: Text(title),
          ),
          Text(
            ok
                ? 'مناسب'
                : 'غير مناسب',
            style: TextStyle(
              fontWeight:
                  FontWeight.bold,
              color: ok
                  ? Colors.green
                  : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

class InfoBullet
    extends StatelessWidget {
  final String text;

  const InfoBullet({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 5,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: 20,
            color:
                Theme.of(context)
                    .colorScheme
                    .primary,
          ),
          const SizedBox(
              width: 8),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }
}

class EmptyState
    extends StatelessWidget {
  final IconData icon;
  final String title;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 60,
            color: Colors.grey,
          ),
          const SizedBox(
              height: 12),
          Text(
            title,
            style:
                const TextStyle(
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'air_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Air Quality Index',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const AirQualityPage(),
    );
  }
}

class AirQualityPage extends StatefulWidget {
  const AirQualityPage({super.key});

  @override
  State<AirQualityPage> createState() => _AirQualityPageState();
}

class _AirQualityPageState extends State<AirQualityPage> {
  final service = AirService();
  Map<String, dynamic>? airData;
  bool loading = false;

  // แปลง AQI -> ข้อความและสีตามมาตรฐาน US EPA
  Map<String, dynamic> getAqiStatus(int aqi) {
    if (aqi <= 50) {
      return {
        "text": "Good",
        "color": Colors.green,
        "bg": const Color(0xFFE8F5E9),
      };
    } else if (aqi <= 100) {
      return {
        "text": "Moderate",
        "color": const Color(0xFFFBC02D),
        "bg": const Color(0xFFFFF8E1),
      };
    } else if (aqi <= 150) {
      return {
        "text": "Unhealthy for Sensitive Groups",
        "color": Colors.orange,
        "bg": const Color(0xFFFFF3E0),
      };
    } else if (aqi <= 200) {
      return {
        "text": "Unhealthy",
        "color": Colors.red,
        "bg": const Color(0xFFFFEBEE),
      };
    } else if (aqi <= 300) {
      return {
        "text": "Very Unhealthy",
        "color": Colors.purple,
        "bg": const Color(0xFFF3E5F5),
      };
    } else {
      return {
        "text": "Hazardous",
        "color": const Color(0xFF6D4C41),
        "bg": const Color(0xFFEFEBE9),
      };
    }
  }

  Future<void> loadData() async {
    if (loading) return;
    setState(() => loading = true);
    try {
      final data = await service.fetchAirQuality();
      setState(() => airData = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    final aqi = (airData?["aqi"] ?? 0) as int;
    final status = getAqiStatus(aqi);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Air Quality Index (AQI)"),
        actions: [
          IconButton(
            tooltip: "Refresh",
            onPressed: loadData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadData,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: airData == null
                ? ListView(
                    // ให้ RefreshIndicator ทำงานได้ตอนยังโหลดไม่เสร็จ
                    children: const [
                      SizedBox(height: 160),
                      Center(child: CircularProgressIndicator()),
                    ],
                  )
                : LayoutBuilder(
                    builder: (context, c) {
                      return ListView(
                        children: [
                          Text(
                            airData!["city"],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            color: status["bg"],
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 28,
                                horizontal: 20,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // ค่า AQI ตัวใหญ่
                                  Text(
                                    aqi.toString(),
                                    style: TextStyle(
                                      fontSize: 96,
                                      fontWeight: FontWeight.w900,
                                      height: 1.0,
                                      color: status["color"],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // สถานะอากาศดี/ไม่ดี
                                  Text(
                                    status["text"],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: status["color"],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // อุณหภูมิ
                                  Text(
                                    "Temperature: ${airData!["temperature"]}°C",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // ปุ่มรีเฟรช
                          FilledButton.icon(
                            onPressed: loading ? null : loadData,
                            icon: loading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.refresh),
                            label: const Text("Refresh"),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}

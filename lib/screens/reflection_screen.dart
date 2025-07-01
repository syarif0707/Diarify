import 'package:diarify/screens/home_screen.dart';
import 'package:diarify/screens/setting_screen.dart';
import 'package:diarify/services/notification_service.dart';
import 'package:diarify/utils/app_constants.dart';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:intl/intl.dart';
import '../widgets/bottom_nav_bar.dart';

class ReflectionScreen extends StatefulWidget {
  const ReflectionScreen({super.key});

  @override
  State<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends State<ReflectionScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Map<String, int> _moodStatistics = {};
  Map<String, int> _dailyEntryCounts = {};
  Map<String, int> _weeklyEntryCounts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReflectionData();
  }

  Future<void> _loadReflectionData() async {
    setState(() {
      _isLoading = true;
    });
    if (AppConstants.currentUserId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final userId = AppConstants.currentUserId!;
    _moodStatistics = await _dbHelper.getMoodStatistics(userId);
    _dailyEntryCounts = await _dbHelper.getDailyEntryCounts(userId);
    _weeklyEntryCounts = await _dbHelper.getWeeklyEntryCounts(userId);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Your Reflections'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Mood Statistics',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          _moodStatistics.isEmpty
                              ? const Center(child: Text('No mood data available yet.'))
                              : PieChart(
                                  dataMap: _moodStatistics.map(
                                    (key, value) => MapEntry(key, value.toDouble())),
                                  animationDuration: const Duration(milliseconds: 800),
                                  chartLegendSpacing: 32,
                                  chartRadius: MediaQuery.of(context).size.width / 2.5,
                                  colorList: const [
                                    Colors.green,
                                    Colors.blue,
                                    Colors.grey,
                                    Colors.orange,
                                    Colors.red,
                                    Colors.teal,
                                    Colors.purple,
                                    Colors.pink
                                  ],
                                  initialAngleInDegree: 0,
                                  chartType: ChartType.ring,
                                  ringStrokeWidth: 32,
                                  centerText: "Moods",
                                  legendOptions: const LegendOptions(
                                    showLegendsInRow: false,
                                    legendPosition: LegendPosition.right,
                                    showLegends: true,
                                    legendTextStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  chartValuesOptions: const ChartValuesOptions(
                                    showChartValueBackground: true,
                                    showChartValues: true,
                                    showChartValuesInPercentage: true,
                                    showChartValuesOutside: false,
                                    decimalPlaces: 1,
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Daily Entry Count (Last 7 Days)',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          _dailyEntryCounts.isEmpty
                              ? const Text('No daily entries recorded.')
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _dailyEntryCounts.length,
                                  itemBuilder: (context, index) {
                                    String date = _dailyEntryCounts.keys.elementAt(index);
                                    int count = _dailyEntryCounts.values.elementAt(index);
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            DateFormat('MMM d, yyyy').format(DateTime.parse(date)),
                                            style: const TextStyle(fontSize: 16),
                                          ),
                                          Text(
                                            '$count entries',
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Weekly Entry Count (Last 4 Weeks)',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          _weeklyEntryCounts.isEmpty
                              ? const Text('No weekly entries recorded.')
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _weeklyEntryCounts.length,
                                  itemBuilder: (context, index) {
                                    String week = _weeklyEntryCounts.keys.elementAt(index);
                                    int count = _weeklyEntryCounts.values.elementAt(index);
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Week $week',
                                            style: const TextStyle(fontSize: 16),
                                          ),
                                          Text(
                                            '$count entries',
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else if (index == 2) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const SettingScreen()),
            );
          }
        },
      ),
    );
  }
}
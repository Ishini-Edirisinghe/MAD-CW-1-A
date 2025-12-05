import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/health_records.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../database/database_handler.dart';
import 'records_screen.dart';
import 'goal_screen.dart';
import 'add_health_record_screen.dart';
import '../model/health_records.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  int todaySteps = 0;
  int todayCalories = 0;
  int todayWater = 0;

  List<HealthRecord> weeklyRecords = [];

  @override
  void initState() {
    super.initState();
    _loadTodayActivity();
    _loadWeeklyData();
  }

  Future<void> _loadTodayActivity() async {
    final today = DateFormat("MM/dd/yyyy").format(DateTime.now());

    final records = await DatabaseHandler.instance.getRecords();
    final todayRecord = records.where((rec) => rec.date == today).toList();

    if (todayRecord.isNotEmpty) {
      setState(() {
        todaySteps = todayRecord.first.steps;
        todayCalories = todayRecord.first.calories;
        todayWater = todayRecord.first.water;
      });
    } else {
      setState(() {
        todaySteps = 0;
        todayCalories = 0;
        todayWater = 0;
      });
    }
  }

  Future<void> _loadWeeklyData() async {
    final all = await DatabaseHandler.instance.getRecords();

    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(
      Duration(days: now.weekday - 1),
    ); // Monday

    weeklyRecords = all.where((r) {
      DateTime d = DateFormat("MM/dd/yyyy").parse(r.date);
      return d.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
          d.isBefore(startOfWeek.add(const Duration(days: 7)));
    }).toList();

    setState(() {});
  }

  List<Widget> get _screens => [
    DashboardHome(
      steps: todaySteps,
      calories: todayCalories,
      water: todayWater,
      weeklyRecords: weeklyRecords,
      onRefresh: () async {
        await _loadTodayActivity();
        await _loadWeeklyData();
      },
    ),
    const RecordsScreen(),
    const ProfilePage(),
  ];

  void _onNavTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Records"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class DashboardHome extends StatelessWidget {
  final int steps;
  final int calories;
  final int water;
  final List<HealthRecord> weeklyRecords;
  final Function onRefresh;

  const DashboardHome({
    super.key,
    required this.steps,
    required this.calories,
    required this.water,
    required this.weeklyRecords,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: RefreshIndicator(
        onRefresh: () async => await onRefresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _header(),
              _todaySection(),
              _weeklySummaryCard(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00A77F),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddHealthRecordScreen()),
          );
          onRefresh();
        },
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  // HEADER UI
  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00C6A2), Color(0xFF00A77F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Text(
            "Dashboard",
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2),
          Text(
            "Track your health journey",
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
        ],
      ),
    );
  }

  // TODAY ACTIVITY UI
  Widget _todaySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Activity",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _activityCard(
            title: "Steps Walked",
            value: steps.toString(),
            unit: "",
            icon: Icons.directions_walk_rounded,
            color: Colors.orange,
          ),
          const SizedBox(height: 14),
          _activityCard(
            title: "Calories Burned",
            value: calories.toString(),
            unit: "kcal",
            icon: Icons.local_fire_department_rounded,
            color: Colors.redAccent,
          ),
          const SizedBox(height: 14),
          _activityCard(
            title: "Water Intake",
            value: water.toString(),
            unit: "ml",
            icon: Icons.water_drop_rounded,
            color: Colors.blueAccent,
          ),
        ],
      ),
    );
  }

  // ACTIVITY CARD UI
  Widget _activityCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "$value $unit",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
        ],
      ),
    );
  }

  // WEEKLY SUMMARY CARD
  Widget _weeklySummaryCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.bar_chart, color: Colors.green, size: 22),
                SizedBox(width: 8),
                Text(
                  "Weekly Summary",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            buildWeeklyBarChart(weeklyRecords),
          ],
        ),
      ),
    );
  }

  // WEEKLY BAR CHART
  Widget buildWeeklyBarChart(List<HealthRecord> weeklyRecords) {
    Map<int, HealthRecord?> dayData = {
      1: null,
      2: null,
      3: null,
      4: null,
      5: null,
      6: null,
      7: null,
    };

    for (var r in weeklyRecords) {
      DateTime d = DateFormat("MM/dd/yyyy").parse(r.date);
      dayData[d.weekday] = r;
    }

    List<BarChartGroupData> bars = [];

    for (int i = 1; i <= 7; i++) {
      final r = dayData[i];

      bars.add(
        BarChartGroupData(
          x: i,
          barsSpace: 4,
          barRods: [
            BarChartRodData(
              toY: (r?.steps ?? 0).toDouble(),
              color: Colors.orange,
            ),
            BarChartRodData(
              toY: (r?.calories ?? 0).toDouble(),
              color: Colors.redAccent,
            ),
            BarChartRodData(
              toY: (r?.water ?? 0).toDouble(),
              color: Colors.blueAccent,
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: false),
          barGroups: bars,
          titlesData: FlTitlesData(
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  const days = {
                    1: "Mon",
                    2: "Tue",
                    3: "Wed",
                    4: "Thu",
                    5: "Fri",
                    6: "Sat",
                    7: "Sun",
                  };

                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      days[value.toInt()] ?? "",
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

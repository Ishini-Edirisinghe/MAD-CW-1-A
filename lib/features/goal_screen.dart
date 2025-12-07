import 'package:flutter/material.dart';

class GoalPage extends StatelessWidget {
  const GoalPage({super.key});

  final int dailyStepsGoal = 8000;
  final int waterIntakeGoal = 2500;
  final int caloriesGoal = 2200; // ADDED

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: null,

      body: Column(
        children: [
          // Custom Gradient Header
          Container(
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
                  "Goals",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Health goals for you",
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
              ],
            ),
          ),

          // Body content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("Health Goals"),

                  _buildInfoCard(
                    icon: Icons.directions_walk,
                    color: Colors.orange,
                    title: "Daily Steps Goal",
                    value: "$dailyStepsGoal steps",
                  ),

                  const SizedBox(height: 15),

                  _buildInfoCard(
                    icon: Icons.water_drop,
                    color: Colors.blue,
                    title: "Water Intake Goal",
                    value: "$waterIntakeGoal ml",
                  ),

                  const SizedBox(height: 15),

                  // 🔥 ADDED: Calories Goal
                  _buildInfoCard(
                    icon: Icons.local_fire_department,
                    color: Colors.redAccent,
                    title: "Daily Calories Burn Goal",
                    value: "$caloriesGoal kcal",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Section Title Widget
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    );
  }

  // Non editable info card
  Widget _buildInfoCard({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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

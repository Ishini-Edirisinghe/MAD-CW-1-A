import 'package:flutter/material.dart';
import '../database/database_handler.dart';
import '../model/health_records.dart';

class AddHealthRecordScreen extends StatefulWidget {
  const AddHealthRecordScreen({super.key});

  @override
  State<AddHealthRecordScreen> createState() => _AddHealthRecordScreenState();
}

class _AddHealthRecordScreenState extends State<AddHealthRecordScreen> {
  final TextEditingController dateCtrl = TextEditingController();
  final TextEditingController stepsCtrl = TextEditingController();
  final TextEditingController caloriesCtrl = TextEditingController();
  final TextEditingController waterCtrl = TextEditingController();

  final DatabaseHandler dbHandler = DatabaseHandler.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("Add Health Record"),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildInputCard(
                icon: Icons.calendar_month,
                label: "Date",
                controller: dateCtrl,
                hint: "12/02/2025",
              ),
              _buildInputCard(
                icon: Icons.directions_walk,
                label: "Steps Walked",
                controller: stepsCtrl,
                hint: "e.g., 8500",
              ),
              _buildInputCard(
                icon: Icons.local_fire_department,
                label: "Calories Burned (kcal)",
                controller: caloriesCtrl,
                hint: "e.g., 420",
              ),
              _buildInputCard(
                icon: Icons.water_drop,
                label: "Water Intake (ml)",
                controller: waterCtrl,
                hint: "e.g., 2100",
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                    ),
                    onPressed: _saveRecord,
                    child: const Text("Save"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveRecord() async {
    if (dateCtrl.text.isEmpty ||
        stepsCtrl.text.isEmpty ||
        caloriesCtrl.text.isEmpty ||
        waterCtrl.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    final record = HealthRecord(
      date: dateCtrl.text,
      steps: int.parse(stepsCtrl.text),
      calories: int.parse(caloriesCtrl.text),
      water: int.parse(waterCtrl.text),
    );

    await dbHandler.insertRecord(record);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Record saved successfully!")));

    Navigator.pop(context, true);
  }

  Widget _buildInputCard({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

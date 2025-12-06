import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  // Gradient colors for reuse
  final Gradient _gradient = const LinearGradient(
    colors: [Color(0xFF00C6A2), Color(0xFF00A77F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void dispose() {
    dateCtrl.dispose();
    stepsCtrl.dispose();
    caloriesCtrl.dispose();
    waterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(gradient: _gradient),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,

            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),

            title: const Text(
              "Add Health Record",
              style: TextStyle(color: Colors.white),
            ),

            actions: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildDatePickerCard(),
              _buildInputCard(
                icon: Icons.directions_walk,
                label: "Steps Walked",
                controller: stepsCtrl,
                hint: "e.g., 8500",
                keyboardType: TextInputType.number,
              ),
              _buildInputCard(
                icon: Icons.local_fire_department,
                label: "Calories Burned (kcal)",
                controller: caloriesCtrl,
                hint: "e.g., 420",
                keyboardType: TextInputType.number,
              ),
              _buildInputCard(
                icon: Icons.water_drop,
                label: "Water Intake (ml)",
                controller: waterCtrl,
                hint: "e.g., 2100",
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),

                  // Save Button with gradient background
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    onPressed: _saveRecord,
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: _gradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 20,
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          "Save",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePickerCard() {
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
                const Icon(Icons.calendar_month, color: Color(0xFF00A77F)),
                const SizedBox(width: 8),
                const Text(
                  "Date",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: dateCtrl,
              readOnly: true,
              decoration: InputDecoration(
                hintText: "Select Date",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: const Icon(Icons.calendar_today),
              ),
              onTap: _pickDate,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    DateTime initialDate = DateTime.now();

    // If user already picked a date, parse and show it as initial date
    if (dateCtrl.text.isNotEmpty) {
      try {
        initialDate = DateFormat("MM/dd/yyyy").parse(dateCtrl.text);
      } catch (_) {}
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        dateCtrl.text = DateFormat("MM/dd/yyyy").format(pickedDate);
      });
    }
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
    TextInputType keyboardType = TextInputType.text,
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
                Icon(icon, color: Color(0xFF00A77F)),
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
              keyboardType: keyboardType,
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

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
      appBar: _buildHeader("Add Health Record"),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildDatePickerCard(),
              _buildNumberInputCard(
                icon: Icons.directions_walk,
                label: "Steps Walked",
                controller: stepsCtrl,
                hint: "e.g., 8500",
              ),
              _buildNumberInputCard(
                icon: Icons.local_fire_department,
                label: "Calories Burned (kcal)",
                controller: caloriesCtrl,
                hint: "e.g., 420",
              ),
              _buildNumberInputCard(
                icon: Icons.water_drop,
                label: "Water Intake (ml)",
                controller: waterCtrl,
                hint: "e.g., 2100",
              ),

              const SizedBox(height: 20),
              _buildButtons(_saveRecord),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildHeader(String title) {
    return PreferredSize(
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
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ],
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
              children: const [
                Icon(Icons.calendar_month, color: Color(0xFF00A77F)),
                SizedBox(width: 8),
                Text("Date", style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: dateCtrl,
              readOnly: true,
              onTap: _pickDate,
              decoration: InputDecoration(
                hintText: "Select Date",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: const Icon(Icons.calendar_today),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    DateTime initialDate = DateTime.now();
    if (dateCtrl.text.isNotEmpty) {
      try {
        initialDate = DateFormat("MM/dd/yyyy").parse(dateCtrl.text);
      } catch (_) {}
    }

    final pickedDate = await showDatePicker(
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

  Widget _buildNumberInputCard({
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
                Icon(icon, color: const Color(0xFF00A77F)),
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
              keyboardType: TextInputType.number,
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

  Widget _buildButtons(Function() saveAction) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: Colors.grey),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text("Cancel"),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: saveAction,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: const Color(0xFF00A77F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              "Save",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      ],
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
}

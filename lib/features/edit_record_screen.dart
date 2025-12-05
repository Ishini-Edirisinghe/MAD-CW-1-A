import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_handler.dart';
import '../model/health_records.dart';

class EditRecordScreen extends StatefulWidget {
  final HealthRecord record;

  const EditRecordScreen({super.key, required this.record});

  @override
  State<EditRecordScreen> createState() => _EditRecordScreenState();
}

class _EditRecordScreenState extends State<EditRecordScreen> {
  late TextEditingController dateController;
  late TextEditingController stepsController;
  late TextEditingController caloriesController;
  late TextEditingController waterController;

  @override
  void initState() {
    super.initState();

    dateController = TextEditingController(text: widget.record.date);
    stepsController = TextEditingController(
      text: widget.record.steps.toString(),
    );
    caloriesController = TextEditingController(
      text: widget.record.calories.toString(),
    );
    waterController = TextEditingController(
      text: widget.record.water.toString(),
    );
  }

  @override
  void dispose() {
    dateController.dispose();
    stepsController.dispose();
    caloriesController.dispose();
    waterController.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    DateTime initialDate;
    try {
      initialDate = DateFormat("MM/dd/yyyy").parse(dateController.text);
    } catch (_) {
      initialDate = DateTime.now();
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        dateController.text = DateFormat("MM/dd/yyyy").format(picked);
      });
    }
  }

  void _saveRecord() async {
    final updatedRecord = HealthRecord(
      id: widget.record.id,
      date: dateController.text,
      steps: int.tryParse(stepsController.text) ?? 0,
      calories: int.tryParse(caloriesController.text) ?? 0,
      water: int.tryParse(waterController.text) ?? 0,
    );

    await DatabaseHandler.instance.updateRecord(updatedRecord);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInputCard(
                      label: "Date",
                      icon: Icons.calendar_month,
                      child: TextField(
                        controller: dateController,
                        readOnly: true,
                        onTap: pickDate,
                        decoration: _inputDecoration("Select date"),
                      ),
                    ),
                    _buildInputCard(
                      label: "Steps Walked",
                      icon: Icons.directions_walk,
                      child: TextField(
                        controller: stepsController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration("e.g., 8500"),
                      ),
                    ),
                    _buildInputCard(
                      label: "Calories Burned (kcal)",
                      icon: Icons.local_fire_department,
                      child: TextField(
                        controller: caloriesController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration("e.g., 420"),
                      ),
                    ),
                    _buildInputCard(
                      label: "Water Intake (ml)",
                      icon: Icons.water_drop,
                      child: TextField(
                        controller: waterController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration("e.g., 2100"),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildButtons(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Edit Health Record",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "Update your health data",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard({
    required String label,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildButtons() {
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
            onPressed: _saveRecord,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text("Save", style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }
}

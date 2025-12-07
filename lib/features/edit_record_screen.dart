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

  final Gradient _gradient = const LinearGradient(
    colors: [Color(0xFF00C6A2), Color(0xFF00A77F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

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
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: _buildHeader(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCard(
              "Date",
              Icons.calendar_month,
              TextField(
                controller: dateController,
                readOnly: true,
                onTap: pickDate,
                decoration: _inputDecoration("Select Date"),
              ),
            ),
            _buildCard(
              "Steps Walked",
              Icons.directions_walk,
              TextField(
                controller: stepsController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration("e.g., 8500"),
              ),
            ),
            _buildCard(
              "Calories Burned (kcal)",
              Icons.local_fire_department,
              TextField(
                controller: caloriesController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration("e.g., 420"),
              ),
            ),
            _buildCard(
              "Water Intake (ml)",
              Icons.water_drop,
              TextField(
                controller: waterController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration("e.g., 2100"),
              ),
            ),
            const SizedBox(height: 16),

            // SAME BUTTONS AS ADD SCREEN
            _buildButtons(_saveRecord),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildHeader() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Container(
        decoration: BoxDecoration(gradient: _gradient),
        child: AppBar(
          title: const Text(
            "Edit Health Record",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
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

  Widget _buildCard(String label, IconData icon, Widget child) {
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
              Icon(icon, color: const Color(0xFF00A77F)),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
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
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.grey.shade100,
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
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: _gradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                child: const Text(
                  "Save",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

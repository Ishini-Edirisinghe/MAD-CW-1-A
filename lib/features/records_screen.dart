import 'package:flutter/material.dart';
import '../database/database_handler.dart';
import '../model/health_records.dart';
import 'edit_record_screen.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  final TextEditingController dateController = TextEditingController();

  List<HealthRecord> records = [];
  List<HealthRecord> allRecords = [];
  String selectedSort = "Newest";

  @override
  void initState() {
    super.initState();

    dateController.addListener(() {
      setState(() {}); // update clear button visibility
    });

    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final data = await DatabaseHandler.instance.getRecords();

    // Sort data
    if (selectedSort == "Oldest") {
      data.sort((a, b) => a.id!.compareTo(b.id!));
    } else {
      data.sort((a, b) => b.id!.compareTo(a.id!));
    }

    allRecords = data;

    // Apply date filter if exists
    if (dateController.text.isNotEmpty) {
      _filterByDate(dateController.text);
    } else {
      setState(() {
        records = allRecords;
      });
    }
  }

  void _filterByDate(String selectedDate) {
    if (selectedDate.isEmpty) {
      setState(() {
        records = allRecords;
      });
      return;
    }

    // Convert selected "MM/DD/YYYY" to DateTime
    final parts = selectedDate.split("/");
    final selected = DateTime(
      int.parse(parts[2]),
      int.parse(parts[0]),
      int.parse(parts[1]),
    );

    final filtered = allRecords.where((record) {
      try {
        DateTime dbDate;

        // If database format is YYYY-MM-DD
        if (record.date.contains("-")) {
          dbDate = DateTime.parse(record.date.trim());
        }
        // If stored as MM/DD/YYYY
        else if (record.date.contains("/")) {
          final p = record.date.split("/");
          dbDate = DateTime(int.parse(p[2]), int.parse(p[0]), int.parse(p[1]));
        } else {
          return false;
        }

        return dbDate.year == selected.year &&
            dbDate.month == selected.month &&
            dbDate.day == selected.day;
      } catch (e) {
        return false;
      }
    }).toList();

    setState(() {
      records = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: null,
      body: Column(
        children: [
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
                  "Health Records",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "View and manage your records",
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSearchField(),
                  const SizedBox(height: 12),
                  _buildSortDropdown(),
                  const SizedBox(height: 16),

                  Expanded(
                    child: records.isEmpty
                        ? const Center(
                            child: Text(
                              "No records found",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: records.length,
                            itemBuilder: (context, index) {
                              return _buildRecordCard(records[index]);
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: dateController,
      readOnly: true,
      decoration: InputDecoration(
        hintText: "Select a date",
        prefixIcon: const Icon(Icons.calendar_month),
        suffixIcon: dateController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  dateController.clear();
                  _filterByDate('');
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2035),
        );

        if (picked != null) {
          String formatted = "${picked.month}/${picked.day}/${picked.year}";

          dateController.text = formatted;
          _filterByDate(formatted);
        }
      },
    );
  }

  Widget _buildSortDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(border: InputBorder.none),
        value: selectedSort,
        items: const [
          DropdownMenuItem(
            value: "Newest",
            child: Text("Sort by Date (Newest)"),
          ),
          DropdownMenuItem(
            value: "Oldest",
            child: Text("Sort by Date (Oldest)"),
          ),
        ],
        onChanged: (value) {
          selectedSort = value ?? "Newest";
          _loadRecords();
        },
      ),
    );
  }

  Widget _buildRecordCard(HealthRecord record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      record.date,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditRecordScreen(record: record),
                          ),
                        );
                        _loadRecords();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Delete Record'),
                            content: const Text(
                              'Are you sure you want to delete this record?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true) {
                          await DatabaseHandler.instance.deleteRecord(
                            record.id!,
                          );
                          _loadRecords();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem(
                  icon: Icons.directions_walk,
                  color: Colors.orange,
                  label: "Steps",
                  value: "${record.steps}",
                ),
                _buildInfoItem(
                  icon: Icons.local_fire_department,
                  color: Colors.redAccent,
                  label: "Calories",
                  value: "${record.calories}",
                ),
                _buildInfoItem(
                  icon: Icons.water_drop,
                  color: Colors.blue,
                  label: "Water",
                  value: "${record.water} ml",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 14)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ],
    );
  }
}

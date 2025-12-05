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
  String selectedSort = "Newest";

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final data = await DatabaseHandler.instance.getRecords();

    // Optional: sort data if you want
    if (selectedSort == "Oldest") {
      data.sort((a, b) => a.id!.compareTo(b.id!));
    } else {
      data.sort((a, b) => b.id!.compareTo(a.id!));
    }

    setState(() {
      records = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false,
        title: const Text(
          "Health Records",
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(30),
          child: Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              "View and manage your records",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ),
      ),

      body: Padding(
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
                        style: TextStyle(fontSize: 18, color: Colors.grey),
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
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: dateController,
      decoration: InputDecoration(
        hintText: "mm/dd/yyyy",
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (value) {
        // Optional: implement search filtering here
        // For now, just re-load all records or filter the list manually
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
          setState(() {
            selectedSort = value ?? "Newest";
            _loadRecords();
          });
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
            /// --- TITLE + ACTION ICONS ROW ---
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
                        _loadRecords(); // Refresh after edit
                      },
                    ),

                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        // Confirm delete dialog
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

            /// --- INFO ROW ---
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

// import 'package:flutter/material.dart';
// import 'edit_record_screen.dart';

// class RecordsScreen extends StatefulWidget {
//   const RecordsScreen({super.key});

//   @override
//   State<RecordsScreen> createState() => _RecordsScreenState();
// }

// class _RecordsScreenState extends State<RecordsScreen> {
//   final TextEditingController dateController = TextEditingController();

//   List<Map<String, dynamic>> records = [
//     {
//       "date": "November 28, 2025",
//       "steps": 8500,
//       "calories": 420,
//       "water": 2100,
//     },
//     {
//       "date": "November 27, 2025",
//       "steps": 12000,
//       "calories": 580,
//       "water": 2500,
//     },
//     {
//       "date": "November 26, 2025",
//       "steps": 9000,
//       "calories": 500,
//       "water": 1900,
//     },
//   ];

//   String selectedSort = "Newest";

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade100,

//       appBar: AppBar(
//         backgroundColor: Colors.green,
//         automaticallyImplyLeading: false,
//         title: const Text(
//           "Health Records",
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 32,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         bottom: const PreferredSize(
//           preferredSize: Size.fromHeight(30),
//           child: Padding(
//             padding: EdgeInsets.only(bottom: 10),
//             child: Text(
//               "View and manage your records",
//               style: TextStyle(color: Colors.white70, fontSize: 14),
//             ),
//           ),
//         ),
//       ),

//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             _buildSearchField(),
//             const SizedBox(height: 12),

//             _buildSortDropdown(),
//             const SizedBox(height: 16),

//             Expanded(
//               child: ListView.builder(
//                 itemCount: records.length,
//                 itemBuilder: (context, index) {
//                   return _buildRecordCard(records[index], index);
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ------------------- SEARCH FIELD ---------------------
//   Widget _buildSearchField() {
//     return TextField(
//       controller: dateController,
//       decoration: InputDecoration(
//         hintText: "mm/dd/yyyy",
//         prefixIcon: const Icon(Icons.search),
//         filled: true,
//         fillColor: Colors.white,
//         contentPadding: const EdgeInsets.symmetric(vertical: 14),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14),
//           borderSide: BorderSide.none,
//         ),
//       ),
//     );
//   }

//   // ------------------- SORT DROPDOWN ---------------------
//   Widget _buildSortDropdown() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: DropdownButtonFormField(
//         decoration: const InputDecoration(border: InputBorder.none),
//         value: selectedSort,
//         items: const [
//           DropdownMenuItem(
//             value: "Newest",
//             child: Text("Sort by Date (Newest)"),
//           ),
//           DropdownMenuItem(
//             value: "Oldest",
//             child: Text("Sort by Date (Oldest)"),
//           ),
//         ],
//         onChanged: (value) {
//           setState(() => selectedSort = value.toString());
//         },
//       ),
//     );
//   }

//   // ------------------- RECORD CARD ---------------------
//   Widget _buildRecordCard(Map<String, dynamic> record, int index) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       elevation: 1,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             /// --- TITLE + ACTION ICONS ROW ---
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     const Icon(Icons.calendar_today, color: Colors.green),
//                     const SizedBox(width: 8),
//                     Text(
//                       record["date"],
//                       style: const TextStyle(
//                         fontWeight: FontWeight.w600,
//                         fontSize: 16,
//                       ),
//                     ),
//                   ],
//                 ),

//                 Row(
//                   children: [
//                     IconButton(
//                       icon: const Icon(Icons.edit, color: Colors.blue),
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) =>
//                                 EditRecordScreen(record: records[index]),
//                           ),
//                         );
//                       },
//                     ),

//                     IconButton(
//                       icon: const Icon(Icons.delete, color: Colors.red),
//                       onPressed: () {
//                         setState(() {
//                           records.removeAt(index);
//                         });
//                       },
//                     ),
//                   ],
//                 ),
//               ],
//             ),

//             const SizedBox(height: 12),

//             /// --- INFO ROW ---
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 _buildInfoItem(
//                   icon: Icons.multitrack_audio_rounded,
//                   color: Colors.orange,
//                   label: "Steps",
//                   value: "${record["steps"]}",
//                 ),
//                 _buildInfoItem(
//                   icon: Icons.local_fire_department,
//                   color: Colors.redAccent,
//                   label: "Calories",
//                   value: "${record["calories"]}",
//                 ),
//                 _buildInfoItem(
//                   icon: Icons.water_drop,
//                   color: Colors.blue,
//                   label: "Water",
//                   value: "${record["water"]} ml",
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ------------------- INFO ITEM ---------------------
//   Widget _buildInfoItem({
//     required IconData icon,
//     required Color color,
//     required String label,
//     required String value,
//   }) {
//     return Column(
//       children: [
//         Icon(icon, color: color, size: 28),
//         const SizedBox(height: 4),
//         Text(label, style: const TextStyle(fontSize: 14)),
//         Text(
//           value,
//           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
//         ),
//       ],
//     );
//   }
// }

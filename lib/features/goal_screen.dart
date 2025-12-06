import 'package:flutter/material.dart';

class GoalPage extends StatelessWidget {
  const GoalPage({super.key});

  final int dailyStepsGoal = 8000;
  final int waterIntakeGoal = 2500;
  final int currentStreak = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // light background

      appBar: null, // remove default app bar

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

                  const SizedBox(height: 25),

                  _sectionTitle("Current Streak"),

                  _buildInfoCard(
                    icon: Icons.local_fire_department,
                    color: Colors.redAccent,
                    title: "Current Streak",
                    value: "$currentStreak Days",
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

// import 'package:flutter/material.dart';

// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});

//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {
//   final TextEditingController usernameController = TextEditingController();

//   String username = "Health User";
//   int dailyStepsGoal = 8000;
//   int waterIntakeGoal = 2500;
//   int currentStreak = 5;

//   @override
//   Widget build(BuildContext context) {
//     usernameController.text = username;

//     return Scaffold(
//       backgroundColor: Colors.grey.shade100,

//       appBar: AppBar(
//         backgroundColor: Colors.green,
//         automaticallyImplyLeading: false,
//         title: const Text("Profile"),
//         bottom: const PreferredSize(
//           preferredSize: Size.fromHeight(30),
//           child: Padding(
//             padding: EdgeInsets.only(bottom: 10),
//             child: Text(
//               "Manage your profile",
//               style: TextStyle(color: Colors.white70, fontSize: 14),
//             ),
//           ),
//         ),
//       ),

//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Username Section Title
//             _sectionTitle("Username"),

//             // Username Field
//             _buildEditableUsername(),

//             const SizedBox(height: 10),

//             // Save Button (Moved here)
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green,
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 onPressed: () {
//                   setState(() {
//                     username = usernameController.text;
//                   });

//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text("Username Updated Successfully!"),
//                       backgroundColor: Colors.green,
//                     ),
//                   );
//                 },
//                 child: const Text(
//                   "Save Username",
//                   style: TextStyle(
//                     fontSize: 17,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 25),

//             // Health Goals Section
//             _sectionTitle("Health Goals"),

//             _buildInfoCard(
//               icon: Icons.directions_walk,
//               color: Colors.orange,
//               title: "Daily Steps Goal",
//               value: "$dailyStepsGoal steps",
//             ),

//             const SizedBox(height: 15),

//             _buildInfoCard(
//               icon: Icons.water_drop,
//               color: Colors.blue,
//               title: "Water Intake Goal",
//               value: "$waterIntakeGoal ml",
//             ),

//             const SizedBox(height: 25),

//             // Streak Section
//             _sectionTitle("Current Streak"),

//             _buildInfoCard(
//               icon: Icons.local_fire_department,
//               color: Colors.redAccent,
//               title: "Current Streak",
//               value: "$currentStreak Days",
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Section Title Widget
//   Widget _sectionTitle(String text) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 6),
//       child: Text(
//         text,
//         style: const TextStyle(
//           fontSize: 18,
//           fontWeight: FontWeight.w700,
//           color: Colors.black87,
//         ),
//       ),
//     );
//   }

//   // Editable Username Field
//   Widget _buildEditableUsername() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: TextField(
//         controller: usernameController,
//         decoration: const InputDecoration(
//           labelText: "Enter Username",
//           border: InputBorder.none,
//         ),
//       ),
//     );
//   }

//   // Non editable info card
//   Widget _buildInfoCard({
//     required IconData icon,
//     required Color color,
//     required String title,
//     required String value,
//   }) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
//         child: Row(
//           children: [
//             Icon(icon, color: color, size: 32),
//             const SizedBox(width: 15),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   value,
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

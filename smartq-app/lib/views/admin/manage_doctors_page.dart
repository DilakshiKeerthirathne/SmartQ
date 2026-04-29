import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/doctor_viewmodel.dart';
import 'add_doctor_page.dart';

class ManageDoctorsPage extends StatefulWidget {
  const ManageDoctorsPage({super.key});

  @override
  State<ManageDoctorsPage> createState() => _ManageDoctorsPageState();
}

class _ManageDoctorsPageState extends State<ManageDoctorsPage> {
  String searchText = "";
  String selectedDepartment = "All";

  final List<String> departments = [
    "All",
    "General",
    "Dental",
    "Pediatrics",
    "Cardiology",
    "Radiology",
  ];

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<DoctorViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Doctors"),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddDoctorPage()),
          );
        },
        child: const Icon(Icons.add),
      ),

      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search doctor...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value.toLowerCase();
                });
              },
            ),
          ),

         
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: DropdownButtonFormField<String>(
              initialValue: selectedDepartment,
              items: departments
                  .map((d) => DropdownMenuItem(
                        value: d,
                        child: Text(d),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedDepartment = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: "Filter by Department",
                border: OutlineInputBorder(),
              ),
            ),
          ),

          const SizedBox(height: 10),

          
          Expanded(
            child: StreamBuilder(
              stream: vm.getDoctors(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                // FILTER LOGIC (kept in UI ONLY for display)
                final filtered = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  final name = data['name'].toString().toLowerCase();
                  final dept = data['department'];

                  final matchesSearch = name.contains(searchText);
                  final matchesDept = selectedDepartment == "All"
                      ? true
                      : dept == selectedDepartment;

                  return matchesSearch && matchesDept;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text("No doctors found"));
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final d = filtered[index];
                    final data = d.data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        leading: const Icon(Icons.local_hospital),

                        title: Text(data['name']),
                        subtitle: Text(data['department']),

                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                vm.deleteDoctor(d.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/doctor_viewmodel.dart';

class AddDoctorPage extends StatefulWidget {
  const AddDoctorPage({super.key});

  @override
  State<AddDoctorPage> createState() => _AddDoctorPageState();
}

class _AddDoctorPageState extends State<AddDoctorPage> {

  final nameController = TextEditingController();
  final deptController = TextEditingController();
  final queueController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<DoctorViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Add Doctor")),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Doctor Name"),
            ),

            TextField(
              controller: deptController,
              decoration: const InputDecoration(labelText: "Department"),
            ),

            TextField(
              controller: queueController,
              decoration: const InputDecoration(labelText: "Queue"),
            ),

            const SizedBox(height: 20),

            vm.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      await vm.addDoctor(
                        nameController.text,
                        deptController.text,
                        queueController.text,
                      );

                      if (vm.error == null) {
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Doctor Added")),
                        );
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                      }
                    },
                    child: const Text("Add Doctor"),
                  )
          ],
        ),
      ),
    );
  }
}

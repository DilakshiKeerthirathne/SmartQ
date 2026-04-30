import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/admin_viewmodel.dart';
import 'manage_doctors_page.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AdminViewModel>(context);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 39, 65, 121),

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Admin Panel",
          style: TextStyle(
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 26, 42, 78),
      ),

      body: Column(
        children: [
          const SizedBox(height: 20),

          
          if (vm.error != null)
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                vm.error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),

          const SizedBox(height: 10),

        
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              SizedBox(
                width: 140,
                child: ElevatedButton.icon(
                onPressed: vm.isLoading
                   ? null
                   : () async {
                    final error = await vm.callNext();

                  if (error != null && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error)),
                    );
                  } else if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Next patient called"),
                      ),
                    );
                  }
                },

               icon: vm.isLoading
                   ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                    ),
                    )
                   : const Icon(Icons.skip_next),
                  label: const Text("Serve"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  ),
                ),

    
              SizedBox(
                width: 140,
                child: ElevatedButton.icon(
                  onPressed: vm.togglePause,
                  icon: const Icon(Icons.pause),
                  label: const Text("Pause"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                ),
              ),
            ),

    
          SizedBox(
            width: 140,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ManageDoctorsPage(),
                  ),
                );
              },
        
        
              icon: const Icon(Icons.medical_services),
              label: const Text("Doctors"),
              style: ElevatedButton.styleFrom(
                 backgroundColor: Colors.blueAccent,
              ),
            ),
          ),
          ],
          ),

          const SizedBox(height: 20),

          
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: vm.queueStream,
              builder: (context, snapshot) {

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error: ${snapshot.error}",
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }

                final tickets = snapshot.data ?? [];

                if (tickets.isEmpty) {
                  return const Center(
                    child: Text(
                      "No tickets",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: tickets.length,
                  itemBuilder: (context, index) {
                    final t = tickets[index];

                    Color color;
                    switch (t['status']) {
                      case "Completed":
                        color = Colors.green;
                        break;
                      case "Called":
                        color = Colors.blue;
                        break;
                      default:
                        color = Colors.orange;
                    }

                    return Card(
                      child: ListTile(
                        title: Text(t['ticketNumber'] ?? ''),
                        subtitle: Text(t['status'] ?? ''),
                        trailing: Icon(Icons.circle, color: color),
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
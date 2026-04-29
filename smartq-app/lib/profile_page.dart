import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../theme_provider.dart';
import '../../viewmodels/profile_viewmodel.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser;

  Future<void> editName(String currentName) async {
    final vm = Provider.of<ProfileViewModel>(context, listen: false);
    TextEditingController controller =
        TextEditingController(text: currentName);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Name"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: "Enter new name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await vm.updateName(
                  user!.uid,
                  controller.text.trim(),
                );

                if (vm.error != null) {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(vm.error!)),
                  );
                }

                // ignore: use_build_context_synchronously
                Navigator.pop(context);
                setState(() {});
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> changePassword() async {
    TextEditingController controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Change Password"),
          content: TextField(
            controller: controller,
            obscureText: true,
            decoration: const InputDecoration(labelText: "New Password"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await user!.updatePassword(controller.text.trim());

                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);

                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Password updated")),
                  );
                } catch (e) {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Re-login required to change password"),
                    ),
                  );
                }
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final _ = Provider.of<ProfileViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile",style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xFF1E2A47),
      ),

      body:Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/profile.jpg",
              fit: BoxFit.cover,
            ) 
          ),

          Positioned.fill(
            child:Container(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.4),
            ) 
          ),
        
       
        FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
            .collection("users")
            .doc(user!.uid)
            .get(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                children: [

                  const SizedBox(height: 30),

                  const CircleAvatar(
                    radius: 55,
                    child: Icon(Icons.person, size: 60),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Column(
                      children: [

                        ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(data['name']),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => editName(data['name']),
                          ),
                        ),

                        const Divider(),

                        ListTile(
                          leading: const Icon(Icons.email),
                          title: Text(data['email']),
                        ),

                        const Divider(),

                        Consumer<ThemeProvider>(
                          builder: (context, themeProvider, child) {
                            return ListTile(
                              leading: const Icon(Icons.dark_mode),
                              title: const Text("Dark Mode"),
                              trailing: Switch(
                                value: themeProvider.isDarkMode,
                                onChanged: themeProvider.toggleTheme,
                              ),
                            );
                          },
                        ),

                        const Divider(),

                        ListTile(
                          leading: const Icon(Icons.lock),
                          title: const Text("Change Password"),
                          onTap: changePassword,
                        ),

                        const Divider(),

                        ListTile(
                          leading: const Icon(Icons.badge),
                          title: const Text("Role"),
                          trailing: Text(data['role']),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: logout,
                      icon: const Icon(Icons.logout),
                      label: const Text("Logout"),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      ]
      )
    );
  }
}
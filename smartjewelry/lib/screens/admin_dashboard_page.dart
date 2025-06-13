import 'package:flutter/material.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({Key? key}) : super(key: key);

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int selectedIndex = 0;
  int priceFilter = 0;
  String searchQuery = '';
  String roleFilter = 'All';

  List<Map<String, dynamic>> users = [
    {
      "name": "Yahya",
      "email": "yahya@example.com",
      "role": "admin",
      "savedDesigns": [
        {"imagePath": "assets/images/ring1.jpg", "price": 5000, "weight": "10g"}
      ],
      "generatedImages": [
        {"imagePath": "assets/images/ring1.jpg", "price": 5000, "weight": "10g"},
        {"imagePath": "assets/images/ring2.jpg", "price": 4500, "weight": "8g"},
      ]
    },
    {
      "name": "Noha",
      "email": "noha@example.com",
      "role": "user",
      "savedDesigns": [
        {"imagePath": "assets/images/ring3.jpg", "price": 3200, "weight": "6g"}
      ],
      "generatedImages": [
        {"imagePath": "assets/images/ring3.jpg", "price": 3200, "weight": "6g"}
      ]
    }
  ];

  Widget buildSidebarButton(String label, IconData icon, int index) {
    return ListTile(
      leading: Icon(icon, color: selectedIndex == index ? Colors.black : const Color(0xFFD4AF37)),
      tileColor: selectedIndex == index ? const Color(0xFFD4AF37) : Colors.transparent,
      title: Text(label,
          style: TextStyle(
            color: selectedIndex == index ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          )),
      onTap: () => setState(() => selectedIndex = index),
    );
  }

  Widget statCard(String label, int value) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD4AF37)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 10),
          Text('$value', style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 32, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget buildStatsHome() {
    int totalUsers = users.length;
    int totalAdmins = users.where((u) => u['role'] == 'admin').length;
    int totalSaved = users.fold(0, (sum, u) => sum + ((u['savedDesigns'] ?? []) as List).length);
    int totalGenerated = users.fold(0, (sum, u) => sum + ((u['generatedImages'] ?? []) as List).length);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: GridView(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 20, mainAxisSpacing: 20, childAspectRatio: 1.2,
        ),
        children: [
          statCard("Total Users", totalUsers),
          statCard("Admins", totalAdmins),
          statCard("Saved Designs", totalSaved),
          statCard("Generated Images", totalGenerated),
        ],
      ),
    );
  }

  Widget buildImagesSection(String title, String key) {
    List<Map<String, dynamic>> allImages = [];
    for (var user in users) {
      allImages.addAll((user[key] as List).map((img) => {
            ...img,
            "generatedBy": user['name'],
            "user": user,
          }));
    }

    List<Map<String, dynamic>> filtered = [...allImages];
    if (priceFilter > 0) {
      filtered = filtered.where((img) => (img['price'] ?? 0) > priceFilter).toList();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Text(title, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 20)),
              const Spacer(),
              DropdownButton<int>(
                dropdownColor: Colors.grey[900],
                value: priceFilter,
                iconEnabledColor: const Color(0xFFD4AF37),
                items: [0, 3000, 4000, 5000].map((p) {
                  return DropdownMenuItem(
                    value: p,
                    child: Text(
                      p == 0 ? "All Prices" : "Price > $p",
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => priceFilter = val ?? 0),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final img = filtered[index];
              final code = 'IMG-${(index + 1).toString().padLeft(3, '0')}';
              final user = img['user'];
              final listKey = key == 'savedDesigns' ? 'savedDesigns' : 'generatedImages';

              return Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Image.asset(img['imagePath'], width: 50, height: 50),
                  title: Text("$code - ${img['price']} EGP", style: const TextStyle(color: Colors.white)),
                  subtitle: Text("Weight: ${img['weight']} • By: ${img['generatedBy']}", style: const TextStyle(color: Colors.white54)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    tooltip: "Delete Image",
                    onPressed: () {
                      setState(() {
                        (user[listKey] as List).remove(img);
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildUserList(List<Map<String, dynamic>> list) {
    return ListView.builder(
      itemCount: list.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final user = list[index];
        return Card(
          color: Colors.grey[900],
          child: ListTile(
            title: Text(user['name'], style: const TextStyle(color: Colors.white)),
            subtitle: Text(user['email'], style: const TextStyle(color: Colors.white60)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(user['role'], style: const TextStyle(color: Color(0xFFD4AF37))),
                IconButton(
                  icon: const Icon(Icons.swap_horiz, color: Colors.white),
                  tooltip: "Toggle Role",
                  onPressed: () {
                    setState(() {
                      user['role'] = user['role'] == 'admin' ? 'user' : 'admin';
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() => users.remove(user));
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildContent() {
    switch (selectedIndex) {
      case 0:
        return buildStatsHome();
      case 1:
        return buildImagesSection("All Generated Images", "generatedImages");
      case 2:
        return buildImagesSection("Saved Designs", "savedDesigns");
      case 3:
        return buildUserList(users);
      case 4:
        return buildUserList(users.where((u) => u['role'] == 'admin').toList());
      case 5:
        return buildUserList(users.where((u) => u['role'] == 'user').toList());
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 220,
            color: Colors.grey[850],
            child: Column(
              children: [
                const DrawerHeader(
                  child: Text('Admin Menu',
                      style: TextStyle(color: Color(0xFFD4AF37), fontSize: 20)),
                ),
                buildSidebarButton("Home", Icons.dashboard, 0),
                buildSidebarButton("All Images", Icons.image, 1),
                buildSidebarButton("Saved Designs", Icons.save, 2),
                buildSidebarButton("Users", Icons.people, 3),
                buildSidebarButton("Admins", Icons.security, 4),
                buildSidebarButton("Regular Users", Icons.person_outline, 5),
              ],
            ),
          ),
          Expanded(child: buildContent()),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'saved_designs_page.dart';
import 'profile_page.dart';
import 'edit_design_page.dart';
import 'welcome_screen.dart';

class GeneratePage extends StatefulWidget {
  const GeneratePage({super.key});

  @override
  _GeneratePageState createState() => _GeneratePageState();
}

class _GeneratePageState extends State<GeneratePage> {
  final TextEditingController _controller = TextEditingController();
  List<String> generatedImages = [
    'assets/images/ring1.jpg',
    'assets/images/ring2.jpg',
    'assets/images/ring3.jpg',
  ];
  int currentIndex = 0;
  List<Map<String, dynamic>> savedDesigns = [];

  void generateDesign() {
    setState(() => currentIndex = 0);
  }

  void nextImage() {
    setState(() {
      if (currentIndex < generatedImages.length - 1) currentIndex++;
    });
  }

  void previousImage() {
    setState(() {
      if (currentIndex > 0) currentIndex--;
    });
  }

  void handleVoiceInput() {
    print('Voice input triggered');
  }

  void _navigateWithSlide(Widget page) {
    Navigator.pop(context);
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          final offsetAnimation = Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ));
          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _navigateToEdit() {
    final design = {
      'imagePath': generatedImages[currentIndex],
      'price': 3450 + currentIndex * 250,
    };

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => EditDesignPage(design: design),
        transitionsBuilder: (context, animation, __, child) {
          final curved =
              CurvedAnimation(parent: animation, curve: Curves.easeInOut);
          return ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(curved),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 1.0),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      drawer: Drawer(
        child: Container(
          color: Colors.black,
          child: Column(
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Color(0xFFD4AF37)),
                child: Center(
                  child: Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person, color: Color(0xFFD4AF37)),
                title: const Text('Profile',
                    style: TextStyle(color: Colors.white)),
                onTap: () => _navigateWithSlide(const ProfilePage()),
              ),
              ListTile(
                leading: const Icon(Icons.favorite, color: Color(0xFFD4AF37)),
                title: const Text('Saved Designs',
                    style: TextStyle(color: Colors.white)),
                onTap: () => _navigateWithSlide(
                    SavedDesignsPage(savedDesigns: savedDesigns)),
              ),
              const Spacer(),
              const Divider(color: Colors.white),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title:
                    const Text('Log Out', style: TextStyle(color: Colors.red)),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Jewelry Jinn',
          style: TextStyle(
            color: Color(0xFFD4AF37),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.mic, color: Color(0xFFD4AF37)),
                    onPressed: handleVoiceInput,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                      decoration: const InputDecoration.collapsed(
                        hintText: 'Describe your dream jewelry...',
                        hintStyle: TextStyle(color: Colors.white54),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.auto_fix_high,
                        color: Color(0xFFD4AF37)),
                    onPressed: generateDesign,
                  )
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Center(
              child: Text(
                'Saved Designs',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black45,
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        generatedImages[currentIndex],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios,
                            color: Color(0xFFD4AF37)),
                        onPressed: previousImage,
                      ),
                      Text(
                        '${currentIndex + 1} / ${generatedImages.length}',
                        style: const TextStyle(
                          color: Color(0xFFD4AF37),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios,
                            color: Color(0xFFD4AF37)),
                        onPressed: nextImage,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      final design = {
                        'imagePath': generatedImages[currentIndex],
                        'price': 3450 + currentIndex * 250,
                      };
                      if (!savedDesigns
                          .any((d) => d['imagePath'] == design['imagePath'])) {
                        setState(() {
                          savedDesigns.add(design);
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: Colors.black,
                      minimumSize: const Size(180, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    icon: const Icon(Icons.save),
                    label: const Text('Save Design'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _navigateToEdit, // ✅ NEW: open edit page
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFD4AF37),
                      minimumSize: const Size(180, 45),
                      side: const BorderSide(color: Color(0xFFD4AF37)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Design'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

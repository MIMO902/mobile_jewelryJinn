import 'package:flutter/material.dart';

class EditDesignPage extends StatefulWidget {
  final Map<String, dynamic> design;

  const EditDesignPage({super.key, required this.design});

  @override
  _EditDesignPageState createState() => _EditDesignPageState();
}

class _EditDesignPageState extends State<EditDesignPage> {
  List<Offset> currentBrush = [];
  List<Map<String, dynamic>> allEdits = [];
  final TextEditingController _descriptionController = TextEditingController();

  void _onPanUpdate(DragUpdateDetails details, RenderBox box) {
    final local = box.globalToLocal(details.globalPosition);
    setState(() => currentBrush.add(local));
  }

  void _onPanEnd(_) {
    setState(() {
      if (currentBrush.isNotEmpty) {
        currentBrush.add(Offset.zero); // Marks the end of one stroke
      }
    });
  }

  void _showEditBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets.add(const EdgeInsets.all(16)),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Describe your selection',
                  style: TextStyle(color: Color(0xFFD4AF37), fontSize: 18),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _descriptionController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Change the gemstone to ruby...',
                    hintStyle: TextStyle(color: Colors.white54),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFD4AF37), width: 2),
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_descriptionController.text.trim().isEmpty) return;

                      setState(() {
                        allEdits.add({
                          'description': _descriptionController.text.trim(),
                          'points': [...currentBrush],
                        });
                        currentBrush.clear();
                        _descriptionController.clear();
                      });

                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("Apply"),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _removeEdit(int index) {
    setState(() => allEdits.removeAt(index));
  }

  void _clearAll() {
    setState(() {
      allEdits.clear();
      currentBrush.clear();
    });
  }

  void _undoLastStroke() {
    setState(() {
      if (currentBrush.isNotEmpty) {
        currentBrush.removeLast();
        while (currentBrush.isNotEmpty && currentBrush.last != Offset.zero) {
          currentBrush.removeLast();
        }
        if (currentBrush.isNotEmpty) currentBrush.removeLast(); // remove trailing zero
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final design = widget.design;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
        title: const Text('Edit Design', style: TextStyle(color: Color(0xFFD4AF37))),
        actions: [
          if (currentBrush.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.undo),
              tooltip: 'Undo Last Stroke',
              onPressed: _undoLastStroke,
            ),
          if (allEdits.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              tooltip: 'Clear All',
              onPressed: _clearAll,
            )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              allEdits.isEmpty
                  ? '🖌️ Brush over parts of the image to edit'
                  : '✅ ${allEdits.length} edit(s) added',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 260,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          design['imagePath'],
                          fit: BoxFit.cover,
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                        ),
                      ),
                      Positioned.fill(
                        child: Builder(
                          builder: (context) {
                            final box = context.findRenderObject() as RenderBox?;
                            return GestureDetector(
                              onPanUpdate: (details) {
                                if (box != null) _onPanUpdate(details, box);
                              },
                              onPanEnd: _onPanEnd,
                              child: CustomPaint(
                                painter: MultiBrushPainter(
                                  current: currentBrush,
                                  all: allEdits.map((e) => e['points'] as List<Offset>).toList(),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            if (allEdits.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD4AF37)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Edits:", style: TextStyle(color: Color(0xFFD4AF37))),
                    ...List.generate(allEdits.length, (index) {
                      return ListTile(
                        title: Text(
                          allEdits[index]['description'],
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _removeEdit(index),
                        ),
                      );
                    }),
                  ],
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: currentBrush.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _showEditBottomSheet,
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.black,
              icon: const Icon(Icons.check),
              label: const Text('Apply Edit'),
            )
          : null,
    );
  }
}

class MultiBrushPainter extends CustomPainter {
  final List<Offset> current;
  final List<List<Offset>> all;

  MultiBrushPainter({required this.current, required this.all});

  @override
  void paint(Canvas canvas, Size size) {
    final brush = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.5)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    for (final stroke in all) {
      for (int i = 0; i < stroke.length - 1; i++) {
        if (stroke[i] != Offset.zero && stroke[i + 1] != Offset.zero) {
          canvas.drawLine(stroke[i], stroke[i + 1], brush);
        }
      }
    }

    for (int i = 0; i < current.length - 1; i++) {
      if (current[i] != Offset.zero && current[i + 1] != Offset.zero) {
        canvas.drawLine(current[i], current[i + 1], brush);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

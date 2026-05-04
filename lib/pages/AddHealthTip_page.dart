import 'package:flutter/material.dart';

class AddHealthTipPage extends StatefulWidget {
  const AddHealthTipPage({super.key});

  @override
  State<AddHealthTipPage> createState() => _AddHealthTipPageState();
}

class _AddHealthTipPageState extends State<AddHealthTipPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _personNameController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _shortTipController = TextEditingController();

  String _selectedType = 'Doctor';
  String _selectedEmoji = '💙';
  Color _selectedColor = const Color(0xFFFDFFB6);

  final List<String> _types = ['Doctor', 'Volunteer', 'Companion'];

  final List<Map<String, dynamic>> _emojiOptions = [
    {'emoji': '😴', 'color': Color(0xFFFDFFB6)},
    {'emoji': '🥗', 'color': Color(0xFFFFC6FF)},
    {'emoji': '🧠', 'color': Color(0xFFFFADAD)},
    {'emoji': '💧', 'color': Color(0xFF9BF6FF)},
    {'emoji': '❤️', 'color': Color(0xFFCAFFBF)},
    {'emoji': '💙', 'color': Color(0xFFC5E7F5)},
  ];

  @override
  void dispose() {
    _personNameController.dispose();
    _titleController.dispose();
    _shortTipController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF4F4F4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  void _saveTip() {
    if (!_formKey.currentState!.validate()) return;

    final Map<String, dynamic> newTip = {
      'personName': _personNameController.text.trim(),
      'personType': _selectedType,
      'title': _titleController.text.trim(),
      'shortTip': _shortTipController.text.trim(),
      'emoji': _selectedEmoji,
      'color': _selectedColor.value,
    };

    Navigator.pop(context, newTip);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F4F4),
        appBar: AppBar(
          backgroundColor: const Color(0xFF87CEEB),
          elevation: 0,
          title: const Text(
            'Add Health Tip',
            style: TextStyle(color: Colors.black),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Create New Tip',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _personNameController,
                      decoration: _inputDecoration('Person Name'),
                      validator: (value) {
                        if ((value ?? '').trim().isEmpty) {
                          return 'Please enter person name';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      initialValue: _selectedType,
                      decoration: _inputDecoration('Person Type'),
                      items: _types.map((type) {
                        return DropdownMenuItem(value: type, child: Text(type));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _titleController,
                      decoration: _inputDecoration('Tip Title'),
                      validator: (value) {
                        if ((value ?? '').trim().isEmpty) {
                          return 'Please enter tip title';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _shortTipController,
                      maxLines: 4,
                      decoration: _inputDecoration('Short Tip'),
                      validator: (value) {
                        if ((value ?? '').trim().isEmpty) {
                          return 'Please enter tip description';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Choose Tip Style',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _emojiOptions.map((item) {
                        final bool isSelected = _selectedEmoji == item['emoji'];

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedEmoji = item['emoji'];
                              _selectedColor = item['color'];
                            });
                          },
                          child: Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              color: item['color'],
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.black
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                item['emoji'],
                                style: const TextStyle(fontSize: 28),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _saveTip,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF87CEEB),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Save Tip',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

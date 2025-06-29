import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/diary_entry.dart';
import '../utils/app_constants.dart';
import '../widgets/bottom_nav_bar.dart';
import 'home_screen.dart';
import 'reflection_screen.dart';

class AddEditEntryScreen extends StatefulWidget {
  final DiaryEntry? diaryEntry; // For editing existing entry
  final DateTime initialDate; // Date from Home screen's date picker
  final String? imageSource; // 'camera' or 'gallery' for direct image picking

  const AddEditEntryScreen({
    super.key,
    this.diaryEntry,
    required this.initialDate,
    this.imageSource,
  });

  @override
  State<AddEditEntryScreen> createState() => _AddEditEntryScreenState();
}

class _AddEditEntryScreenState extends State<AddEditEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _imageCaptionController = TextEditingController();
  String? _selectedMood;
  DateTime? _entryDate;
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  final List<String> _moodOptions = [
    'Happy',
    'Sad',
    'Neutral',
    'Excited',
    'Angry',
    'Relaxed',
    'Anxious',
    'Motivated'
  ];

  @override
  void initState() {
    super.initState();
    _entryDate = widget.initialDate;

    if (widget.diaryEntry != null) {
      _titleController.text = widget.diaryEntry!.title;
      _contentController.text = widget.diaryEntry!.content;
      _selectedMood = widget.diaryEntry!.mood;
      _entryDate = widget.diaryEntry!.entryDate;
      _imagePath = widget.diaryEntry!.imagePath;
      _imageCaptionController.text = widget.diaryEntry!.imageCaption ?? '';
    }

    // Handle direct image picking from FAB
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.imageSource == 'camera') {
        _pickImage(ImageSource.camera);
      } else if (widget.imageSource == 'gallery') {
        _pickImage(ImageSource.gallery);
      }
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  void _saveEntry() async {
    if (_formKey.currentState!.validate()) {
      if (AppConstants.currentUserId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User not logged in.')),
        );
        return;
      }

      final newEntry = DiaryEntry(
        id: widget.diaryEntry?.id,
        userId: AppConstants.currentUserId!,
        title: _titleController.text,
        content: _contentController.text,
        mood: _selectedMood ?? 'Neutral',
        entryDate: _entryDate!,
        imagePath: _imagePath,
        imageCaption: _imageCaptionController.text.trim().isEmpty
            ? null
            : _imageCaptionController.text.trim(),
      );

      if (widget.diaryEntry == null) {
        await _dbHelper.insertDiaryEntry(newEntry);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Diary entry added!')),
        );
      } else {
        await _dbHelper.updateDiaryEntry(newEntry);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Diary entry updated!')),
        );
      }
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _selectEntryDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _entryDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _entryDate) {
      setState(() {
        _entryDate = picked;
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else if (index == 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ReflectionScreen()),
      );
    } else if (index == 2) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => AddEditEntryScreen(
            initialDate: DateTime.now(),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _imageCaptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.diaryEntry == null ? 'New Diary Entry' : 'Edit Diary Entry'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: 'What\'s on your mind?',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your thoughts';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedMood,
                      hint: const Text('Select Mood'),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Mood',
                      ),
                      items: _moodOptions.map((String mood) {
                        return DropdownMenuItem<String>(
                          value: mood,
                          child: Text(mood),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedMood = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a mood';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectEntryDate(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          readOnly: true,
                          controller: TextEditingController(
                            text: _entryDate == null
                                ? ''
                                : DateFormat('MMM d, yyyy')
                                    .format(_entryDate!),
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Date',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _imagePath != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.file(
                          File(_imagePath!),
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _imageCaptionController,
                          decoration: const InputDecoration(
                            labelText: 'Image Caption (Optional)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            icon: const Icon(Icons.remove_circle),
                            label: const Text('Remove Image'),
                            onPressed: () {
                              setState(() {
                                _imagePath = null;
                                _imageCaptionController.clear();
                              });
                            },
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Add Photo from Camera'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.image),
                          label: const Text('Add Photo from Gallery'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                          ),
                        ),
                      ],
                    ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveEntry,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    widget.diaryEntry == null
                        ? 'Save Entry'
                        : 'Update Entry',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: _onItemTapped,
      ),
    );
  }
}

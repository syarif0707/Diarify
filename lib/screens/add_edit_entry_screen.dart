import 'dart:io';
import 'package:diarify/utils/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/diary_entry.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

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
  Color _selectedColor = Colors.white; // Default color for the entry card

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
      // Editing existing entry
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
  void _showColorPicker(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Select Card Color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _selectedColor,
            onColorChanged: (color) {
              setState(() {
                _selectedColor = color;
              });
            },
            showLabel: true,
            pickerAreaHeightPercent: 0.7,
            enableAlpha: false,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      );
    },
  );
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
        id: widget.diaryEntry?.id, // ID will be null for new entry, present for update
        userId: AppConstants.currentUserId!,
        title: _titleController.text,
        content: _contentController.text,
        mood: _selectedMood ?? 'Neutral', // Default mood if not selected
        entryDate: _entryDate!,
        imagePath: _imagePath,
        cardColor: _selectedColor.value,
        imageCaption: _imageCaptionController.text.trim().isEmpty ? null : _imageCaptionController.text.trim(),
      );

      if (widget.diaryEntry == null) {
        // Add new entry
        await _dbHelper.insertDiaryEntry(newEntry);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Diary entry added!')),
        );
      } else {
        // Update existing entry
        await _dbHelper.updateDiaryEntry(newEntry);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Diary entry updated!')),
        );
      }
      Navigator.of(context).pop(true); // Pop with true to indicate data change
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
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(widget.diaryEntry == null ? 'New Diary Entry' : 'Edit Diary Entry'),
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
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
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
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'What\'s on your mind?',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
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
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
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
                                : DateFormat('MMM d, yyyy').format(_entryDate!),
                          ),
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'Date',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Add this widget after the date picker row
const SizedBox(height: 16),
ListTile(
  title: Text('Card Color'),
  trailing: GestureDetector(
    onTap: () => _showColorPicker(context),
    child: Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: _selectedColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey),
      ),
    ),
  ),
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
                            backgroundColor: Color.fromARGB(255, 1, 56, 102),
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.image),
                          label: const Text('Add Photo from Gallery'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor: Color.fromARGB(255, 1, 56, 102),
                            foregroundColor: Colors.white,
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
                    backgroundColor: Color.fromARGB(255, 1, 56, 102),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    widget.diaryEntry == null ? 'Save Entry' : 'Update Entry',
                    style: const TextStyle(
                      fontSize: 20, 
                      color: Colors.white,
                      fontWeight: FontWeight.bold,),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
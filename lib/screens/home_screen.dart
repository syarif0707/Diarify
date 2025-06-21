import 'package:diarify/utils/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/diary_entry.dart';
import 'add_edit_entry_screen.dart';
import 'reflection_screen.dart';
import '../widgets/diary_card.dart'; // Custom widget for diary entry display

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<DiaryEntry> _diaryEntries = [];
  DateTime _selectedDate = DateTime.now();
  int _currentIndex = 0; // For Bottom Navigation Bar

  @override
  void initState() {
    super.initState();
    _loadDiaryEntries();
  }

  Future<void> _loadDiaryEntries() async {
    if (AppConstants.currentUserId == null) {
      // Handle case where user ID is not set (e.g., redirect to login)
      return;
    }
    List<DiaryEntry> entries = await _dbHelper.getDiaryEntriesByDate(
      AppConstants.currentUserId!,
      _selectedDate,
    );
    setState(() {
      _diaryEntries = entries;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadDiaryEntries(); // Reload entries for the new date
    }
  }

  void _onFabTapped(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Add New Entry'),
                onTap: () {
                  Navigator.pop(context); // Close bottom sheet
                  _navigateToAddEditEntry(context, null);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Add Photo from Camera'),
                onTap: () {
                  Navigator.pop(context); // Close bottom sheet
                  _navigateToAddEditEntry(context, null, imageSource: 'camera');
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Add Photo from Gallery'),
                onTap: () {
                  Navigator.pop(context); // Close bottom sheet
                  _navigateToAddEditEntry(context, null, imageSource: 'gallery');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToAddEditEntry(BuildContext context, DiaryEntry? entry, {String? imageSource}) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditEntryScreen(
          diaryEntry: entry,
          initialDate: _selectedDate,
          imageSource: imageSource,
        ),
      ),
    );
    if (result == true) {
      _loadDiaryEntries(); // Reload if entry was added/edited/deleted
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 0) {
      // Home tab - do nothing, already on home
      _loadDiaryEntries(); // Ensure entries are fresh if re-selecting Home
    } else if (index == 1) {
      // Reflection tab
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const ReflectionScreen()),
      ).then((_) {
        // After returning from ReflectionScreen, ensure Home is selected
        setState(() {
          _currentIndex = 0;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diarify'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh), // Add refresh button
            onPressed: _loadDiaryEntries,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Entries for: ${DateFormat('EEEE, MMM d, yyyy').format(_selectedDate)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: _diaryEntries.isEmpty
                ? const Center(child: Text('No diary entries for this date. Create one!'))
                : ListView.builder(
                    itemCount: _diaryEntries.length,
                    itemBuilder: (context, index) {
                      final entry = _diaryEntries[index];
                      return Dismissible(
                        key: Key(entry.id.toString()), // Unique key for Dismissible
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Confirm Delete"),
                                content: const Text("Are you sure you want to delete this entry?"),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: const Text("Delete"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        onDismissed: (direction) async {
                          if (entry.id != null) {
                            await _dbHelper.deleteDiaryEntry(entry.id!);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Entry "${entry.title}" deleted')),
                            );
                            _loadDiaryEntries(); // Refresh the list
                          }
                        },
                        child: DiaryCard(
                          entry: entry,
                          onTap: () => _navigateToAddEditEntry(context, entry),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onFabTapped(context),
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.home),
              color: _currentIndex == 0 ? Theme.of(context).primaryColor : Colors.grey,
              onPressed: () => _onItemTapped(0),
            ),
            // Spacer for FAB
            const SizedBox(width: 48),
            IconButton(
              icon: const Icon(Icons.bar_chart),
              color: _currentIndex == 1 ? Theme.of(context).primaryColor : Colors.grey,
              onPressed: () => _onItemTapped(1),
            ),
          ],
        ),
      ),
    );
  }
}
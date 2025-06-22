import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/diary_entry.dart';
import '../utils/app_constants.dart';
import 'add_edit_entry_screen.dart';
import 'reflection_screen.dart';
import '../widgets/diary_card.dart';
import 'setting_screen.dart'; // Import the SettingScreen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<DiaryEntry> _allDiaryEntries = []; // Stores all entries for the selected date
  List<DiaryEntry> _filteredDiaryEntries = []; // Stores entries filtered by search
  DateTime _selectedDate = DateTime.now();
  int _currentIndex = 0; // For Bottom Navigation Bar
  final TextEditingController _searchController = TextEditingController();
  bool _showSearchBar = false; // To toggle search bar visibility

  @override
  void initState() {
    super.initState();
    _loadDiaryEntries();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDiaryEntries() async {
    if (AppConstants.currentUserId == null) {
      // Handle case where user ID is not set (e.g., redirect to login)
      setState(() {
        _allDiaryEntries = [];
        _filteredDiaryEntries = [];
      });
      return;
    }
    List<DiaryEntry> entries = await _dbHelper.getDiaryEntriesByDate(
      AppConstants.currentUserId!,
      _selectedDate,
    );
    setState(() {
      _allDiaryEntries = entries;
      _onSearchChanged(); // Apply current search filter after loading new entries
    });
  }

  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredDiaryEntries = List.from(_allDiaryEntries);
      } else {
        _filteredDiaryEntries = _allDiaryEntries.where((entry) {
          return entry.title.toLowerCase().contains(query) ||
              entry.content.toLowerCase().contains(query);
        }).toList();
      }
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
        _searchController.clear(); // Clear search when date changes
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
        // Removed `leading` property and put all actions back into `actions` list
        title: const Text(
          'Diarify',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          // Refresh button (now on the right)
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDiaryEntries,
          ),
          // Settings button (now on the right)
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingScreen()),
              );
            },
          ),
          // Search Icon Button (to toggle search bar visibility below AppBar)
          IconButton(
            icon: Icon(_showSearchBar ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _showSearchBar = !_showSearchBar;
                if (!_showSearchBar) {
                  _searchController.clear(); // Clear search when closing
                }
              });
            },
          ),
          // Calendar button back in actions
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar below AppBar
          if (_showSearchBar) // Conditionally show the search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search entries...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor, // Use card color for background
                  contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                ),
                style: const TextStyle(fontSize: 16),
                onChanged: (value) => _onSearchChanged(), // Trigger search on change
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Entries for: ${DateFormat('EEEE, MMM d, yyyy').format(_selectedDate)}', // Corrected format to include year
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: _filteredDiaryEntries.isEmpty
                ? Center(
                    child: Text(
                      _searchController.text.isEmpty
                          ? 'No diary entries for this date. Create one!'
                          : 'No entries found matching "${_searchController.text}".',
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredDiaryEntries.length,
                    itemBuilder: (context, index) {
                      final entry = _filteredDiaryEntries[index];
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
      // FAB for Add New Entry remains centerDocked
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
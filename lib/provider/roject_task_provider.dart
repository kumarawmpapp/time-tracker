import 'package:flutter/foundation.dart';
import '../models/time_entry.dart';
import 'package:localstorage/localstorage.dart';
import 'dart:convert';

class TimeEntryProvider with ChangeNotifier {
  final LocalStorage storage;
  List<TimeEntry> _entries = [];

  List<TimeEntry> get entries => _entries;

  TimeEntryProvider(this.storage) {
    _loadentrysFromStorage();
  }

  void _loadentrysFromStorage() async {
    // await storage.ready;
    var storedentrys = storage.getItem('entrys');
    if (storedentrys != null) {
      _entries = List<TimeEntry>.from(
        (storedentrys as List).map((item) => TimeEntry.fromJson(item)),
      );
      notifyListeners();
    }
  }

  void addTimeEntry(TimeEntry entry) {
    _entries.add(entry);
    _saveentrysToStorage();
    notifyListeners();
  }

  void _saveentrysToStorage() {
    storage.setItem(
        'entrys', jsonEncode(_entries.map((e) => e.toJson()).toList()));
  }

  void addOrUpdateentry(TimeEntry entry) {
    int index = _entries.indexWhere((e) => e.id == entry.id);
    if (index != -1) {
      // Update existing entry
      _entries[index] = entry;
    } else {
      // Add new entry
      _entries.add(entry);
    }
    _saveentrysToStorage(); // Save the updated list to local storage
    notifyListeners();
  }

  // Delete an entry
  void deleteTimeEntry(String id) {
    _entries.removeWhere((entry) => entry.id == id);
    _saveentrysToStorage(); // Save the updated list to local storage
    notifyListeners();
  }
}

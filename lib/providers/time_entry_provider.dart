import 'package:flutter/foundation.dart';
import '../models/time_entry.dart';
import '../models/project.dart';
import '../models/task.dart';
import 'package:localstorage/localstorage.dart';
import 'dart:convert';

class TimeEntryProvider with ChangeNotifier {
  final LocalStorage storage;
  // List of time entries
  List<TimeEntry> _entries = [];

  // List of projects
  final List<Project> _projects = [
    Project(id: '1', name: 'Project 1', isDefault: true),
    Project(id: '2', name: 'Project 2', isDefault: true),
  ];

  // List of tasks
  final List<Task> _tasks = [
    Task(id: '1', name: 'Task 1'),
    Task(id: '2', name: 'Task 2'),
  ];

  // Getters
  List<TimeEntry> get entries => _entries;
  List<Project> get projects => _projects;
  List<Task> get tasks => _tasks;

  TimeEntryProvider(this.storage) {
    _loadTimeEntriesFromStorage();
  }

  void _loadTimeEntriesFromStorage() async {
    // await storage.ready;
    var storedEntries = storage.getItem('timeEntries');
    if (storedEntries != null) {
      var decodedEntries = jsonDecode(storedEntries) as List;
      _entries = List<TimeEntry>.from(
        decodedEntries.map((item) => TimeEntry.fromJson(item)),
      );
      notifyListeners();
    }
  }

  // Add an time entry
  void addTimeEntry(TimeEntry entry) {
    _entries.add(entry);
    _saveTimeEntriesToStorage();
    notifyListeners();
  }

  void _saveTimeEntriesToStorage() {
    storage.setItem(
        'timeEntries', jsonEncode(_entries.map((e) => e.toJson()).toList()));
  }

  void addOrUpdateTimeEntry(TimeEntry entry) {
    int index = _entries.indexWhere((e) => e.id == entry.id);
    if (index != -1) {
      // Update existing time
      _entries[index] = entry;
    } else {
      // Add new time
      _entries.add(entry);
    }
    _saveTimeEntriesToStorage(); // Save the updated list to local storage
    notifyListeners();
  }

  // Delete an time
  void deleteTimeEntry(String id) {
    _entries.removeWhere((entry) => entry.id == id);
    _saveTimeEntriesToStorage(); // Save the updated list to local storage
    notifyListeners();
  }

  // Add a project
  void addProject(Project project) {
    if (!_projects.any((proj) => proj.name == project.name)) {
      _projects.add(project);
      notifyListeners();
    }
  }

  // Delete a project
  void deleteProject(String id) {
    _projects.removeWhere((project) => project.id == id);
    notifyListeners();
  }

  // Add a task
  void addTask(Task task) {
    if (!_tasks.any((t) => t.name == task.name)) {
      _tasks.add(task);
      notifyListeners();
    }
  }

  // Delete a task
  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }

  void removeTimeEntry(String id) {
    _entries.removeWhere((entry) => entry.id == id);
    _saveTimeEntriesToStorage(); // Save the updated list to local storage
    notifyListeners();
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/time_entry.dart';
import '../providers/time_entry_provider.dart';
import '../screens/add_time_entry_screen.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../theme/theme.dart'; // Import the theme file

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Time Tracking"),
        backgroundColor: AppTheme.primaryColor, // Use theme color
        foregroundColor: AppTheme.appBarForegroundColor, // Use theme color
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accentColor,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.black38,
          tabs: [
            Tab(text: "All Entries"),
            Tab(text: "Grouped by Projects"),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: AppTheme.primaryColor),
              child: Center(
                child: Text(
                  'Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.folder, color: AppTheme.primaryColor),
              title: Text('Projects'),
              onTap: () {
                Navigator.pop(context); // This closes the drawer
                Navigator.pushNamed(context, '/manage_projects');
              },
            ),
            ListTile(
              leading: Icon(Icons.assignment, color: AppTheme.primaryColor),
              title: Text('Tasks'),
              onTap: () {
                Navigator.pop(context); // This closes the drawer
                Navigator.pushNamed(context, '/manage_tasks');
              },
            ),
          ],
        ),
      ),
      backgroundColor: AppTheme.backgroundColor, // Use theme color
      body: TabBarView(
        controller: _tabController,
        children: [
          buildTimeEntrysByDate(context),
          buildTimeEntrysByProject(context),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.accentColor, // Use theme color
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => AddTimeEntryScreen())),
        tooltip: 'Add Time Entry',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget buildTimeEntrysByDate(BuildContext context) {
    return Consumer<TimeEntryProvider>(
      builder: (context, provider, child) {
        if (provider.entries.isEmpty) {
          return EmptyEntriesView();
        }
        return ListView.builder(
          itemCount: provider.entries.length,
          itemBuilder: (context, index) {
            final timeEntry = provider.entries[index];
            String formattedDate =
                DateFormat('MMM dd, yyyy').format(timeEntry.date);
            String projectName =
                provider.getProjectNameById(timeEntry.projectId);
            String taskName = provider.getTaskNameById(timeEntry.taskId);
            return Dismissible(
              key: Key(timeEntry.id),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                provider.removeTimeEntry(timeEntry.id);
              },
              background: Container(
                color: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.centerRight,
                child: Icon(Icons.delete, color: Colors.white),
              ),
              child: Card(
                color: AppTheme.backgroundColor,
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                elevation: 5,
                child: ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$projectName - $taskName",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20), // Add space between title and subtitle
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total Time: ${timeEntry.totalTime} hours",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        "Date: $formattedDate",
                      ),
                      Text(
                        "Notes: ${timeEntry.notes}",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      provider.removeTimeEntry(timeEntry.id);
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget buildTimeEntrysByProject(BuildContext context) {
    return Consumer<TimeEntryProvider>(
      builder: (context, provider, child) {
        if (provider.entries.isEmpty) {
          return EmptyEntriesView();
        }

        // Grouping TimeEntrys by category
        var grouped = groupBy(provider.entries, (TimeEntry e) => e.projectId);
        return ListView(
          children: grouped.entries.map((entry) {
            String projectName = provider.getProjectNameById(entry.key); // Use provider method
            double total = entry.value.fold(0.0,
                (double prev, TimeEntry element) => prev + element.totalTime);
            return Card(
              elevation: 5, // Set the elevation to 5
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              color: AppTheme.backgroundColor, // Set the card color to AppTheme.backgroundColor
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(20), // Add padding of 20 pixels
                    child: Text(
                      "$projectName",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListView.builder(
                    physics:
                        NeverScrollableScrollPhysics(), // to disable scrolling within the inner list view
                    shrinkWrap:
                        true, // necessary to integrate a ListView within another ListView
                    itemCount: entry.value.length,
                    itemBuilder: (context, index) {
                      TimeEntry timeEntry = entry.value[index];
                      String taskName = provider.getTaskNameById(timeEntry.taskId);
                      String formattedDate = DateFormat('MMM dd, yyyy').format(timeEntry.date);
                      return Column(
                        children: [
                          ListTile(
                            title: Text(
                              " - $taskName: ${timeEntry.totalTime} hours ($formattedDate)",
                              style: TextStyle(fontWeight: FontWeight.w400),
                            ),
                          ),
                          SizedBox(height: 5), // Add space between items
                        ],
                      );
                    },
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class EmptyEntriesView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: Colors.transparent, // Set the background to transparent
        margin: EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                Color.fromRGBO(160, 160, 160, 1),
                BlendMode.srcIn,
              ),
              child: Image.asset(
                'assets/images/empty.png',
                width: 50,
                height: 50,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 20), // Add space between items
            Text('No time entries yet!',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color.fromRGBO(100, 100, 100, 1))),
            SizedBox(height: 20), // Add space between items
            Text(
              'Tap the + button to add your first entry.',
              style: TextStyle(color: Color.fromRGBO(160, 160, 160, 1)),
            ),
          ],
        ),
      ),
    );
  }
}

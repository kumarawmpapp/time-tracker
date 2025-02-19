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
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
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
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text('Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: Icon(Icons.category, color: Colors.deepPurple),
              title: Text('Projects'),
              onTap: () {
                Navigator.pop(context); // This closes the drawer
                Navigator.pushNamed(context, '/manage_projects');
              },
            ),
            ListTile(
              leading: Icon(Icons.tag, color: Colors.deepPurple),
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
                color: Colors.purple[50],
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                child: ListTile(
                  title: Text(
                      "${timeEntry.projectId} - ${timeEntry.totalTime} hours"),
                  subtitle: Text(
                      '${timeEntry.date.toString()} - Notes: ${timeEntry.notes}'),
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
            String projectName = getProjectNameById(
                context, entry.key); // Ensure you implement this function
            double total = entry.value.fold(
                0.0, (double prev, TimeEntry element) => prev + element.totalTime);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "$projectName - Total Time: \$${total.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
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
                    return ListTile(
                      leading:
                          Icon(Icons.monetization_on, color: Colors.deepPurple),
                      title: Text(
                          "${timeEntry.notes} - \$${timeEntry.totalTime}"),
                      subtitle: Text(DateFormat('MMM dd, yyyy')
                          .format(timeEntry.date)),
                    );
                  },
                ),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  // home_screen.dart
  String getProjectNameById(BuildContext context, String projectId) {
    var project = Provider.of<TimeEntryProvider>(context, listen: false)
        .projects
        .firstWhere((proj) => proj.id == projectId);
    return project.name;
  }
}

class EmptyEntriesView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        color: Colors.white, // Set the background to transparent
        elevation: 0,
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
            Text('No time entries yet!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color.fromRGBO(100, 100, 100, 1))),
            SizedBox(height: 20), // Add space between items
            Text('Tap the + button to add your first entry.', style: TextStyle(color: Color.fromRGBO(160, 160, 160, 1)),),
          ],
        ),
      ),
    );
  }
}
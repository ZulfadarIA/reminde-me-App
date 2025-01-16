import 'package:flutter/material.dart';
import 'package:remind_me_app/database/db_helper.dart';
import 'package:remind_me_app/pages/add_edit_task.dart';
import 'package:remind_me_app/pages/task_detail_page.dart';
import 'package:remind_me_app/services/notification_helper.dart';
import 'package:remind_me_app/services/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _reminders = [];

  @override
  void initState() {
    super.initState();
    requestNotificationPermissions();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    final reminders = await DbHelper.getReminders();
    setState(() {
      _reminders = reminders;
    });
  }

  Future<void> _toggleReminder(int id, bool isActive) async {
    await DbHelper.toggleReminder(id, isActive);
    if (isActive) {
      final reminder = _reminders.firstWhere((rem) => rem['id'] == id);
      NotificationHelper.scheduleNotification(id, reminder['title'],
          reminder['category'], DateTime.parse(reminder['reminderTime']));
    } else {
      NotificationHelper.cancelNotifications(id);
    }
    _loadReminders();
  }

  Future<void> _deleteReminders(int id) async {
    await DbHelper.deleteReminder(id);
    NotificationHelper.cancelNotifications(id);
    _loadReminders();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            "Remind-me App",
            style: TextStyle(color: const Color.fromARGB(255, 169, 116, 255)),
          ),
          iconTheme: IconThemeData(color: Colors.purple),
        ),
        body: _reminders.isEmpty
            ? Center(
                child: Text(
                  "No Tasks Found",
                  style: TextStyle(
                      fontSize: 18,
                      color: const Color.fromARGB(255, 169, 116, 255)),
                ),
              )
            : ListView.builder(
                itemCount: _reminders.length,
                itemBuilder: (context, index) {
                  final reminder = _reminders[index];
                  return Dismissible(
                    key: Key(reminder['id'].toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.redAccent,
                      padding: EdgeInsets.only(right: 20),
                      alignment: Alignment.centerRight,
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      return await _showDeleteConfirmationDialog(context);
                    },
                    onDismissed: (direction) {
                      _deleteReminders(reminder['id']);
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Task Deleted!")));
                    },
                    child: Card(
                      color: const Color.fromARGB(255, 169, 116, 255),
                      elevation: 6,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TaskDetailPage(
                                reminderId: reminder['id'],
                              ),
                            ),
                          );
                        },
                        leading: Icon(
                          Icons.task,
                          color: Colors.white54,
                        ),
                        title: Text(
                          reminder['title'],
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        subtitle: Text(
                          "Cartegory: ${reminder['category']}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.white),
                        ),
                        trailing: Switch(
                          value: reminder['isActive'] == 1,
                          activeColor: const Color.fromARGB(255, 136, 0, 160),
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: Colors.red,
                          onChanged: (value) {
                            _toggleReminder(reminder['id'], value);
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color.fromARGB(255, 169, 116, 255),
          foregroundColor: Colors.white,
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddAndEditTaskPage(),
              ),
            );
          },
        ),
      ),
    );
  }

  // Show confirmation dialog before deleting a task
  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text("Delete Task"),
            content: Text("Are you sure you want to delete this task?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // cancel delete
                },
                child: Text(
                  "Cancel",
                  style: TextStyle(color: Colors.blueAccent),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true); // confirm delete
                },
                child: Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
        });
  }
}

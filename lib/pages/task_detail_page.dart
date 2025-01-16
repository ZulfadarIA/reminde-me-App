import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:remind_me_app/database/db_helper.dart';
import 'package:remind_me_app/pages/add_edit_task.dart';

class TaskDetailPage extends StatefulWidget {
  final int reminderId;
  const TaskDetailPage({super.key, required this.reminderId});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: DbHelper.getRemindersById(widget.reminderId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: const Color.fromARGB(255, 186, 94, 202),
              ),
            ),
          );
        }
        final reminder = snapshot.data!;
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text(
              "Task Details",
              style: TextStyle(color: const Color.fromARGB(255, 169, 116, 255)),
            ),
            iconTheme: IconThemeData(color: Colors.purple),
            centerTitle: true,
          ),
          body: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailCard(
                  label: "Title",
                  icon: Icons.title,
                  content: reminder['title'],
                ),
                SizedBox(height: 20),
                _buildDetailCard(
                  label: "Descriprion",
                  icon: Icons.description,
                  content: reminder['description'],
                ),
                SizedBox(height: 20),
                _buildDetailCard(
                  label: "Category",
                  icon: Icons.category_sharp,
                  content: reminder['category'],
                ),
                SizedBox(height: 20),
                _buildDetailCard(
                  label: "Date",
                  icon: Icons.access_time,
                  content: DateFormat('yyyy-MM-dd hh:mm a').format(
                    DateTime.parse(
                      reminder['reminderTime'],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 40),
                          backgroundColor: Colors.purple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          textStyle: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          elevation: 5,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddAndEditTaskPage(
                                reminderId: reminder['id'],
                              ),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit,
                              color: Colors.white,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Edit",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        )),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailCard(
      {required String label,
      required IconData icon,
      required String content}) {
    return Card(
      elevation: 6,
      color: const Color.fromARGB(255, 169, 116, 255),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Colors.white54,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              content,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

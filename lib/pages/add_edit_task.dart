import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:remind_me_app/database/db_helper.dart';
import 'package:remind_me_app/pages/home_page.dart';
import 'package:remind_me_app/services/notification_helper.dart';

class AddAndEditTaskPage extends StatefulWidget {
  final int? reminderId;
  const AddAndEditTaskPage({super.key, this.reminderId});

  @override
  State<AddAndEditTaskPage> createState() => _AddAndEditTaskPageState();
}

class _AddAndEditTaskPageState extends State<AddAndEditTaskPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  String _category = "Work";
  DateTime _reminderTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.reminderId != null) {
      fetchReminder();
    }
  }

  Future<void> fetchReminder() async {
    try {
      final data = await DbHelper.getRemindersById(widget.reminderId!);
      if (data != null) {
        _titleController.text = data['title'];
        _descriptionController.text = data['description'];
        _category = data['category'];
        _reminderTime = DateTime.parse(data['reminderTime']);
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.blue),
        backgroundColor: Colors.white,
        title: Text(
          widget.reminderId == null ? "Add Reminder" : "Edit Reminder",
          style: TextStyle(
            color: Colors.blueAccent,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInputCard(
                  label: "Judul",
                  icon: Icons.title,
                  child: TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: "Masukkan Judul",
                      hintStyle: TextStyle(color: Colors.white),
                      border: InputBorder.none,
                    ),
                    validator: (value) {
                      value!.isEmpty ? "Tolong Masukkan Judul!" : null;
                    },
                  ),
                ),
                SizedBox(height: 20),
                _buildInputCard(
                  label: "Deskripsi",
                  icon: Icons.description,
                  child: TextFormField(
                    controller: _descriptionController,
                    maxLines: 5,
                    decoration: InputDecoration(
                        hintText: "Masukkan Deskripsi",
                        hintStyle: TextStyle(color: Colors.white),
                        border: InputBorder.none,
                        helperStyle: TextStyle(color: Colors.white)),
                    validator: (value) {
                      value!.isEmpty ? "Isi Deskripsi!" : null;
                    },
                  ),
                ),
                SizedBox(height: 20),
                _buildInputCard(
                  label: "Category",
                  icon: Icons.category_sharp,
                  child: DropdownButtonFormField(
                    value: _category,
                    dropdownColor: Colors.purple.shade300,
                    decoration: InputDecoration.collapsed(hintText: ''),
                    items: ['Work', 'Personal', "health", "Others"]
                        .map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(
                          category,
                          selectionColor: Colors.purple,
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _category = value!;
                      });
                    },
                  ),
                ),
                SizedBox(height: 20),
                _buildDataTimePicker(
                    label: "Tanggal",
                    icon: Icons.calendar_today_rounded,
                    displayValue:
                        DateFormat('yyyy-MM-dd').format(_reminderTime),
                    onPressed: _selectDate),
                _buildDataTimePicker(
                    label: "Jam",
                    icon: Icons.timer_outlined,
                    displayValue: DateFormat('hh:mm a').format(_reminderTime),
                    onPressed: _selectTime),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                        backgroundColor: Colors.purple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        textStyle: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        elevation: 5,
                      ),
                      onPressed: _saveReminder,
                      child: Text(
                        "Simpan",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 60),
                        backgroundColor: const Color.fromARGB(255, 255, 22, 22),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        textStyle: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        elevation: 5,
                      ),
                      onPressed: () {
                        Navigator.pop(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomePage(),
                          ),
                        );
                      },
                      child: Text(
                        "Batal",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard(
      {required String label, required IconData icon, required Widget child}) {
    return Card(
      elevation: 6,
      color: const Color.fromARGB(255, 169, 116, 255),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  label,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildDataTimePicker(
      {required String label,
      required IconData icon,
      required String displayValue,
      required Function() onPressed}) {
    return Card(
      elevation: 6,
      color: const Color.fromARGB(255, 169, 116, 255),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        trailing: TextButton(
            onPressed: onPressed,
            child: Text(
              displayValue,
              style: TextStyle(color: Colors.white),
            )),
      ),
    );
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
        initialDate: _reminderTime,
        context: context,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));
    if (picked != null) {
      setState(() {
        _reminderTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _reminderTime.hour,
          _reminderTime.minute,
        );
      });
    }
  }

  Future<void> _selectTime() async {
    TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime:
            TimeOfDay(hour: _reminderTime.hour, minute: _reminderTime.minute));
    if (picked != null) {
      setState(() {
        _reminderTime = DateTime(
          _reminderTime.year,
          _reminderTime.month,
          _reminderTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _saveReminder() async {
    if (_formKey.currentState!.validate()) {
      final newReminder = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'isActive': 1,
        'reminderTime': _reminderTime.toIso8601String(),
        'category': _category,
      };
      if (widget.reminderId == null) {
        final reminderId = await DbHelper.addReminders(newReminder);
        NotificationHelper.scheduleNotification(
            reminderId, _titleController.text, _category, _reminderTime);
      } else {
        await DbHelper.updateReminders(widget.reminderId!, newReminder);
        NotificationHelper.scheduleNotification(widget.reminderId!,
            _titleController.text, _category, _reminderTime);
      }
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ));
    }
  }
}

import 'package:long_planner/model.dart';
import 'package:long_planner/notification.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  List<Aktivite> activites = [];
  late Box box;
  DateTime selectedDate = DateTime(2025, 4, 28);

  @override
  void initState() {
    box = Hive.box<Aktivite>(
      "activiteBox1",
    ); // Şimdi kutu gerçekten açılmış olacak!
    for (var element in box.values) {
      activites.add(element);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar Planner'),
        actions: [
          IconButton(
            onPressed: () {
              return _ekleAktivite();
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: Stack(
        alignment: AlignmentDirectional.bottomEnd,
        children: [
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: activites.length,
                  itemBuilder: (context, index) {
                    activites.sort((a, b) => a.date.compareTo(b.date));

                    final aktivite = activites[index];
                    return Dismissible(
                      direction: DismissDirection.horizontal,
                      key: Key(aktivite.ID),
                      onDismissed: (a) async {
                        activites.removeAt(index);
                        await box.deleteAt(index);
                        await NotificationService.cancelNotification(
                          int.parse(aktivite.ID),
                        );

                        setState(() {});
                      },
                      child: ListTile(
                        title: Text(aktivite.title),
                        subtitle: Text(
                          DateFormat.yMd().add_Hm().format(aktivite.date),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(11),
            child: IconButton(
              iconSize: 50,
              onPressed: () async {
                activites.clear();
                await box.clear();
                await NotificationService.cancelAllNotifications();
                setState(() {});
              },
              icon: Icon(Icons.delete),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    // Tarih seçimi
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      // Saat seçimi
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        final DateTime fullDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          selectedDate = fullDateTime;
        });

        print("Seçilen Tarih ve Saat: $selectedDate");
      }
    }
  }

  _ekleAktivite() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            icon: Icon(Icons.add),
            content: SizedBox(
              height: 255,
              child: Column(
                children: [
                  TextFormField(
                    controller: _controller,

                    decoration: InputDecoration(hintText: 'Write an activate'),
                  ),

                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextButton(
                          onPressed: () {
                            _selectDate(context);
                          },
                          child: Text('Choose a Date'),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 0),
                  IconButton(
                    onPressed: () async {
                      await NotificationService.scheduleNotification(
                        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                        title: "Yeni Görev Zamanı!",
                        body: "- ${_controller.text}",
                        scheduledDate: selectedDate,
                      );
                      String ID =
                          (DateTime.now().millisecondsSinceEpoch ~/ 1000)
                              .toString();
                      box.add(
                        Aktivite(
                          title: _controller.text,
                          date: selectedDate,
                          ID: ID,
                        ),
                      );
                      activites.add(
                        Aktivite(
                          title: _controller.text,
                          date: selectedDate,
                          ID: ID,
                        ),
                      );
                      setState(() {});
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.save),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(),
                      TextButton.icon(
                        icon: Icon(Icons.backspace_outlined),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        label: Text('Back'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;

class ToDo_Screen extends StatefulWidget {
  @override
  _ToDo_ScreenState createState() => _ToDo_ScreenState();
}

class _ToDo_ScreenState extends State<ToDo_Screen> {
  final taskTextController = TextEditingController();
  String task;
  var li = new List();
  @override
  void initState() {
    super.initState();
    getList();
  }

  void getList() async {
    var doc_ref = await _firestore.collection('Tasks').orderBy('Time').get();
    doc_ref.docs.forEach((result) {
      li.add(result.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.lightBlueAccent,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(
                  top: 20.0,
                  left: 20.0,
                  right: 20.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "TO_DO List",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 50.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            child: TextField(
                              controller: taskTextController,
                              onChanged: (value) {
                                task = value;
                              },
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                filled: true,
                                hintText: 'Add your task here...',
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 20.0),
                              ),
                            ),
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black38,
                                  blurRadius: 25,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        FloatingActionButton(
                          backgroundColor: Colors.blueGrey.shade800,
                          onPressed: () {
                            taskTextController.clear();
                            _firestore.collection('Tasks').add({
                              'Task': task,
                              'Time': DateTime.now(),
                            });
                          },
                          child: Icon(
                            Icons.add,
                            color: Colors.lightBlueAccent,
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(22.0),
                      topRight: Radius.circular(22.0),
                    ),
                  ),
                  child: StreamBuilder(
                    stream: _firestore
                        .collection('Tasks')
                        .orderBy('Time')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.lightBlueAccent,
                          ),
                        );
                      }
                      final tasklist = snapshot.data.docs;
                      List<TaskTile> TaskWidgets = [];
                      int i = 0;
                      for (var work in tasklist) {
                        final TaskText = work.data()['Task'];
                        final ID = li[i];
                        i++;
                        final TaskWidget = TaskTile(
                          tasktext: TaskText,
                          id: ID,
                        );
                        TaskWidgets.add(TaskWidget);
                      }
                      return ListView(
                        children: TaskWidgets,
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class TaskTile extends StatefulWidget {
  TaskTile({this.tasktext, this.id});

  var id;

  final String tasktext;
  @override
  _TaskTileState createState() =>
      _TaskTileState(TextTask: tasktext, uni_id: id);
}

class _TaskTileState extends State<TaskTile> {
  _TaskTileState({this.TextTask, this.uni_id});

  final String TextTask;
  var uni_id;
  String msg;

  bool showvalue = false;
  final editController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.0),
      child: ListTile(
        title: Text(
          TextTask,
          style: TextStyle(fontSize: 25.0),
        ),
        leading: Checkbox(
          activeColor: Colors.lightBlueAccent,
          value: showvalue,
          onChanged: (bool value) {
            setState(() {
              this.showvalue = value;
            });
          },
        ),
        trailing: Wrap(
          children: <Widget>[
            IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  print("Edit");
                  showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => SingleChildScrollView(
                              child: Container(
                            child: Container(
                              color: Color(0xff757575),
                              child: Container(
                                padding: EdgeInsets.all(20.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20.0),
                                    topRight: Radius.circular(20.0),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    Text(
                                      'Edit Task',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 30.0,
                                        color: Colors.lightBlueAccent,
                                      ),
                                    ),
                                    TextField(
                                      controller: editController,
                                      textAlign: TextAlign.center,
                                      onChanged: (newText) {
                                        msg = newText;
                                      },
                                    ),
                                    FlatButton(
                                      child: Text(
                                        'Edit',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      color: Colors.lightBlueAccent,
                                      onPressed: () {
                                        editController.clear();
                                        var doc_ref = _firestore
                                            .collection('Tasks')
                                            .doc("$uni_id")
                                            .update({'Task': msg});
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )));
                }),
            IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  print("Delete");
                  print(uni_id);
                  var doc_ref =
                      _firestore.collection('Tasks').doc("$uni_id").delete();
                }),
          ],
        ),
      ),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'employee.dart';
import 'dart:async';
import 'DBHelper.dart';

class DBTestPage extends StatefulWidget {
  final String title;

  DBTestPage({Key key, this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _DBTestPageState();
  }
}

class _DBTestPageState extends State<DBTestPage> {
  //
  Future<List<Employee>> employees;
  TextEditingController controller = TextEditingController();
  String name;
  int curUserId;

  final formKey = new GlobalKey<FormState>();
  var dbHelper;
  bool isUpdating;

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
    isUpdating = false;
    refreshList();
  }

  refreshList() {
    setState(() {
      employees = dbHelper.getEmployees();
    });
  }

  clearName() {
    controller.text = '';
  }

  validate() {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      if (isUpdating) {
        Employee e = Employee(curUserId, name);
        dbHelper.update(e);
        setState(() {
          isUpdating = false;
        });
      } else {
        Employee e = Employee(null, name);
        dbHelper.save(e);
      }
      clearName();
      refreshList();
    }
  }

  form() {
    return Form(
      key: formKey,
      child: Padding(
        padding: EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          verticalDirection: VerticalDirection.down,
          children: <Widget>[
            TextFormField(
              controller: controller,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(labelText: 'Name'),
              validator: (val) => val.length == 0 ? 'Enter Name' : null,
              onSaved: (val) => name = val,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                RaisedButton(
                  focusColor: Colors.black,
                  splashColor: Colors.yellowAccent,
                  color: Colors.red,
                  onPressed: validate,
                  child: Text(isUpdating ? 'UPDATE' : 'ADD'),
                ),
                RaisedButton(
                  focusColor: Colors.black,
                  splashColor: Colors.yellowAccent,
                  color: Colors.red,
                  onPressed: () {
                    setState(() {
                      isUpdating = false;
                    });
                    clearName();
                  },
                  child: Text('CANCEL'),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  SingleChildScrollView dataTable(List<Employee> employees) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          DataTable(
            showCheckboxColumn: true,
            sortAscending: true,
            dividerThickness: 0.0,
            dataRowHeight: 70,
            headingRowHeight: 60,
            headingRowColor:
                MaterialStateColor.resolveWith((states) => Colors.orange),
            columns: [
              DataColumn(
                label: Text('NAME'),
              ),
              DataColumn(
                label: Text('EDIT'),
              ),
              DataColumn(
                label: Text('DELETE'),
              )
            ],
            rows: employees
                .map(
                  (employee) => DataRow(cells: [
                    DataCell(),
                    DataCell(
                      Text(employee.name),
                      onTap: () {
                        setState(() {
                          isUpdating = true;
                          curUserId = employee.id;
                        });
                        controller.text = employee.name;
                      },
                    ),
                    DataCell(IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        setState(() {
                          isUpdating = true;
                          curUserId = employee.id;
                        });
                        controller.text = employee.name;
                      },
                    )),
                    DataCell(IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        dbHelper.delete(employee.id);
                        refreshList();
                      },
                    )),
                  ]),
                )
                .toList(),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Container(
          //       decoration: BoxDecoration(
          //           color: Colors.redAccent,
          //           borderRadius: BorderRadius.all(Radius.circular(8))),
          //       height: 80,
          //       width: width,
          //       child: Text("yash")),
          // ),
        ],
      ),
    );
  }

  list() {
    return FutureBuilder(
      future: employees,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return dataTable(snapshot.data);
        }

        if (null == snapshot.data || snapshot.data.length == 0) {
          return Text("No Data Found");
        }

        return CircularProgressIndicator();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Flutter SQLITE DEMO'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: new Container(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            verticalDirection: VerticalDirection.down,
            children: <Widget>[
              form(),
              list(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  height: 80,
                  width: width,
                  child: Text("yash"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

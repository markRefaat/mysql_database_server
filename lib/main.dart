import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: MyHomePage(title: 'Mysql And Server'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var headerController = new TextEditingController();
  var bodyController = new TextEditingController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  Future AllData;
  @override
  void initState() {
    AllData = getAllData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
        centerTitle: true,
      ),
      body: new FutureBuilder<List>(
        future: AllData,
        builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
          if (snapshot.hasData) {
            return RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: () {setState(() {
                AllData = getAllData();
              });
              return AllData;
              },
              child: new ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  return new ListTile(
                    leading: new CircleAvatar(
                      child: new Text(snapshot.data[index]['id']),
                    ),
                    title: new Text(snapshot.data[index]['post_header']),
                    subtitle: new Text(snapshot.data[index]['post_body']),
                  );
                },
              ),
            );
          } else {
            return new Center(
              child: new CircularProgressIndicator(),
            );
            //return Center(child: new Text('Wait For Connection'));
          }
        },
      ),
      floatingActionButton: new FloatingActionButton(
        child: new Icon(Icons.add),
        onPressed: _showFormDialog,
      ),
    );
  }

  Future<List> getAllData() async {
    String url = 'https://tagalog-rolls.000webhostapp.com/get.php';
    http.Response response = await http.get(url);
    return jsonDecode(response.body);
  }

  void addData() {
    String url = 'https://tagalog-rolls.000webhostapp.com/post.php';
    http.post(url,
        body: {'header': headerController.text, 'body': bodyController.text});
    setState(() {
        AllData = getAllData();
    });
  }

  _showFormDialog() {
    var alert = new AlertDialog(
      content: new IntrinsicHeight(
        child: new Column(
          children: <Widget>[
            new TextField(
              decoration: new InputDecoration(
                labelText: "Header",
                hintText: "eg. Today's news",
                icon: new Icon(Icons.note_add),
              ),
              autofocus: true,
              controller: headerController,
            ),
            new TextField(
              decoration: new InputDecoration(
                labelText: "Body",
                hintText: "eg. Tomorrow is windy day",
                icon: new Icon(Icons.note_add),
              ),
              controller: bodyController,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        new FlatButton(
            onPressed: () {
              Navigator.pop(context);
              addData();
            },
            child: Text("Save")),
        new FlatButton(
            onPressed: () => Navigator.pop(context), child: Text("Cancel"))
      ],
    );
    showDialog(
        context: context,
        builder: (_) {
          return alert;
        });
  }

  Future<void> onRefresh() {
    setState(() {});
  }
}

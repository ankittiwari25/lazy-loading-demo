import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lazyloadingdemo/model.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lazy Loading',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: MyHomePage(title: 'Lazy Loading'),
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
  static int page = 0;
  ScrollController _sc = new ScrollController();
  bool isLoading = false;
  List<Results> allUsers = [];

  @override
  void initState() {
    this._getMoreData();
    super.initState();
    _sc.addListener(() {
      if (_sc.position.pixels == _sc.position.maxScrollExtent) {
        _getMoreData();
      }
    });
  }

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  void _getMoreData() async {
    var url = "https://randomuser.me/api/?page=" +
        page.toString() +
        "&results=20&seed=abc";
    print(url);
    http.Response response = await http.get(url);
    allUsers.addAll(Users.fromJson(json.decode(response.body)).results);
    setState(() {
      page++;
    });
  }

  Widget _buildList() {
    return ListView.builder(
      itemCount: allUsers.length + 1,
      // Add one more item for progress indicator
      padding: EdgeInsets.symmetric(vertical: 8.0),
      itemBuilder: (BuildContext context, int index) {
        if (index == allUsers.length) {
          return _buildProgressIndicator();
        } else {
          return new ListTile(
            leading: CircleAvatar(
              radius: 30.0,
              backgroundImage: NetworkImage(
                allUsers[index].picture.large,
              ),
            ),
            title: Text((allUsers[index].name.first)),
            subtitle: Text((allUsers[index].email)),
          );
        }
      },
      controller: _sc,
    );
  }

  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        child: _buildList(),
      ),
      resizeToAvoidBottomPadding: false,
    );
  }
}

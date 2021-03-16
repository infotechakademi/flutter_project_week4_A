import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project14/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    getUsers();
    super.initState();
  }

  Future<List<User>> getUsers() async {
    Uri url;
    try {
      url = Uri.parse('https://jsonplaceholder.typicode.com/users');

      http.Response response = await http.get(url);
      if (response.statusCode == 200) {
        List<User> _userList = [];
        print(response.statusCode);
        var userDataList = jsonDecode(response.body);
        for (var userData in userDataList) {
          User currentUser = User.fromJson(userData);
          _userList.add(currentUser);
        }
        return _userList;
      }
      return <User>[];
    } catch (error) {
      throw error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter"),
        leading: IconButton(
            icon: Icon(Icons.square_foot_sharp),
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              var dataToPrint = prefs.getStringList("userList");
              print(dataToPrint);
            }),
      ),
      body: FutureBuilder(
        future: getUsers(),
        builder: (context, AsyncSnapshot<List<User>> asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.none) {
            return SizedBox();
          } else if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: LinearProgressIndicator(),
            );
          } else if (asyncSnapshot.connectionState == ConnectionState.done) {
            if (asyncSnapshot.hasError)
              return Center(
                child: Text("Hata oluştu " + asyncSnapshot.error.toString()),
              );
            saveToLocale(asyncSnapshot.data);
            return userListWidget(asyncSnapshot.data);
          }
          return null;
        },
      ),
    );
  }

  void saveToLocale(List<User> userList) async {
    List<String> userListAsTextFormat = [];
    userList.forEach((User curUser) {
      userListAsTextFormat.add(curUser.toString());
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList("userList", userListAsTextFormat);
  }

  Widget userListWidget(List<User> userList) {
    return ListView.builder(
      itemCount: userList.length,
      itemBuilder: (context, index) {
        User _user = userList[index];
        return ListTile(
          title: Text(_user.name),
          subtitle: Text(_user.idText),
          leading: IconButton(
            icon: Icon(Icons.call),
            onPressed: () async {
              var telData = _user.phone;
              if (await canLaunch(telData)) {
                await launch(telData);
              } else {
                throw 'Could not launch';
              }
            },
          ),
          trailing: IconButton(
            icon: Icon(Icons.link),
            onPressed: () async {
              if (await canLaunch("http://" + _user.website)) {
                await launch("http://" + _user.website);
              } else {
                throw 'Could not launch';
              }
            },
          ),
        );
      },
    );
  }
}

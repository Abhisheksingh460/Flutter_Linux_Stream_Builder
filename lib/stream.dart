import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

main() {
  runApp(
    Mystream(),
  );
}

data(chatmsg) async {
  //var fsconnect = FirebaseFirestore.instance;
  var fs = FirebaseFirestore.instance;
  var authc = FirebaseAuth.instance;
  // ignore: unnecessary_brace_in_string_interps
  var url = "http://192.168.43.48/cgi-bin/linux.py?x=${chatmsg}";
  var response = await http.get(url);

  var state = response.body;
  // ignore: non_constant_identifier_names
  var SignInUser = authc.currentUser.email;
  await fs.collection('student').add({
    "User": SignInUser,
    '$chatmsg': state,
  });
}

class Mystream extends StatefulWidget {
  @override
  _MystreamState createState() => _MystreamState();
}

class _MystreamState extends State<Mystream> {
  var fs = FirebaseFirestore.instance;
  var authc = FirebaseAuth.instance;
  String chatmsg;
  var state;

  var msgcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // ignore: non_constant_identifier_names
    //var SignInUser = authc.currentUser.email;
    return Scaffold(
      appBar: AppBar(
        title: Text("streamterminal"),
        actions: [
          IconButton(
              icon: Icon(Icons.logout),
              onPressed: () async {
                await authc.signOut();
                Navigator.pushNamed(context, '/');
              })
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(children: [
              Container(
                //  width: MediaQuery.of(context).size.width * 0.8,
                child: TextField(
                  onChanged: (value) {
                    chatmsg = value;
                  },
                  style: TextStyle(color: Colors.black),
                  controller: msgcontroller,
                  decoration: InputDecoration(
                      hintText: '  Enter Your Command',
                      hintStyle: TextStyle(color: Colors.red),
                      fillColor: Colors.black,
                      prefixText: '[root@localhost ~]# ',
                      prefixStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black),
                      focusColor: Colors.blue,
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black45))),
                  autocorrect: true,
                  showCursor: true,
                ),
              ),
              SizedBox(
                width: 30,
              ),
              Material(
                borderRadius: BorderRadius.circular(10),
                child: MaterialButton(
                  onPressed: () async {
                    msgcontroller.clear();

                    var url =
                        "http://192.168.43.48/cgi-bin/linux.py?x=${chatmsg}";
                    var response = await http.get(url);
                    print(response);

                    //setState(() async {
                    state = response.body;
                    await fs.collection('student').add({
                      '$chatmsg': "$state",
                      //});
                      //"sender": SignInUser
                    });
                  },
                  child: Text("run"),
                  color: Colors.lightBlue.shade200,
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: fs.collection('student').snapshots(),
                builder: (context, snapshot) {
                  List<Widget> y = [];
                  try {
                    var msg = snapshot.data.docs;
                    print(msg);

                    for (var d in msg) {
                      var msgtext = d.data;
                      print(msgtext);
                      //  var msgSender = d.data['sender'];
                      var msgWidget = Text(
                        "  $msgtext",
                        style: TextStyle(color: Colors.white),
                      );
                      y.add(msgWidget);
                    }
                  } catch (e) {}

                  return Container(
                    height: MediaQuery.of(context).size.height * 0.66,
                    width: MediaQuery.of(context).size.width * 0.9,
                    margin: EdgeInsets.symmetric(vertical: 15, horizontal: 0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.black),
                    child: ListView.builder(
                      itemCount: 1,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          child: Column(
                            children: y,
                          ),
                        );
                      },
                    ),
                  );
                },
                //  stream: fs.collection("student").snapshots(),
              )
            ])),
      ),
    );
  }
}

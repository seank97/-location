import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import './home.dart';
import './login.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class User {
  String userEmail;
  String pid;

  DocumentReference reference;

  User(String userEmail, String pid) {
    this.userEmail = userEmail;
    this.pid = pid;
  }

  Map<String, dynamic> toJson() => _userToJson(this);

  @override
  String toString() => "User<$userEmail>";
}

User _userFromJson(Map<dynamic, dynamic> json) {
  return User(
    json['userEmail'] as String,
    json['pid'] as String,
  );
}

Map<String, dynamic> _userToJson(User user) => <String, dynamic>{
      'userEmail': user.userEmail,
      'pid': user.pid,
    };

class DataRepository {
  final CollectionReference collection = Firestore.instance.collection('users');

  Stream<QuerySnapshot> getStream() {
    return collection.snapshots();
  }

  // 3
  Future<DocumentReference> addUser(User user) {
    return collection.add(user.toJson());
  }

  // 4
  updateUser(User user) async {
    await collection
        .document(user.reference.documentID)
        .updateData(user.toJson());
  }
}

class FriendList extends StatefulWidget {
  FriendList({Key key, this.title}) : super(key: key);

  final String title;

  @override
  FriendListState createState() => FriendListState();
}

class FriendListState extends State<FriendList> {
  final DataRepository repository = DataRepository();
  final String userEmail = LoginState.userEmail;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friends List'),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: repository.getStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              print('idk');
              return LinearProgressIndicator();
            }
            return ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemBuilder: (context, index) =>
                  buildItem(context, snapshot.data.documents[index]),
              itemCount: snapshot.data.documents.length,
            );
          }),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Profile'
                  //getUserName()
//                  Firestore.instance.document(userEmail).get().then((value) {
//                    print(value.data['name']);
//                  });
                  ),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
              ),
            ),
            ListTile(
              title: Text('Home'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Home(),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Friends'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Logout'),
              onTap: () async {
                await _auth.signOut();
                print('Logout successful');

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Login(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String getUserName() {
    //Firestore.instance.collection('users').document().
    var ret;
    Firestore.instance
        .collection('users')
        .document(userEmail)
        .get()
        .then((value) {
      print(value.data['name']);
      ret = value.data['name'];
    });
    return ret;
  }

  Widget buildItem(BuildContext context, DocumentSnapshot document) {
    if (document['email'] == userEmail) {
      return Container();
    }
    return Container(
      child: FlatButton(
        onPressed: () {
          Navigator.pop(context, false);
        },
        child: Row(
          children: <Widget>[
            Material(
              borderRadius: BorderRadius.all(Radius.circular(25.0)),
              clipBehavior: Clip.hardEdge,
            ),
            Flexible(
              child: Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Text(
                        '${document['name']}',
                        style: TextStyle(color: Colors.black),
                      ),
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    ),
                  ],
                ),
                margin: EdgeInsets.only(left: 20.0),
              ),
            ),
          ],
        ),
        color: Colors.grey,
        padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
      margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
    );
  }
//  }
}

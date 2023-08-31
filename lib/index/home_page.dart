// ignore_for_file: prefer_const_constructors, prefer_interpolation_to_compose_strings, prefer_const_literals_to_create_immutables
import 'dart:convert';
// import 'dart:js_util';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:my_flix_app/model/titles.dart';
import 'package:my_flix_app/api_key.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? user = FirebaseAuth.instance.currentUser;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final _titleSearchController = TextEditingController();

  final List<Titles> titles = [];

  Future<Map<String, dynamic>> fetchData() async {
    if (_titleSearchController.text.trim().isNotEmpty) {
      final response = await http.get(
        Uri.https(
          'unogs-unogs-v1.p.rapidapi.com',
          '/search/titles',
          {
            // 'type': 'movie',
            'title': _titleSearchController.text.trim(),
            'order_by': 'date',
            'rapidapi-key': apiKey
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed.');
      }
    } else {
      throw Exception('Failed');
    }
  }

  int currentPageIndex = 0;
  bool isDarkModeEnabled = true;

  Future<dynamic> getUserData() async {
    String uid = user?.uid ?? "";
    DocumentReference docRef =
        FirebaseFirestore.instance.collection('users').doc(uid);
    DocumentSnapshot docSnapshot = await docRef.get();
    if (docSnapshot.exists) {
      List<String> userData = [];
      userData.add(docSnapshot.get('username'));
      userData.add(docSnapshot.get('fav'));
      userData.add(docSnapshot.get('title'));
      userData.add(docSnapshot.get('rating'));
      return userData;
    } else {
      return null;
    }
  }

  Future makeFavourite(
      String imgSrc, int netflixId, String rating, String title) async {
    String uid = user?.uid ?? "";
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'fav': imgSrc,
      'rating': rating,
      'id': netflixId,
      'title': title,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          brightness: Brightness.dark,
        ),
        child: NavigationBar(
          backgroundColor: Theme.of(context).primaryColor,
          selectedIndex: currentPageIndex,
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          // ignore: prefer_const_literals_to_create_immutables
          destinations: const <Widget>[
            NavigationDestination(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
            NavigationDestination(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
      body: <Widget>[
        Container(
          color: Theme.of(context).primaryColor,
          alignment: Alignment.center,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    color: Colors.orange.shade100,
                    child: FutureBuilder<dynamic>(
                      future: getUserData(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }
                        if (snapshot.hasData) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Greetings, ',
                                        style: TextStyle(
                                          fontSize: 18.0,
                                        ),
                                      ),
                                      Text(
                                        '${snapshot.data[0]}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24.0,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Card(
                                        color: Colors.amber.shade50,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            ListTile(
                                              title: Text(
                                                'FAVORITE',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              tileColor: Colors.amber.shade400,
                                            ),
                                            // Divider(),
                                            ListTile(
                                              title: Text(
                                                '${snapshot.data[2]}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                              subtitle: Text('title'),
                                            ),
                                            ListTile(
                                              title: Text(
                                                '${snapshot.data[3]}' + '/10',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                              subtitle: Text('rating'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 45, right: 17),
                                child: Image.network('${snapshot.data[1]}'),
                              ),
                            ],
                          );
                        } else {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Greetings!',
                                        style: TextStyle(
                                          fontSize: 18.0,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Container(
                                        alignment: Alignment.bottomLeft,
                                        child: Row(
                                          children: [
                                            Text(
                                              'Favourite Title',
                                              style: TextStyle(
                                                fontSize: 16.0,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 25),
                                              child: Icon(
                                                Icons.arrow_right_alt_rounded,
                                                color: Color.fromARGB(
                                                    255, 10, 10, 10),
                                                size: 30,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: Text('ADD A FAVOURITE TITLE'),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          color: Theme.of(context).primaryColor,
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                // ignore: prefer_const_literals_to_create_immutables
                children: [
                  Text(
                    "Is it on Netflix?",
                    style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 28.0,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12.0),
                  TextField(
                    controller: _titleSearchController,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.redAccent),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.redAccent),
                        ),
                        hintText: 'e.g. The Dark Knight',
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.redAccent,
                        )),
                  ),
                  SizedBox(height: 12.0),
                  FutureBuilder(
                    future: fetchData(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      if (snapshot.hasData) {
                        final titleData = snapshot.data;
                        final title = titleData!['results'][0]['title'];
                        final synopsis = titleData['results'][0]['synopsis'];
                        final imgSrc = titleData['results'][0]['img'];
                        final netflixId = titleData['results'][0]['netflix_id'];
                        final rating = titleData['results'][0]['rating'];
                        if (_titleSearchController.text.trim().toLowerCase() ==
                            '$title'.toLowerCase()) {
                          return Card(
                            color: Color.fromARGB(255, 121, 186, 246),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ListTile(
                                        title: Text(
                                          '$title',
                                          style: TextStyle(
                                            fontWeight: FontWeight
                                                .bold, // Set the font weight to bold
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 15.0, bottom: 15),
                                        child: Text('$synopsis'),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 35, top: 15),
                                        child: Padding(
                                          padding: const EdgeInsets.all(1),
                                          child: OutlinedButton.icon(
                                            onPressed: () {
                                              makeFavourite(imgSrc, netflixId,
                                                  rating, title);
                                              final snackbar = SnackBar(
                                                content: Text(
                                                    'Updated favourite...'),
                                                duration: Duration(seconds: 1),
                                              );

                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(snackbar);
                                            },
                                            icon: Icon(
                                              Icons.star,
                                              color: Colors.amber.shade300,
                                            ),
                                            label: Text(
                                              'Favourite'.toUpperCase(),
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(14.0),
                                  child: Image.network('$imgSrc'),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Card(
                            color: Color.fromARGB(255, 243, 116, 129),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Text('The title ' +
                                            '"' +
                                            _titleSearchController.text.trim() +
                                            '"' +
                                            ' is not available on Netflix.'),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(15),
                                        child: Text(
                                            'Sorry for the inconvenience.'),
                                      ),
                                      Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(15),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                            decoration: BoxDecoration(
                                                color: Color.fromARGB(
                                                    255, 255, 238, 0),
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            child: Padding(
                                              padding: const EdgeInsets.all(1),
                                              child: Text(
                                                'NOT ON NETFLIX',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      } else {
                        return Column();
                      }
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        fetchData();
                      });
                      final snackBar = SnackBar(
                        content: Text('Results for search input...'),
                        duration: Duration(seconds: 1),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    },
                    child: Text('Find out!'.toUpperCase()),
                  )
                ],
              ),
            ),
          ),
        ),
        Container(
          color: Theme.of(context).primaryColor,
          alignment: Alignment.center,
          child: MaterialButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              googleSignIn.signOut();
            },
            color: Colors.blue[400],
            child: Text('Logout'),
          ),
        )
      ][currentPageIndex],
    );
  }
}

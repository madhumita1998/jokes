import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<String> jokes = [];

  @override
  void initState() {
    super.initState();
    // Load jokes from local storage when the app starts
    _loadJokes();
    // Fetch new jokes every minute
    Timer.periodic(const Duration(minutes: 1), (Timer t) {
      _fetchJokes();
    });
  }

  Future<void> _fetchJokes() async {
    final response = await http.get(Uri.parse('https://geek-jokes.sameerkumar.website/api?format=json'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> jokeData = json.decode(response.body);
      final String newJoke = jokeData['joke'];
      setState(() {
        jokes.add(newJoke);
        if (jokes.length > 10) {
          jokes.removeAt(0); // Remove the oldest joke if the list exceeds 10 jokes
        }
      });
      _saveJokes();
    } else {
      throw Exception('Failed to load joke');
    }
  }

  Future<void> _loadJokes() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedJokes = prefs.getStringList('jokes') ?? [];
    setState(() {
      jokes = savedJokes;
    });
  }

  Future<void> _saveJokes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('jokes', jokes);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Column(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(top: 20, bottom: 20),
              child: Text('Joke App', style: TextStyle(fontSize: 30, color: Color(0xFF98CF33), fontWeight: FontWeight.bold),),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: jokes.length,
                reverse: true,
                itemBuilder: (context, index) {
                  return
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                      // height: 50,
                      // width: 250,
                        padding: const EdgeInsets.only(top: 15, bottom: 15, left: 10, right: 10),
                      decoration:  BoxDecoration(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10.0),),
                        // boxShadow: const [
                        //   BoxShadow(
                        //     color: Color(0xffc7c7c7),
                        //     spreadRadius: 1,
                        //     blurRadius: 5,
                        //     offset: Offset(0,3),
                        //   ),
                        // ],
                        color: const Color(0xFFCAE592).withOpacity(0.4),
                      ),
                      child:  Text(jokes[index], style: TextStyle(color: Colors.black),),
                  ),
                    );

                  //   Container(
                  //     height: 50,
                  //       width: 100,
                  //       decoration: const BoxDecoration(
                  //         borderRadius: BorderRadius.all(
                  //           Radius.circular(10.0),),
                  //         boxShadow: [
                  //           BoxShadow(
                  //             color: Color(0xffc7c7c7),
                  //             spreadRadius: 1,
                  //             blurRadius: 5,
                  //             offset: Offset(0,5),
                  //           ),
                  //         ],
                  //         color: Color(0xFFCAE592),
                  //         // gradient: LinearGradient(
                  //         //   begin: Alignment.centerLeft,
                  //         //   end: Alignment.centerRight,
                  //         //   colors: <Color>[
                  //         //     Color(0xFFCAE592),
                  //         //     Color(0xFF98CF33),
                  //         //   ],
                  //         // ),
                  //       ),
                  //   child: Text('• ${jokes[index]}'),
                  // );
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                child: InkWell(
                  onTap: _fetchJokes,
                  child: Container(
                    height: 50,
                    width: 250,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xffc7c7c7),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: Offset(0,5),
                        ),
                      ],
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: <Color>[
                          Color(0xFFCAE592),
                          Color(0xFF98CF33),
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Fetch Jokes',
                        style: TextStyle(
                          color:  Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
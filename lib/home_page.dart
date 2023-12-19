import 'dart:html';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  TextEditingController reportIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 400,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Invalid report ID, please try again!",
                  style: TextStyle(
                      fontSize: 40,
                    fontWeight: FontWeight.bold
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20,),
                TextField(
                  controller: reportIdController,
                  decoration: InputDecoration(
                    hintText: 'Or try searching for one manually.',
                    suffixIcon: GestureDetector(
                      onTap: (){
                        launchUrl(Uri.parse('/${reportIdController.text}'));
                      },
                      child: const Icon(
                        Icons.search
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      )
    );
  }
}
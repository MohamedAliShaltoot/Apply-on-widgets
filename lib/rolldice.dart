import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class RollGame extends StatefulWidget {
  RollGame({super.key});

  @override
  State<RollGame> createState() => _RollGameState();
}

class _RollGameState extends State<RollGame> {
  int number1 = 1;
  int number2 = 2;
  int result = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 15, 2, 91),
        title: const Text(
          "Roll Game",
          style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic),
        ),
        centerTitle: true,
      ),
      body: ListView(children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(
                height: 200,
              ),
              Text(" Sum = $result"),
              const SizedBox(
                height: 100,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: SizedBox(
                      //color: Colors.amber,
                      width: 400,
                      height: 90,
                      child:  Image.asset("images/p$number1.jpg"),
                      
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                Expanded(
                    child: SizedBox(
                      //color: Colors.amber,
                      width: 400,
                      height: 90,
                      child:  Image.asset("images/p$number2.jpg"),
                      
                    ),
                  ),
                ],
              ),
              //  Image.asset("images/p$number2.JPG"),
              // const CircleAvatar(
              //           radius: 20,
              //           backgroundImage: AssetImage("images/me.jpg"),
              //         ),

              const SizedBox(
                height: 100,
              ),
             number1==number2? const Text("You Win ",
          style: TextStyle(color: Color.fromARGB(255, 207, 21, 21), fontStyle: FontStyle.italic)):const Text(""),
          const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                  onPressed: () {
                    setRollDice();
                  },
                  child: const Text(
                    "Roll",
                    style: TextStyle(
                        color: Color.fromARGB(255, 33, 1, 1),
                        fontStyle: FontStyle.italic),
                  )),
            ],
          ),
        ),
      ]),
    );
  }

  void setRollDice() {
    setState(() {
      number1 = Random().nextInt(6) + 1;
      number2 = Random().nextInt(6) + 1;
      result = number1 + number2;
    });
  }
}

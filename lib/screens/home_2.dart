import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isOnLine = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              // Container(
              //   color: const Color.fromARGB(255, 215, 209, 189),
              //   width: 400,
              //   height: 400,
              // ),
              Container(
                decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 26, 44, 59),
                    shape: BoxShape.circle),
                width: 250,
                height: 200,
              ),
              isOnLine
                  ? Positioned(
                      top: 160,
                      left: 180,
                      child: Container(
                        decoration: BoxDecoration(
                          color: !isOnLine ? Colors.red : Colors.green,
                          //shape: BoxShape.circle,
                          borderRadius: BorderRadius.circular(100),
                          //  border: Border.all(color: Colors.black, width: 5)
                        ),
                        width: 20,
                        height: 20,
                      ),
                    )
                  : const SizedBox(),
              // Container(
              //   color: Colors.green,
              //   width: 100,
              //   height: 100,
              // ),
            ],
          ),
          // const SizedBox(
          //   height: 50,
          // ),
          IconButton(
              onPressed: () {
                if (isOnLine) {
                  isOnLine = false;
                  setState(() {});
                } else {
                  isOnLine = true;
                  setState(() {});
                }
              },
              icon: const Icon(Icons.switch_account))
        ],
      ),
    );
  }
}

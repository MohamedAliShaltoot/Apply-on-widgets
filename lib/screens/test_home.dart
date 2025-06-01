import 'package:flutter/material.dart';

class TestHome extends StatefulWidget {
  const TestHome({super.key});

  @override
  State<TestHome> createState() => _TestHomeState();
}

class _TestHomeState extends State<TestHome> {
  double minimum = 90;
  double maximum = 20;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        drawer: const Drawer(
          child: Text("Drawer"),
        ),
        appBar: AppBar(
          title: const Text("Test Home"),
          centerTitle: true,
          leading: const Icon(Icons.menu),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.group),
                text: "group",
              ),
              Tab(
                icon: Icon(Icons.phone),
                text: "phone",
              ),
              Tab(
                icon: Icon(Icons.home),
                text: "home",
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Container(
              color: const Color.fromARGB(255, 35, 31, 18),
              width: double.infinity,
              height: 40,
            ),
            Container(
              color: const Color.fromARGB(255, 4, 207, 96),
            ),
            Column(
              children: [
                CircleAvatar(
                  radius: minimum,
                  backgroundImage: const AssetImage("images/me.jpg"),
                  // maxRadius: maximum,
                  // minRadius: minimum,
                ),
                const SizedBox(
                  height: 60,
                ),
                Slider(
                  value: minimum,
                  secondaryTrackValue: 10,
                  label: minimum.toString(),
                  divisions: 20, // every step is 10
                  activeColor: Colors.blue,
                  inactiveColor: Colors.black12,
                  mouseCursor: MouseCursor.uncontrolled,
                  thumbColor: Colors.black, // color of the circle
                  autofocus:
                      true, // already show the slider current value on start
                  allowedInteraction: SliderInteraction
                      .slideThumb, // how to interact tab or drag the thumb
                  overlayColor: WidgetStateProperty.all(
                    Colors.red,
                  ),

                  min: 0,
                  max: 200,
                  onChanged: (value) {
                    setState(() {
                      minimum = value;
                    });
                  },
                ),
                Text("$minimum"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

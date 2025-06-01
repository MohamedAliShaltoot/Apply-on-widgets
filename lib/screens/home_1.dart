import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double opacity = 5; // current value
  double minimum = 0;
  double maximum = 10;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              width: 200,
              height: 200,
              alignment: AlignmentDirectional.center,
              decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [
                    Color.fromARGB(255, 193, 181, 181),
                    Colors.purple,
                    Colors.pink,
                    Colors.yellow
                  ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                  border: Border.all(color: Colors.black, width: 5),
                  image: DecorationImage(
                      opacity: opacity / 10,
                      image: const NetworkImage(
                          "https://t4.ftcdn.net/jpg/02/29/75/83/360_F_229758328_7x8jwCwjtBMmC6rgFzLFhZoEpLobB6L8.jpg"),
                      fit: BoxFit.cover)),
              child: Container(
                width: 100,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Container(
                    margin: const EdgeInsets.all(40),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    )),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Slider(
              value: opacity,
              // secondaryTrackValue: 10,
              label: minimum.toString(),
              divisions: 10, // every step is 10
              activeColor: Colors.blue,
              inactiveColor: Colors.black12,
              mouseCursor: MouseCursor.uncontrolled,
              thumbColor: Colors.black, // color of the circle
              //  autofocus: true, // already show the slider current value on start
              allowedInteraction: SliderInteraction
                  .tapAndSlide, // how to interact tab or drag the thumb
              overlayColor: WidgetStateProperty.all(
                Colors.red,
              ),

              min: minimum,
              max: maximum,
              onChanged: (value) {
                setState(() {
                  opacity = value;
                });
              },
            ),
            Text("${minimum / 10}"),
          ],
        ),
      ),
    );
  }
}

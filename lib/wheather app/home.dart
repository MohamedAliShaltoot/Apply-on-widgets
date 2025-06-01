import 'package:flutter/material.dart';
import 'package:flutter_application_2/wheather%20app/api.dart';
import 'package:flutter_application_2/wheather%20app/model.dart';
import 'package:chat_bubbles/chat_bubbles.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Weather>> futureWeather;

  @override
  void initState() {
    super.initState();
    futureWeather = WeatherService().fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Weather Data")),
      body: FutureBuilder<List<Weather>>(
        future: futureWeather,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No weather data found.'));
          } else {
            List<Weather> weatherList = snapshot.data!;
            return ListView.builder(
              itemCount: weatherList.length,
              itemBuilder: (context, index) {
                Weather weather = weatherList[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: BubbleSpecialOne(
                    text:
                        "${weather.name}\n📍 ${weather.address}, ${weather.city}, ${weather.country}\n🏠 Street: ${weather.street}\n📮 Postal Code: ${weather.postalCode}",
                    isSender: false,
                    color: Colors.blue.shade100,
                    tail: true,
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

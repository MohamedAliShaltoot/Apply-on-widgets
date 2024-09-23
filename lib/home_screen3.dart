import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyhomePage3 extends StatefulWidget {
  const MyhomePage3({super.key});

  @override
  State<MyhomePage3> createState() => _MyhomePage3State();
}

class _MyhomePage3State extends State<MyhomePage3> {
  bool isChecked = false;

@override
  void initState() {
    super.initState();
    print('gghgh');
    SharedPreferences.getInstance().then((prefs) {
      isChecked=prefs.getBool('Checked') ?? false ;
    });
  }

  // String selectedValue = '';
  // List<String> courseNames =['Fluter',"Android","Ios","React Nativ","Xamrin"];
  // String finalValue='';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Visibility(
              visible: isChecked,
              maintainAnimation: true,
              maintainState: true,
              maintainSize: true,
              child: Image.asset(
                'images/انا.jpg',
                width: MediaQuery.of(context).size.width,
                height: 110,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            CheckboxListTile(
                title: const Text(
                  "Show/Hide",
                  style: TextStyle(fontSize: 20, color: Colors.black),
                ),
                value: isChecked,
                onChanged: (value) {
                  setState(() {
                    isChecked = value!;
                  });
                }),
                
       
ElevatedButton(onPressed:() async{
 

SharedPreferences prefs = await SharedPreferences.getInstance();
prefs.setBool('Checked', isChecked);
}, child: const Text("save changes")),

      ]),
    ),
    );
  }
}
/*

RadioListTile<String>(
              value: 'flutter',
              groupValue: selectedValue,
              onChanged: (value) {
                setState(() {
                  selectedValue = value!;
                });
              },
              title: const Text('flutter'),
            ),
            RadioListTile<String>(
              value: 'android',
              groupValue: selectedValue,
              onChanged: (value) {
                setState(() {
                  selectedValue = value!;
                });
              },
              title: const Text('android'),
            ),
*/

/*
           MediaQuery.of(context).size.width
                }),
            const Divider(),
            Column(
              children: 
                courseNames.map((e) => RadioListTile<String>(title: Text(e),value: e, groupValue: selectedValue, onChanged: (value){
                  setState(() {
                  selectedValue = value!;
                });
                })).toList()),
                ElevatedButton(onPressed: (){
                  setState(() {
                    selectedValue=finalValue;
                  });
                  
                }, child: const Text("Get selected Item")),
                Text(selectedValue),
            
          ],
        ),
*/
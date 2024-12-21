import 'package:flutter/material.dart';
import 'package:flutter_application_2/widgets/text_field.dart';

class TextFormFieldWidget extends StatelessWidget {
  const TextFormFieldWidget({super.key});

  @override
  Widget build(BuildContext context) {
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    String? username;
    return Scaffold(
      appBar: AppBar(
        title: const Text("TextFormField Widget"),
      ),
      body: Form(
        key: formKey,
        child: Column(
          children: [
             TextFormField(
              autovalidateMode: AutovalidateMode.onUnfocus,
              onSaved: (newValue) {
                username=newValue;
              },
              decoration: const InputDecoration(hintText: "Enter Your Name",labelText: "Enter Your Name",border: OutlineInputBorder()),
             validator: (value){
               if(value!.isEmpty){
                 return "Please Enter Name";
                 
               } else if(value.length<=6){
return "you must enter 7 characters at least ";
               }
               return null;
             },
            ),
            ElevatedButton(onPressed: () {
              if(formKey.currentState!.validate()){
                formKey.currentState!.save(); // to save the value in username string 
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Form is Valid")));
                Navigator.push(context, MaterialPageRoute(builder: (context) => const TextFieldWidget(),));
              }
            }, child: const Text("Submit"),),
          ],
        ),
      ),
    );
  }
}
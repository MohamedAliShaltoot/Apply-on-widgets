import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_2/user.dart';
import 'package:flutter_application_2/utils/context_extension.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class HomeScreen33 extends StatelessWidget {
   HomeScreen33({super.key});

List<User> users=[
User('mo@gmail.com', 'mohamed', '0123456788', 'software testing','https://www.google.com/imgres?q=person%20image%20icon%20jpg&imgurl=https%3A%2F%2Fcdn-icons-png.flaticon.com%2F512%2F4202%2F4202841.png'),
User('noha@gmail.com', 'noha', '0123720988', 'Graphic designer','https://thumb.ac-illust.com/be/bee98c70d1cfc02d0f387d2852464bf5_t.jpeg'),
User('magdi@gmail.com', 'magdi', '08432222788', 'drawer','https://www.iconpacks.net/icons/1/free-user-icon-295-thumb.png'),
User('hema@gmail.com', 'hema', '32345455588', 'backer','https://www.google.com/imgres?q=person%20image%20icon%20jpg&imgurl=https%3A%2F%2Fst2.depositphotos.com%2F3369547%2F11481%2Fv%2F950%2Fdepositphotos_114817672-stock-illustration-avatar-man-icon-businesspeople-design.jpg'),
User('mahy@gmail.com', 'mahy', '012445456788', 'engineer','https://static.vecteezy.com/system/resources/previews/014/194/198/non_2x/avatar-icon-human-a-person-s-badge-social-media-profile-symbol-the-symbol-of-a-person-vector.jpg'),
User('nader@gmail.com', 'nader', '01978756788', 'content creator','https://visualpharm.com/assets/387/Person-595b40b75ba036ed117da139.svg'),
User('wael@gmail.com', 'wael', '06765456788', 'project manager','https://png.pngtree.com/png-vector/20190411/ourmid/pngtree-vector-business-man-icon-png-image_924785.jpg'),
User('ahmed@gmail.com', 'ahmed', '67655456788', 'sw engineer'),

];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: ListView.builder(
        itemCount: users.length,
        itemBuilder:(context,index)=>
        ListTile(
          onTap: (){
          context.showSnackBar(users[index].name,actionLabet: 'view profile',onCtick: (){
            _viewUserDetails(context,users[index]);
          });
          },
          leading: CircleAvatar(radius: 35, backgroundImage:NetworkImage(users[index].pic ?? 'https://t4.ftcdn.net/jpg/02/29/75/83/360_F_229758328_7x8jwCwjtBMmC6rgFzLFhZoEpLobB6L8.jpg') ,),
          title: Text(users[index].name),
          subtitle: Text(users[index].position),
          trailing: SizedBox(width: 100,child: Row(children: [
            IconButton(onPressed: ()=> _callUser(users[index].phone), icon: const Icon(Icons.call,color: Colors.green,)),


             IconButton(onPressed: ()=> _sendEmail(users[index].email), icon: const Icon(Icons.email,color: Colors.indigo,)),
            ],)
          ,),
        )
        
        
        )),
    );
  }
}

void _viewUserDetails(context,User user) {

showModalBottomSheet(context: context, builder:(context)=>
ListView(

  children: [
    ListTile(
      title: Text(user.name),
      subtitle: Text(user.position),
    ),
    Image.network(user.pic ?? 'https://t4.ftcdn.net/jpg/02/29/75/83/360_F_229758328_7x8jwCwjtBMmC6rgFzLFhZoEpLobB6L8.jpg' ,width: 120,),
    ListTile(leading: const Icon(Icons.phone),title: Text(user.phone),),
    ListTile(leading: const Icon(Icons.email),title: Text(user.email),),
TextButton(onPressed: (){
   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(user.name),
   action: SnackBarAction(label: 'you view that profile', onPressed: (){}),
   ));
}, child: const Text('view profiled'))

  ],
) );
  
  

 // print(user.name);
}

_sendEmail(String email) async{


  try {
Uri uri = Uri.parse('mailto:+$email');
if (await canLaunchUrl(uri)) {
launchUrl(uri);
}
}catch (e){

log(e .toString());
}

}

_callUser(String phone) async {

  try {
Uri uri = Uri.parse('tel:+$phone');
if (await canLaunchUrl(uri)) {
launchUrl(uri);

}
}catch (e){

log(e .toString());
}

}


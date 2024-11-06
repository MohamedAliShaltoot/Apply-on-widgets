import 'package:flutter/material.dart';
import 'package:flutter_application_2/user.dart';

class MyhomePage extends StatelessWidget {
  MyhomePage({super.key});

  List<User> users = [
    User('mo@gmail.com', 'mohamed', '0123456788', 'software testing',
        'https://www.google.com/imgres?q=person%20image%20icon%20jpg&imgurl=https%3A%2F%2Fcdn-icons-png.flaticon.com%2F512%2F4202%2F4202841.png'),
    User('noha@gmail.com', 'noha', '0123720988', 'Graphic designer',
        'https://thumb.ac-illust.com/be/bee98c70d1cfc02d0f387d2852464bf5_t.jpeg'),
    User('magdi@gmail.com', 'magdi', '08432222788', 'drawer',
        'https://www.iconpacks.net/icons/1/free-user-icon-295-thumb.png'),
    User('hema@gmail.com', 'hema', '32345455588', 'backer',
        'https://www.google.com/imgres?q=person%20image%20icon%20jpg&imgurl=https%3A%2F%2Fst2.depositphotos.com%2F3369547%2F11481%2Fv%2F950%2Fdepositphotos_114817672-stock-illustration-avatar-man-icon-businesspeople-design.jpg'),
    User('mahy@gmail.com', 'mahy', '012445456788', 'engineer',
        'https://static.vecteezy.com/system/resources/previews/014/194/198/non_2x/avatar-icon-human-a-person-s-badge-social-media-profile-symbol-the-symbol-of-a-person-vector.jpg'),
    User('nader@gmail.com', 'nader', '01978756788', 'content creator',
        'https://visualpharm.com/assets/387/Person-595b40b75ba036ed117da139.svg'),
    User('wael@gmail.com', 'wael', '06765456788', 'project manager',
        'https://png.pngtree.com/png-vector/20190411/ourmid/pngtree-vector-business-man-icon-png-image_924785.jpg'),
    User('ahmed@gmail.com', 'ahmed', '67655456788', 'sw engineer'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GridView.builder(
          itemCount: users.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2),
          itemBuilder: (context, index) => InkWell(
            onTap: (){
              // ignore: avoid_print
              print(users[index].name);
            },
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(users[index].pic ??
                        'https://t4.ftcdn.net/jpg/02/29/75/83/360_F_229758328_7x8jwCwjtBMmC6rgFzLFhZoEpLobB6L8.jpg'),
                  ),
                  const SizedBox(height: 20,),
                  Text(users[index].name,style: TextStyle(fontSize: 40,color: Colors.black),),
                  Text(users[index].position),
                  const SizedBox(height: 5,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(onPressed: ()=> null, icon: const Icon(Icons.call,color: Colors.green,)),
            
            
               IconButton(onPressed: ()=> null, icon: const Icon(Icons.email,color: Colors.indigo,)),  
                    ],
                  )
            
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

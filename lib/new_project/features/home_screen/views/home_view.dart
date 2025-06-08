import 'package:flutter/material.dart';
import 'package:flutter_application_2/new_project/features/home_screen/data/home_repo/home_repo.dart';
import 'package:flutter_application_2/new_project/features/home_screen/data/models/home_model.dart';
import 'package:flutter_application_2/new_project/features/home_screen/manager/cubit/home_cubit.dart';
import 'package:flutter_application_2/new_project/features/home_screen/manager/cubit/home_state.dart';
import 'package:flutter_application_2/screens/home_1.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    NewsResponse? n = HomeRepo().getHomeData() as NewsResponse;
    return BlocProvider(
      create: (context) => HomeCubit(),
      child: BlocConsumer<HomeCubit, HomeState>(
        listener: (context, state) {
          if (state is HomeSuccess) {
          //  print(n.articles[0].title);
             print("sucress");
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("HomeScreen"),
            ),
            body:state is HomeLoading ? const CircularProgressIndicator(color: Color.fromARGB(255, 11, 67, 156),) : ElevatedButton(
                              onPressed: HomeCubit.get(context).onPressed,
                              child: const Text("get Data")),
            // body: state is HomeSuccess
            //     ? Column(
            //         children: [
            //           const Center(
            //             child: Text("Home"),
            //           ),
            //           Text(state.res as String),
            //           Text(state.res.articles[0].title!),
            //           Text(state.res.articles[0].description!),
            //           Text(state.res.articles[0].source!.name),
            //           state is HomeLoading
            //               ? const CircularProgressIndicator(
            //                   color: Color.fromARGB(255, 11, 67, 156),
            //                 )
            //               : ElevatedButton(
            //                   onPressed: HomeCubit.get(context).onPressed,
            //                   child: const Text("get Data")),
            //         ],
            //       )
            //     : const Center(
            //         child: CircularProgressIndicator(),
            //       ),
          );
        },
      ),
    );
  }
}

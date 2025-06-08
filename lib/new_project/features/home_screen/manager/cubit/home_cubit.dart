import 'package:bloc/bloc.dart';
import 'package:flutter_application_2/new_project/features/home_screen/data/home_repo/home_repo.dart';
import 'package:flutter_application_2/new_project/features/home_screen/manager/cubit/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

HomeRepo authRepo = HomeRepo();
  static HomeCubit get(context) => BlocProvider.of(context);
void onPressed() async {
    
    emit(HomeLoading());
    var result = await authRepo.getHomeData(
      
    );

    result.fold(
      (error) {
        emit(HomeError());
      },
      (res) {
        emit(HomeSuccess(res: res));
      },
    );
  }













}
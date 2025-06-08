// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter_application_2/new_project/features/home_screen/data/models/home_model.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeSuccess extends HomeState {
  NewsResponse res ;
  HomeSuccess( {
    required this.res,
  });
}

class HomeError extends HomeState {}

class HomeEmpty extends HomeState {}

class HomeNoInternet extends HomeState {}

class HomeNoData extends HomeState {}

class HomeNoToken extends HomeState {}

class HomeNoUser extends HomeState {}
 
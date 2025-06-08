// ignore_for_file: avoid_print

import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_application_2/new_project/core/network/api_response.dart';
import 'package:flutter_application_2/new_project/features/home_screen/data/models/home_model.dart';


import '../../../../core/cache/cache_helper.dart';
import '../../../../core/cache/cache_keys.dart';
import '../../../../core/network/api_helper.dart';

import '../../../../core/network/end_points.dart';

class HomeRepo {
  // singleton
  HomeRepo._internal();
  static final HomeRepo _repo = HomeRepo._internal();
  factory HomeRepo() => _repo;

  ApiHelper apiHelper = ApiHelper();
  Dio dio = Dio();
 
  Future<Either<String, NewsResponse>> getHomeData() async {
    try {
    Response response = await    dio.get("https://newsapi.org/v2/everything?q=apple&from=2025-06-06&to=2025-06-06&sortBy=popularity&apiKey=83b239da7eb34781b7efa27976cb11dc");
    return response.data; 
      
    } catch (e) {
      if (e is DioException) {
        if (e.response != null && e.response?.data['message'] != null) {
          return Left(e.response?.data['message']);
        }
      }
      ApiResponse apiResponse = ApiResponse.fromError(e);
      return Left(apiResponse.message);
      // print("Error ${e.toString()}");
      // return Left(e.toString());
    }
  }

  
  }

//https://newsapi.org/v2/everything?q=apple&from=2025-06-06&to=2025-06-06&sortBy=popularity&apiKey=83b239da7eb34781b7efa27976cb11dc

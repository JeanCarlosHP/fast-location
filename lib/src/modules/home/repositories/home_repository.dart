import 'package:dio/dio.dart';
import 'package:fast_location/src/http/app_dio.dart';

class HomeRepository with AppDio {
  Future<Response> getAddressViaCep(String cep) async {
    String baseUrl = 'https://viacep.com.br/ws';

    Dio httpClient = await AppDio.getConnection();

    Response response = await httpClient.get('$baseUrl/$cep/json');

    return response;
  }
}
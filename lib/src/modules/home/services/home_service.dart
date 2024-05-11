import 'package:dio/dio.dart';
import 'package:fast_location/src/modules/home/model/address_model.dart';
import 'package:fast_location/src/modules/home/repositories/home_local_repositories.dart';
import 'package:fast_location/src/modules/home/repositories/home_repository.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:map_launcher/map_launcher.dart';

class HomeService {
  final HomeRepository _homeRepository = HomeRepository();
  final HomeLocalRepository _homeLocalRepository = HomeLocalRepository();

  Future<AddressModel> getAddress(String cep) async {
    try {
      Response response = await _homeRepository.getAddressViaCep(cep);
      return AddressModel.fromJson(response.data);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<List<AddressModel>> getAddressRecentList() async {
    try {
      return await _homeLocalRepository.getAddressRecent() ?? <AddressModel>[];
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
  
  Future<List<AddressModel>> getAddressHistoryList() async {
    try {
      return await _homeLocalRepository.getAddressHistory() ?? <AddressModel>[];
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> addAddressHistory(AddressModel address) async {
    try {
      await _homeLocalRepository.addAddressHistory(address);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> openMap(BuildContext context, String address) async {
    try {
      Map<String, double> location = await getGeoLocation(address);

      double? latitude = location['latitude'] ?? 0;
      double? longitude = location['longitude'] ?? 0;

      final List<AvailableMap> avalibleMaps = await MapLauncher.installedMaps;

      if (avalibleMaps.isNotEmpty) {
        await avalibleMaps.first.showDirections(
          destinationTitle: "Destino",
          destination: Coords(latitude, longitude),
        );
      }
    } on Exception {
      rethrow;
    }
  }

  Future<Map<String, double>> getGeoLocation(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      return {
        'latitude': locations.first.latitude,
        'longitude': locations.first.longitude,
      };
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  } 
}

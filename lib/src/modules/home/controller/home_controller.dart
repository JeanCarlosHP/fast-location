import 'package:fast_location/src/modules/home/model/address_model.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:fast_location/src/modules/home/services/home_service.dart';

part 'home_controller.g.dart';

// ignore: library_private_types_in_public_api
class HomeController = _HomeControllerBase with _$HomeController;

abstract class _HomeControllerBase with Store {
  final HomeService _homeService = HomeService();

  @observable
  bool isLoading = false;

  @observable
  bool hasAddress = false;

  @observable
  bool hasError = false;

  @observable
  bool hasRouteError = false;

  @observable
  AddressModel? lastAddress;

  @observable
  List<AddressModel> addressRecentList = [];

  @action
  Future<void> loadData() async {
    isLoading = true;
    try {
      addressRecentList = await _homeService.getAddressRecentList();
      lastAddress = addressRecentList.isNotEmpty ? addressRecentList.first : null;
      hasAddress = addressRecentList.isNotEmpty;
    } catch (e) {
      hasError = true;
    }
    isLoading = false;
  }

  @action
  Future<void> getAddress(String cep) async {
    isLoading = true;
    try {
      final address = await _homeService.getAddress(cep);
      await _homeService.addAddressHistory(address);
      addressRecentList = await _homeService.getAddressRecentList();
      lastAddress = address;
      hasAddress = true;
    } catch (e) {
      hasRouteError = true;
    }
    isLoading = false;
  }

  @action
  Future<void> route(BuildContext context) async {
    isLoading = true;
    try {
      if (lastAddress != null) {
        await _homeService.openMap(context, '${lastAddress?.publicPlace}, ${lastAddress?.neighborhood}');
        isLoading = false;
      } else {
        hasRouteError = true;
        isLoading = false;
      }
    } catch (e) {
      hasRouteError = true;
      isLoading = false;
      debugPrint(e.toString());
    }
    isLoading = false;
  }
}

import 'package:fast_location/src/modules/home/components/search_address.dart';
import 'package:fast_location/src/modules/home/components/search_empty.dart';
import 'package:fast_location/src/modules/home/controller/home_controller.dart';
import 'package:fast_location/src/routes/app_router.dart';
import 'package:fast_location/src/shared/colors/app_colors.dart';
import 'package:fast_location/src/shared/components/app_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:geocoding/geocoding.dart';
import 'package:map_launcher/map_launcher.dart';
import '../components/button_action.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeController controller = HomeController();
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.loadData();
  }

  void searchCep(value) async {
    try {
      Navigator.pop(context);
      await controller.getAddress(value.replaceAll('-', ''));
    } catch(_) {
      await Future.delayed(const Duration(seconds: 1));
      if (context.mounted) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao buscar cep '$value'"))
        );
      }
    }

    _textEditingController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        return controller.isLoading
        ? const AppLoading()
        : Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: AppColors.background,
          body: Padding(
            padding: const EdgeInsets.only(top: 60),
            child: Center(
              child: Column(
                  children: [
                    const Flexible(
                      child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.swap_calls, color: AppColors.primary, size: 40,),
                              Text('Fast Location',
                              style: TextStyle(
                                fontWeight: FontWeight.bold, 
                                color: AppColors.primary, 
                                fontSize: 30 
                                ),
                              ),
                            ],
                          ),
                        ),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: controller.lastAddress == null
                      ? const SearchEmpty()
                      : SearchAddress(address: controller.lastAddress!)
                    ),
                    ButtonAction(
                      title: 'Localizar endereço', 
                      onPressed: () async {
                        showDialog(
                          context: context, 
                          builder: (context) => Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextFormField(
                                    controller: _textEditingController,
                                    autofocus: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Insira o cep',
                                      hintText: '00000-000',
                                      labelStyle: TextStyle(color: AppColors.grey),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: AppColors.primary)
                                      ),
                                    ), 
                                    keyboardType: TextInputType.number,
                                    onFieldSubmitted: (value) async => searchCep(value),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 20),
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ButtonStyle(
                                        shape: MaterialStateProperty.resolveWith(
                                          (states) => RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5)
                                          )
                                        ),
                                        foregroundColor: MaterialStateProperty.resolveWith(
                                          (states) => Colors.white
                                        ),
                                        backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                                          (Set<MaterialState> states) {
                                            if (states.contains(MaterialState.pressed)) {
                                              return AppColors.primary.withOpacity(0.5);
                                            }
                                            return AppColors.primary; // Use the component's default.
                                          },
                                        ),
                                      ),
                                      onPressed: () => searchCep(_textEditingController.text),
                                      child: const Text('Buscar'),
                                      )  
                                  )
                                ],
                              ),
                            ),
                          ), 
                        );
                      }
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: Row(
                        children: [
                          Icon(Icons.location_on, color: AppColors.primary,),
                          Text(
                            'Últimos endereços localizados',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18
                            ),
                          )
                        ],
                      ),
                    ),
                    controller.lastAddress == null
                    ? Container(
                        margin: const EdgeInsets.fromLTRB(20, 20, 20, 5),
                        padding: const EdgeInsets.all(30),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: const Center(
                          child: Column(
                            children: [
                              Icon(Icons.location_off, color: AppColors.primary, size: 50,),
                              Padding(
                                padding: EdgeInsets.only(top: 16),
                                child: Text(
                                  'Não há locais recentes',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    : Container(
                      margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.card
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.history),
                        title: Text(controller.lastAddress!.publicPlace, style: const TextStyle(fontWeight: FontWeight.bold),),
                        subtitle: Text(controller.lastAddress!.publicPlace),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(controller.lastAddress!.publicPlace, style: const TextStyle(fontWeight: FontWeight.bold),),
                            Text(controller.lastAddress!.cep)
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: ButtonAction(
                        title: 'Histórico de endereços', 
                        onPressed: () async {
                          Navigator.pushNamed(context, AppRouter.history);
                        }
                      ),
                    )
                  ],
                ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: controller.lastAddress == null 
            ? AppColors.inactive
            : AppColors.primary,
            onPressed: controller.lastAddress == null
            ? null
            : () async {
              List<Location> locations = await locationFromAddress("${controller.lastAddress!.publicPlace}, ${controller.lastAddress!.neighborhood}");
              await MapLauncher.showDirections(
                mapType: MapType.google,
                destination: Coords(locations[0].latitude, locations[0].longitude),
              );
            },
            child: const Icon(Icons.arrow_circle_right_outlined),
          ),
        );
      }
    );
  }
}
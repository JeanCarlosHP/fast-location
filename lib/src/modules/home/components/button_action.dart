import 'package:fast_location/src/shared/colors/app_colors.dart';
import 'package:flutter/material.dart';

class ButtonAction extends StatelessWidget {

  final String title;
  final void Function() onPressed;

  const ButtonAction({super.key, required this.title, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: ElevatedButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.resolveWith(
            (states) => RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
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
        onPressed: onPressed,
        child: Text(title),
      ),
    );
  }
}
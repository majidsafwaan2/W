import 'package:flash/flash.dart';
import 'package:flutter/widgets.dart';
import 'package:resources/widgets/custom_flash_widget.dart';

extension ContextExtensions on BuildContext {
  void showCustomFlashMessage({
    String title = 'Notification',
    String message = 'Action completed successfully',
    bool positionBottom = false,
    bool darkTheme = false,
    required String status,
  }) {
    showFlash(
      context: this,
      duration: const Duration(seconds: 2),
      builder: (_, controller) {
        return Padding(
          padding: const EdgeInsets.all(18.0),
          child: CustomFlashWidget(
            status: status,
            controller: controller,
            title: title,
            message: message,
            darkTheme: darkTheme,
            positionBottom: positionBottom,
          ),
        );
      },
    );
  }
}

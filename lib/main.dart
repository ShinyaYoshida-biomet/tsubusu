import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'providers/theme_provider.dart';
import 'services/window_manager.dart';
import 'widgets/pages/todo_page.dart';

void main(List<String> args) {
  WidgetsFlutterBinding.ensureInitialized();

  // Suppress known Flutter HardwareKeyboard assertion errors on macOS
  // This is a known Flutter bug with multi-window apps and modifier keys
  // See: https://github.com/flutter/flutter/issues/167090
  //      https://github.com/flutter/flutter/issues/87391
  if (defaultTargetPlatform == TargetPlatform.macOS) {
    // Handle FlutterError errors
    FlutterError.onError = (FlutterErrorDetails details) {
      final exception = details.exception.toString();

      // Check for known keyboard state assertion errors
      final isKeyboardAssertionError =
          exception.contains('_assertEventIsRegular') &&
          (exception.contains('KeyDownEvent is dispatched') ||
              exception.contains('KeyUpEvent is dispatched'));

      if (isKeyboardAssertionError) {
        // Known Flutter framework bug - log in debug mode but suppress error
        if (kDebugMode) {
          debugPrint('[Suppressed] Known Flutter keyboard state issue');
        }
        return;
      }

      // Re-throw all other errors normally
      FlutterError.presentError(details);
    };

    // Handle uncaught errors from Dart VM (includes engine-level errors)
    PlatformDispatcher.instance.onError = (error, stack) {
      final errorString = error.toString();

      // Check for known keyboard state assertion errors
      final isKeyboardAssertionError =
          errorString.contains('_assertEventIsRegular') ||
          (errorString.contains('HardwareKeyboard') &&
              (errorString.contains('KeyDownEvent is dispatched') ||
                  errorString.contains('KeyUpEvent is dispatched') ||
                  errorString.contains('physical key is already pressed')));

      if (isKeyboardAssertionError) {
        // Suppress this specific error
        if (kDebugMode) {
          debugPrint('[Suppressed] Flutter keyboard assertion error');
        }
        return true; // Indicates error was handled
      }

      // Return false to let other errors be handled normally
      return false;
    };
  }

  if (WindowManager.supportsWindowManagement &&
      args.firstOrNull == 'multi_window') {
    final windowId = int.parse(args[1]);
    runApp(
      TsubusuWindow(windowController: WindowController.fromWindowId(windowId)),
    );
  } else {
    runApp(const TsubusuWindow());
  }
}

class TsubusuWindow extends StatelessWidget {
  final WindowController? windowController;

  const TsubusuWindow({super.key, this.windowController});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Tsubusu',
            theme: themeProvider.themeData,
            home: const TodoPage(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'check_version_app_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const VersionCheckWrapper(),
    );
  }
}

/// Обертка для проверки версии приложения при запуске
class VersionCheckWrapper extends StatefulWidget {
  const VersionCheckWrapper({super.key});

  @override
  State<VersionCheckWrapper> createState() => _VersionCheckWrapperState();
}

class _VersionCheckWrapperState extends State<VersionCheckWrapper> {
  late Future<VersionCheckResult> _versionCheck;
  bool _bottomSheetShown = false;

  // TODO: Замените на URL вашего Serverpod сервера
  final versionService = CheckVersionAppService(
    baseUrl:
        'http://localhost:8080', // Для эмулятора Android используйте http://10.0.2.2:8080
  );

  @override
  void initState() {
    super.initState();
    _versionCheck = versionService.checkVersion();
  }

  void _showVersionBottomSheet(
    BuildContext context,
    VersionCheckResult result,
  ) {
    if (_bottomSheetShown) return;
    _bottomSheetShown = true;

    showModalBottomSheet(
      context: context,
      isDismissible: !result.isBlocked,
      enableDrag: !result.isBlocked,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => WillPopScope(
        onWillPop: () async => !result.isBlocked,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: result.isBlocked
              ? Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.9,
                  ),
                  child: SingleChildScrollView(
                    child: _buildBottomSheetContent(context, result),
                  ),
                )
              : DraggableScrollableSheet(
                  initialChildSize: 0.6,
                  minChildSize: 0.4,
                  maxChildSize: 0.9,
                  expand: false,
                  builder: (context, scrollController) => SingleChildScrollView(
                    controller: scrollController,
                    child: _buildBottomSheetContent(context, result),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildBottomSheetContent(
    BuildContext context,
    VersionCheckResult result,
  ) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: Image.asset('assets/Placeholder.png'),
            ),
            SizedBox(height: 24),
            Text(
              'Требуется обновление',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 75, 78, 81),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Для обеспечения надёжной работы системы охраны требуется обновление.',
              style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14),
            ),
            SizedBox(height: 16),
            Text(
              'Пожалуйста, установите новую версию приложения.',
              style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14),
            ),
            SizedBox(height: 32),
            Builder(
              builder: (context) {
                if (Platform.isIOS) {
                  return SizedBox(
                    height: 40,
                    child: FilledButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.black),
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      onPressed: () {},
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset('assets/apple.svg'),
                            SizedBox(width: 8),
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                'App Store',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return FilledButton(
                  onPressed: () {},
                  child: Row(
                    children: [SvgPicture.asset('assets/google-play.svg')],
                  ),
                );
              },
            ),
            // Icon(Icons.warning_rounded, size: 64, color: Colors.red.shade600),
            // const SizedBox(height: 16),
            // Text(
            //   result.isBlocked ? 'Требуется обновление' : 'Доступно обновление',
            //   style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            //     fontWeight: FontWeight.bold,
            //     color: Colors.red.shade900,
            //   ),
            //   textAlign: TextAlign.center,
            // ),
            // const SizedBox(height: 12),
            // Text(
            //   result.blockReason ??
            //       'Ваша версия приложения больше не поддерживается. '
            //           'Пожалуйста, обновите приложение до последней версии.',
            //   style: Theme.of(context).textTheme.bodyLarge,
            //   textAlign: TextAlign.center,
            // ),
            // const SizedBox(height: 20),
            // Container(
            //   padding: const EdgeInsets.all(16),
            //   decoration: BoxDecoration(
            //     color: Colors.grey.shade100,
            //     borderRadius: BorderRadius.circular(8),
            //   ),
            //   child: Column(
            //     children: [
            //       _buildVersionRow(
            //         'Текущая версия:',
            //         '${result.currentVersion} (${result.currentBuildNumber})',
            //         Icons.phone_android,
            //       ),
            //       if (result.latestVersion != null) ...[
            //         const SizedBox(height: 12),
            //         _buildVersionRow(
            //           'Последняя версия:',
            //           '${result.latestVersion} (${result.latestBuildNumber ?? ""})',
            //           Icons.arrow_upward,
            //         ),
            //       ],
            //     ],
            //   ),
            // ),
            // if (result.changelog != null && result.changelog!.isNotEmpty) ...[
            //   const SizedBox(height: 20),
            //   Container(
            //     width: double.infinity,
            //     padding: const EdgeInsets.all(16),
            //     decoration: BoxDecoration(
            //       color: Colors.blue.shade50,
            //       borderRadius: BorderRadius.circular(8),
            //       border: Border.all(color: Colors.blue.shade200),
            //     ),
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Row(
            //           children: [
            //             Icon(
            //               Icons.new_releases,
            //               size: 20,
            //               color: Colors.blue.shade700,
            //             ),
            //             const SizedBox(width: 8),
            //             Text(
            //               'Что нового:',
            //               style: TextStyle(
            //                 fontWeight: FontWeight.bold,
            //                 color: Colors.blue.shade900,
            //               ),
            //             ),
            //           ],
            //         ),
            //         const SizedBox(height: 8),
            //         Text(
            //           result.changelog!,
            //           style: TextStyle(color: Colors.grey.shade800),
            //         ),
            //       ],
            //     ),
            //   ),
            // ],
            // const SizedBox(height: 24),
            // SizedBox(
            //   width: double.infinity,
            //   child: ElevatedButton.icon(
            //     onPressed: () {
            //       // Здесь можно добавить логику перехода в магазин приложений
            //     },
            //     icon: const Icon(Icons.system_update),
            //     label: const Text(
            //       'Обновить приложение',
            //       style: TextStyle(fontSize: 16),
            //     ),
            //     style: ElevatedButton.styleFrom(
            //       padding: const EdgeInsets.symmetric(vertical: 16),
            //       backgroundColor: Colors.red.shade600,
            //       foregroundColor: Colors.white,
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(8),
            //       ),
            //     ),
            //   ),
            // ),
            // if (!result.isBlocked) ...[
            //   const SizedBox(height: 12),
            //   TextButton(
            //     onPressed: () => Navigator.pop(context),
            //     child: const Text('Позже'),
            //   ),
            // ],
          ],
        ),
      ),
    );
  }

  Widget _buildVersionRow(String label, String version, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey.shade700),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        Text(
          version,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<VersionCheckResult>(
      future: _versionCheck,
      builder: (context, snapshot) {
        // Показываем загрузку
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Проверка версии приложения...'),
                ],
              ),
            ),
          );
        }

        // Показываем ошибку (но разрешаем продолжить)
        if (snapshot.hasError) {
          return const MyHomePage(title: 'Flutter Demo Home Page');
        }

        final result = snapshot.data;

        // Если версия заблокирована - показываем BottomSheet
        if (result != null && result.isBlocked) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showVersionBottomSheet(context, result);
          });
        }

        // Показываем основное приложение
        return const MyHomePage(title: 'Flutter Demo Home Page');
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class AppDeviceInfo {
  final PackageInfo packageInfo;
  final dynamic deviceInfo;

  AppDeviceInfo(this.packageInfo, this.deviceInfo);
}

class _MyHomePageState extends State<MyHomePage> {
  Future<AppDeviceInfo>? _allInfo;

  Future<AppDeviceInfo> _loadInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final deviceInfoPlugin = DeviceInfoPlugin();

    dynamic deviceInfo;
    if (Platform.isAndroid) {
      deviceInfo = await deviceInfoPlugin.androidInfo;
    } else if (Platform.isIOS) {
      deviceInfo = await deviceInfoPlugin.iosInfo;
    } else {
      deviceInfo = null;
    }

    return AppDeviceInfo(packageInfo, deviceInfo);
  }

  @override
  void initState() {
    super.initState();
    _allInfo = _loadInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            FutureBuilder<AppDeviceInfo>(
              future: _allInfo,
              builder:
                  (
                    BuildContext context,
                    AsyncSnapshot<AppDeviceInfo> snapshot,
                  ) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Column(
                        children: [
                          Text('Данные грузятся'),
                          SizedBox(height: 10),
                          CircularProgressIndicator(),
                        ],
                      );
                    }
                    if (snapshot.hasError) {
                      return Text(
                        'Данные не загружены, ошибка ${snapshot.error}',
                      );
                    }
                    if (!snapshot.hasData) {
                      return Text('Данные недоступны');
                    }
                    final info = snapshot.data!;
                    return Column(
                      children: [
                        AppInfoWidget(packageInfo: info.packageInfo),
                        SizedBox(height: 10),
                        DeviceInfoWidget(deviceInfo: info.deviceInfo),
                      ],
                    );
                  },
            ),
          ],
        ),
      ),
    );
  }
}

class DeviceInfoWidget extends StatelessWidget {
  final dynamic deviceInfo;

  const DeviceInfoWidget({super.key, required this.deviceInfo});

  @override
  Widget build(BuildContext context) {
    if (deviceInfo is AndroidDeviceInfo) {
      print(deviceInfo);
      return Column(
        children: [
          Text('Устройство: ${deviceInfo.model}'),
          Text('Android: ${deviceInfo.version.release}'),
          Text('Бренд: ${deviceInfo.brand}'),
        ],
      );
    } else if (deviceInfo is IosDeviceInfo) {
      return Column(
        children: [
          Text('Устройство: ${deviceInfo.model}'),
          Text('iOS: ${deviceInfo.systemVersion}'),
          Text('Имя: ${deviceInfo.name}'),
        ],
      );
    } else {
      return Text('Неизвестная платформа');
    }
  }
}

class AppInfoWidget extends StatelessWidget {
  final PackageInfo packageInfo;

  const AppInfoWidget({super.key, required this.packageInfo});

  @override
  Widget build(BuildContext context) {
    print(packageInfo);
    return Column(
      children: [
        Text('Название приложения: ${packageInfo.appName}'),
        Text('Namespace: ${packageInfo.packageName}'),
        Text(
          'Версия приложения: ${packageInfo.version}+${packageInfo.buildNumber}',
        ),
      ],
    );
  }
}

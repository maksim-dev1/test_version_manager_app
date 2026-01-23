import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

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
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
                        Text(
                          'Название приложения: ${info.packageInfo.appName}',
                        ),
                        Text('Namespace: ${info.packageInfo.packageName}'),
                        Text('Версия приложения: ${info.packageInfo.version}'),
                        SizedBox(height: 10),
                        DeviceInfoWidget(deviceInfo: info.deviceInfo)
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
  Widget build(BuildContext context){
    if (deviceInfo is AndroidDeviceInfo) {
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

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

/// Результат проверки версии
class VersionCheckResult {
  final bool isBlocked;
  final String? blockReason;
  final String? latestVersion;
  final int? latestBuildNumber;
  final bool forceUpdate;
  final String? changelog;
  final String currentVersion;
  final int currentBuildNumber;

  VersionCheckResult({
    required this.isBlocked,
    this.blockReason,
    this.latestVersion,
    this.latestBuildNumber,
    required this.forceUpdate,
    this.changelog,
    required this.currentVersion,
    required this.currentBuildNumber,
  });

  /// Есть ли доступное обновление
  bool get hasUpdate => latestVersion != null;
}

/// Сервис для проверки версии приложения
class CheckVersionAppService {
  final String baseUrl;

  CheckVersionAppService({required this.baseUrl});

  /// Проверяет, доступна ли текущая версия приложения
  Future<VersionCheckResult> checkVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final buildNumber = int.tryParse(packageInfo.buildNumber) ?? 1;
      final packageName = packageInfo.packageName;

      // Определяем платформу как строку
      String platform;
      if (Platform.isAndroid) {
        platform = 'android';
      } else if (Platform.isIOS) {
        platform = 'ios';
      } else {
        platform = 'unknown';
      }

      // Формируем URL с query параметрами
      final uri = Uri.parse('$baseUrl/appCheck/checkVersion').replace(
        queryParameters: {
          'packageName': packageName,
          'currentVersion': currentVersion,
          'currentBuildNumber': buildNumber.toString(),
          'platform': platform,
        },
      );

      final response = await http
          .post(uri, headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return VersionCheckResult(
          isBlocked: data['isBlocked'] ?? false,
          blockReason: data['blockReason'],
          latestVersion: data['latestVersion'],
          latestBuildNumber: data['latestBuildNumber'],
          forceUpdate: data['forceUpdate'] ?? false,
          changelog: data['changelog'],
          currentVersion: currentVersion,
          currentBuildNumber: buildNumber,
        );
      } else {
        return VersionCheckResult(
          isBlocked: false,
          blockReason: null,
          forceUpdate: false,
          currentVersion: currentVersion,
          currentBuildNumber: buildNumber,
        );
      }
    } catch (e) {
      final packageInfo = await PackageInfo.fromPlatform();
      final buildNumber = int.tryParse(packageInfo.buildNumber) ?? 1;

      return VersionCheckResult(
        isBlocked: false,
        blockReason: 'Ошибка проверки версии: $e',
        forceUpdate: false,
        currentVersion: packageInfo.version,
        currentBuildNumber: buildNumber,
      );
    }
  }

  /// Получает текущую версию приложения
  Future<String> getCurrentVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return '${packageInfo.version}+${packageInfo.buildNumber}';
  }
}

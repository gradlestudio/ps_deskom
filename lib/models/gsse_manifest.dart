import 'dart:convert';

class GsseManifest {
  final String appName;
  final String appEdition;
  final String version;
  final String publisher;
  final String website;
  final String defaultInstallDir;
  final String mainExecutable;
  final bool createDesktopShortcut;
  final bool createStartMenuShortcut;
  final bool runAfterInstall;
  final String? eulaText;

  GsseManifest({
    required this.appName,
    required this.appEdition,
    required this.version,
    this.publisher = 'Gradle Studio',
    this.website = 'https://gradlestudio.com',
    required this.defaultInstallDir,
    required this.mainExecutable,
    this.createDesktopShortcut = true,
    this.createStartMenuShortcut = true,
    this.runAfterInstall = true,
    this.eulaText,
  });

  Map<String, dynamic> toMap() {
    return {
      'appName': appName,
      'appEdition': appEdition,
      'version': version,
      'publisher': publisher,
      'website': website,
      'defaultInstallDir': defaultInstallDir,
      'mainExecutable': mainExecutable,
      'createDesktopShortcut': createDesktopShortcut,
      'createStartMenuShortcut': createStartMenuShortcut,
      'runAfterInstall': runAfterInstall,
      'eulaText': eulaText,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory GsseManifest.fromMap(Map<String, dynamic> map) {
    return GsseManifest(
      appName: map['appName'] as String? ?? 'PS DesKom',
      appEdition: map['appEdition'] as String? ?? 'PRO',
      version: map['version'] as String? ?? '1.0.0',
      publisher: map['publisher'] as String? ?? 'Gradle Studio',
      website: map['website'] as String? ?? 'https://gradlestudio.com',
      defaultInstallDir: map['defaultInstallDir'] as String? ?? r'C:\Program Files\Gradle Studio\PS DesKom',
      mainExecutable: map['mainExecutable'] as String? ?? 'ps_deskom.exe',
      createDesktopShortcut: map['createDesktopShortcut'] as bool? ?? true,
      createStartMenuShortcut: map['createStartMenuShortcut'] as bool? ?? true,
      runAfterInstall: map['runAfterInstall'] as bool? ?? true,
      eulaText: map['eulaText'] as String?,
    );
  }

  factory GsseManifest.fromJson(Map<String, dynamic> json) => GsseManifest.fromMap(json);

  String toJsonString() => jsonEncode(toMap());
}

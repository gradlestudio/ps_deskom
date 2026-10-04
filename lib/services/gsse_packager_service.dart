import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import '../models/gsse_manifest.dart';

class GssePackagerService {
  static const String magicSignature = 'GSSE_V10';
  static const int footerByteSize = 32;

  /// Localiza o executável do NSIS (makensis.exe) no sistema
  Future<String?> localizarMakensis() async {
    final candidatePaths = [
      r'C:\Program Files (x86)\NSIS\makensis.exe',
      r'C:\Program Files\NSIS\makensis.exe',
      p.join(Directory.current.path, 'tools', 'nsis', 'makensis.exe'),
    ];

    for (final path in candidatePaths) {
      if (await File(path).exists()) {
        return path;
      }
    }

    // Tenta via PATH do sistema
    try {
      final res = await Process.run('where', ['makensis.exe']);
      if (res.exitCode == 0 && res.stdout.toString().trim().isNotEmpty) {
        return res.stdout.toString().trim().split('\r\n').first.trim();
      }
    } catch (_) {}

    return null;
  }

  /// Gera e compila um instalador nativo profissional utilizando a engine NSIS (makensis.exe)
  /// com suporte a 7 idiomas nativos e detecção de DDI / Locale do Windows,
  /// com fallback para empacotamento binário GSSE se o NSIS não estiver instalado.
  Future<File> buildInstaller({
    required Directory sourceDir,
    File? stubExecutable,
    required File outputFile,
    required GsseManifest manifest,
    void Function(String message, double progress)? onProgress,
  }) async {
    onProgress?.call('Verificando ambiente do compilador...', 0.05);

    if (!await sourceDir.exists()) {
      throw Exception('Diretório de origem não existe: ${sourceDir.path}');
    }

    final makensisPath = await localizarMakensis();

    if (makensisPath != null) {
      return await _buildInstallerWithNsis(
        sourceDir: sourceDir,
        makensisPath: makensisPath,
        outputFile: outputFile,
        manifest: manifest,
        onProgress: onProgress,
      );
    } else {
      onProgress?.call('NSIS não encontrado no sistema. Utilizando empacotador binário nativo GSSE...', 0.10);
      return await _buildInstallerWithBinaryPacker(
        sourceDir: sourceDir,
        stubExecutable: stubExecutable ?? File(p.join(Directory.current.path, 'assets', 'tools', 'gs_stub.exe')),
        outputFile: outputFile,
        manifest: manifest,
        onProgress: onProgress,
      );
    }
  }

  /// Gera um script .nsi temporário e invoca o makensis.exe com suporte multilíngue
  Future<File> _buildInstallerWithNsis({
    required Directory sourceDir,
    required String makensisPath,
    required File outputFile,
    required GsseManifest manifest,
    void Function(String message, double progress)? onProgress,
  }) async {
    onProgress?.call('Gerando script de instalação NSIS multilíngue (.nsi)...', 0.15);

    final iconFile = File(p.join(Directory.current.path, 'tools', 'gsse_stub', 'app_icon.ico'));
    final String iconPath = (await iconFile.exists())
        ? iconFile.path
        : p.join(Directory.current.path, 'assets', 'icones', 'PS-DesKom.ico');

    final String tempNsiPath = p.join(
      Directory.systemTemp.path,
      'gsse_build_${DateTime.now().millisecondsSinceEpoch}.nsi',
    );

    final runMacro = manifest.runAfterInstall
        ? '!define MUI_FINISHPAGE_RUN "\$INSTDIR\\\\${manifest.mainExecutable}"'
        : '';
    final shortcutStartMenu = manifest.createStartMenuShortcut
        ? 'CreateShortcut "\$SMPROGRAMS\\\\${manifest.appName}\\\\${manifest.appName}.lnk" "\$INSTDIR\\\\${manifest.mainExecutable}"\n  CreateShortcut "\$SMPROGRAMS\\\\${manifest.appName}\\\\Uninstall.lnk" "\$INSTDIR\\\\uninstall.exe"'
        : '';
    final shortcutDesktop = manifest.createDesktopShortcut
        ? 'CreateShortcut "\$DESKTOP\\\\${manifest.appName}.lnk" "\$INSTDIR\\\\${manifest.mainExecutable}"'
        : '';

    final nsiContent = '''
Unicode true
RequestExecutionLevel admin
SetCompressor /SOLID lzma

!include "MUI2.nsh"

!define APP_NAME "${manifest.appName}"
!define APP_VERSION "${manifest.version}"
!define PUBLISHER "${manifest.publisher}"
!define WEBSITE "${manifest.website}"
!define MAIN_EXE "${manifest.mainExecutable}"

Name "\${APP_NAME}"
OutFile "${outputFile.path.replaceAll(r'\', '/')}"
InstallDir "\$PROGRAMFILES64\\\${PUBLISHER}\\\${APP_NAME}"
InstallDirRegKey HKLM "Software\\\${PUBLISHER}\\\${APP_NAME}" "InstallLocation"

!define MUI_ICON "${iconPath.replaceAll(r'\', '/')}"
!define MUI_UNICON "${iconPath.replaceAll(r'\', '/')}"

VIProductVersion "${manifest.version}.0"
VIAddVersionKey "CompanyName" "\${PUBLISHER}"
VIAddVersionKey "FileDescription" "\${APP_NAME} Setup — Gradle Studio"
VIAddVersionKey "FileVersion" "\${APP_VERSION}"
VIAddVersionKey "LegalCopyright" "Copyright (C) 2026 \${PUBLISHER}. Todos os direitos reservados."
VIAddVersionKey "ProductName" "\${APP_NAME}"
VIAddVersionKey "ProductVersion" "\${APP_VERSION}"

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
$runMacro
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "PortugueseBR"
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "Spanish"
!insertmacro MUI_LANGUAGE "French"
!insertmacro MUI_LANGUAGE "German"
!insertmacro MUI_LANGUAGE "Italian"
!insertmacro MUI_LANGUAGE "Russian"

Function .onInit
  !insertmacro MUI_LANGDLL_DISPLAY
FunctionEnd

Section "MainSection" SEC01
  SetOutPath "\$INSTDIR"
  File /r "${sourceDir.path.replaceAll(r'\', '/')}\\*.*"

  CreateDirectory "\$SMPROGRAMS\\\${APP_NAME}"
  $shortcutStartMenu
  $shortcutDesktop

  WriteUninstaller "\$INSTDIR\\uninstall.exe"

  WriteRegStr HKCU "Software\\\${PUBLISHER}\\\${APP_NAME}" "InstallerLanguage" "\$LANGUAGE"

  WriteRegStr HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\\${APP_NAME}" "DisplayName" "\${APP_NAME}"
  WriteRegStr HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\\${APP_NAME}" "UninstallString" '"\$INSTDIR\\uninstall.exe"'
  WriteRegStr HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\\${APP_NAME}" "InstallLocation" "\$INSTDIR"
  WriteRegStr HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\\${APP_NAME}" "DisplayVersion" "\${APP_VERSION}"
  WriteRegStr HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\\${APP_NAME}" "Publisher" "\${PUBLISHER}"
  WriteRegDWORD HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\\${APP_NAME}" "NoModify" 1
  WriteRegDWORD HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\\${APP_NAME}" "NoRepair" 1
SectionEnd

Section "Uninstall"
  RMDir /r "\$INSTDIR"
  RMDir /r "\$SMPROGRAMS\\\${APP_NAME}"
  Delete "\$DESKTOP\\\${APP_NAME}.lnk"
  DeleteRegKey HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\\${APP_NAME}"
  DeleteRegKey HKLM "Software\\\${PUBLISHER}\\\${APP_NAME}"
  DeleteRegKey HKCU "Software\\\${PUBLISHER}\\\${APP_NAME}"
SectionEnd
''';

    final tempNsiFile = File(tempNsiPath);
    await tempNsiFile.writeAsString(nsiContent, encoding: utf8);

    onProgress?.call('Compilando instalador via NSIS Engine (makensis.exe)...', 0.30);

    if (await outputFile.exists()) {
      await outputFile.delete();
    }
    await outputFile.parent.create(recursive: true);

    final process = await Process.start(
      makensisPath,
      ['/V3', tempNsiPath],
      runInShell: true,
    );

    double currentProgress = 0.30;
    process.stdout.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
      if (line.trim().isNotEmpty) {
        currentProgress = (currentProgress + 0.02).clamp(0.30, 0.95);
        onProgress?.call(line.trim(), currentProgress);
      }
    });

    process.stderr.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
      if (line.trim().isNotEmpty) {
        onProgress?.call('[NSIS AVISO/ERRO] ${line.trim()}', currentProgress);
      }
    });

    final exitCode = await process.exitCode;

    // Limpeza do script temporário
    if (await tempNsiFile.exists()) {
      await tempNsiFile.delete();
    }

    if (exitCode != 0 || !await outputFile.exists()) {
      throw Exception('Falha na compilação do NSIS (exitCode $exitCode). Verifique os logs.');
    }

    onProgress?.call('Instalador NSIS/GSSE gerado com sucesso!', 1.0);
    return outputFile;
  }

  /// Método legado de fallback: empacotamento binário com footer de 32 bytes (GSSE_V10)
  Future<File> _buildInstallerWithBinaryPacker({
    required Directory sourceDir,
    required File stubExecutable,
    required File outputFile,
    required GsseManifest manifest,
    void Function(String message, double progress)? onProgress,
  }) async {
    onProgress?.call('Escaneando arquivos para o empacotador binário...', 0.20);

    final allFiles = sourceDir
        .listSync(recursive: true)
        .whereType<File>()
        .toList();

    if (allFiles.isEmpty) {
      throw Exception('Nenhum arquivo encontrado no diretório: ${sourceDir.path}');
    }

    final archive = Archive();
    final totalFiles = allFiles.length;

    for (int i = 0; i < totalFiles; i++) {
      final file = allFiles[i];
      final relativePath = p.relative(file.path, from: sourceDir.path);
      final bytes = await file.readAsBytes();

      archive.addFile(ArchiveFile(
        relativePath.replaceAll(r'\', '/'),
        bytes.length,
        bytes,
      ));

      final progress = 0.20 + (0.45 * ((i + 1) / totalFiles));
      onProgress?.call('Compactando ($i/$totalFiles): $relativePath', progress);
    }

    final zipEncoder = ZipEncoder();
    final zipPayloadBytes = zipEncoder.encode(archive);
    if (zipPayloadBytes == null) {
      throw Exception('Falha ao codificar o payload ZIP.');
    }

    final jsonManifestStr = manifest.toJsonString();
    final jsonManifestBytes = utf8.encode(jsonManifestStr);

    Uint8List stubBytes;
    if (await stubExecutable.exists()) {
      stubBytes = await stubExecutable.readAsBytes();
    } else {
      final dummyHeader = utf8.encode('GSSE_STUB_HEADER_DUMMY_2026\n');
      stubBytes = Uint8List.fromList(dummyHeader);
    }

    final stubBytesLength = stubBytes.length;
    final zipPayloadOffset = stubBytesLength;
    final zipPayloadLength = zipPayloadBytes.length;
    final jsonManifestOffset = zipPayloadOffset + zipPayloadLength;
    final jsonManifestLength = jsonManifestBytes.length;

    final footerByteData = ByteData(footerByteSize);
    footerByteData.setUint64(0, zipPayloadOffset, Endian.little);
    footerByteData.setUint64(8, jsonManifestOffset, Endian.little);
    footerByteData.setUint64(16, jsonManifestLength, Endian.little);

    final magicBytes = utf8.encode(magicSignature);
    for (int i = 0; i < 8; i++) {
      footerByteData.setUint8(24 + i, magicBytes[i]);
    }

    if (await outputFile.exists()) {
      await outputFile.delete();
    }
    await outputFile.parent.create(recursive: true);

    final outputIOSink = outputFile.openWrite();
    outputIOSink.add(stubBytes);
    outputIOSink.add(zipPayloadBytes);
    outputIOSink.add(jsonManifestBytes);
    outputIOSink.add(footerByteData.buffer.asUint8List());

    await outputIOSink.flush();
    await outputIOSink.close();

    onProgress?.call('Instalador GSSE gerado com sucesso!', 1.0);
    return outputFile;
  }

  /// Inspeciona um instalador GSSE para validar assinatura e extrair o manifesto
  Future<GsseManifest?> inspectInstaller(File installerFile) async {
    if (!await installerFile.exists()) return null;

    final length = await installerFile.length();
    if (length < footerByteSize) return null;

    final raf = await installerFile.open(mode: FileMode.read);
    try {
      await raf.setPosition(length - footerByteSize);
      final footerBytes = await raf.read(footerByteSize);
      final footerByteData = ByteData.sublistView(footerBytes);

      final magicBytes = footerBytes.sublist(24, 32);
      final magicStr = utf8.decode(magicBytes, allowMalformed: true);
      if (magicStr != magicSignature) {
        return null;
      }

      final jsonManifestOffset = footerByteData.getUint64(8, Endian.little);
      final jsonManifestLength = footerByteData.getUint64(16, Endian.little);

      if (jsonManifestOffset + jsonManifestLength > length) {
        return null;
      }

      await raf.setPosition(jsonManifestOffset);
      final jsonBytes = await raf.read(jsonManifestLength);
      final jsonStr = utf8.decode(jsonBytes);
      final Map<String, dynamic> jsonMap = jsonDecode(jsonStr);

      return GsseManifest.fromJson(jsonMap);
    } catch (_) {
      return null;
    } finally {
      await raf.close();
    }
  }
}

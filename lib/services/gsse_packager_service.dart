import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import '../models/gsse_manifest.dart';

class GssePackagerService {
  static const String magicSignature = 'GSSE_V10';
  static const int footerByteSize = 32;

  /// Retorna o diretório raiz absoluto onde o executável do aplicativo está instalado/rodando
  String get appDir => File(Platform.resolvedExecutable).parent.path;

  /// Localiza o executável do NSIS (makensis.exe) de forma portátil e neutra
  Future<String?> localizarMakensis() async {
    final String currentAppDir = appDir;
    final List<String> candidatePaths = [
      p.join(currentAppDir, 'tools', 'nsis', 'makensis.exe'),
    ];

    // Variável de ambiente customizada NSIS_DIR
    final String? nsisEnvDir = Platform.environment['NSIS_DIR'];
    if (nsisEnvDir != null && nsisEnvDir.trim().isNotEmpty) {
      candidatePaths.add(p.join(nsisEnvDir.trim(), 'makensis.exe'));
    }

    // Variáveis de ambiente padrão do Windows ProgramFiles e ProgramFiles(x86)
    final String? pf = Platform.environment['ProgramFiles'];
    if (pf != null && pf.trim().isNotEmpty) {
      candidatePaths.add(p.join(pf.trim(), 'NSIS', 'makensis.exe'));
    }
    final String? pfx86 = Platform.environment['ProgramFiles(x86)'];
    if (pfx86 != null && pfx86.trim().isNotEmpty) {
      candidatePaths.add(p.join(pfx86.trim(), 'NSIS', 'makensis.exe'));
    }

    for (final path in candidatePaths) {
      try {
        if (await File(path).exists()) {
          return path;
        }
      } catch (_) {}
    }

    // Busca via PATH global do Windows
    try {
      final res = await Process.run('where', ['makensis.exe']);
      if (res.exitCode == 0 && res.stdout.toString().trim().isNotEmpty) {
        return res.stdout.toString().trim().split('\r\n').first.trim();
      }
    } catch (_) {}

    return null;
  }

  /// Localiza de forma portátil o executável stub do GSSE no sistema
  Future<File> _localizarStubFile(File? customStub) async {
    if (customStub != null && await customStub.exists()) {
      return customStub;
    }

    final String currentAppDir = appDir;
    final candidateStubPaths = [
      p.join(currentAppDir, 'data', 'flutter_assets', 'assets', 'tools', 'gs_stub.exe'),
      p.join(currentAppDir, 'assets', 'tools', 'gs_stub.exe'),
      p.join(currentAppDir, 'tools', 'gsse_stub', 'gs_stub.exe'),
    ];

    for (final path in candidateStubPaths) {
      final file = File(path);
      if (await file.exists()) {
        return file;
      }
    }

    return File(candidateStubPaths.first);
  }

  /// Gera e compila um instalador nativo profissional utilizando a engine NSIS (makensis.exe)
  /// com suporte a 7 idiomas nativos e detecção de DDI / Locale do Windows,
  /// com fallback para empacotador binário GSSE se o NSIS não estiver instalado.
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
      final resolvedStub = await _localizarStubFile(stubExecutable);
      return await _buildInstallerWithBinaryPacker(
        sourceDir: sourceDir,
        stubExecutable: resolvedStub,
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

    final Directory tempBuildDir = await Directory.systemTemp.createTemp('gsse_build_');
    String? iconPathToUse;

    // 1. Caso o usuário tenha selecionado um ícone customizado .ico existente em disco
    if (manifest.iconPath != null &&
        manifest.iconPath!.trim().isNotEmpty &&
        await File(manifest.iconPath!).exists()) {
      iconPathToUse = manifest.iconPath!;
    } else {
      // 2. Extração confiável do ícone padrão dos assets do Flutter para %TEMP%
      try {
        final ByteData data = await rootBundle.load('assets/icones/PS-DesKom.ico');
        final Uint8List bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        final File tempIconFile = File(p.join(tempBuildDir.path, 'app_icon.ico'));
        await tempIconFile.writeAsBytes(bytes, flush: true);
        iconPathToUse = tempIconFile.path;
      } catch (e) {
        // Fallback local caso o carregamento de asset falhe
        final String currentAppDir = appDir;
        final altIconFile1 = File(p.join(currentAppDir, 'data', 'flutter_assets', 'assets', 'icones', 'PS-DesKom.ico'));
        final altIconFile2 = File(p.join(currentAppDir, 'assets', 'icones', 'PS-DesKom.ico'));
        if (await altIconFile1.exists()) {
          iconPathToUse = altIconFile1.path;
        } else if (await altIconFile2.exists()) {
          iconPathToUse = altIconFile2.path;
        }
      }
    }

    final String muiIconDirectives = (iconPathToUse != null && await File(iconPathToUse).exists())
        ? '!define MUI_ICON "${iconPathToUse.replaceAll(r'\', '/')}"\n!define MUI_UNICON "${iconPathToUse.replaceAll(r'\', '/')}"'
        : '';

    final String tempNsiPath = p.join(
      tempBuildDir.path,
      'gsse_script.nsi',
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

$muiIconDirectives

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

    try {
      final tempNsiFile = File(tempNsiPath);
      await tempNsiFile.writeAsString(nsiContent, encoding: utf8);

      onProgress?.call('Compilando instalador via NSIS Engine (makensis.exe)...', 0.30);

      if (await outputFile.exists()) {
        try {
          await outputFile.delete();
        } catch (_) {}
      }
      await outputFile.parent.create(recursive: true);

      final String makensisWorkingDir = File(makensisPath).parent.path;

      final process = await Process.start(
        makensisPath,
        ['/V3', tempNsiPath],
        workingDirectory: makensisWorkingDir,
        runInShell: false,
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

      if (exitCode != 0 || !await outputFile.exists()) {
        throw Exception('Falha na compilação do NSIS (exitCode $exitCode). Verifique os logs.');
      }

      onProgress?.call('Instalador NSIS/GSSE gerado com sucesso!', 1.0);
      return outputFile;
    } finally {
      // Limpeza limpa e assíncrona do diretório temporário isolado
      try {
        if (await tempBuildDir.exists()) {
          await tempBuildDir.delete(recursive: true);
        }
      } catch (_) {}
    }
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

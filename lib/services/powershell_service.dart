import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import '../providers/commander_provider.dart';

class PowerShellService {
  Process? _processoAtivo;
  int _processCount = 0;

  Future<void> cancelarOperacaoAtiva() async {
    if (_processoAtivo != null) {
      final pid = _processoAtivo!.pid;
      try {
        _processoAtivo!.kill();
        await Process.run('taskkill', ['/F', '/T', '/PID', pid.toString()]);
      } catch (_) {}
      _processoAtivo = null;
    }
  }

  Future<String> executeScriptFile(String psScript) async {
    final tempDir = Directory.systemTemp;
    final tempFile = File(
      p.join(
        tempDir.path,
        'ps_deskom_script_${DateTime.now().millisecondsSinceEpoch}_${_processCount++}.ps1',
      ),
    );

    final utf8Bom = [0xEF, 0xBB, 0xBF];
    final scriptBytes = utf8.encode(psScript);
    await tempFile.writeAsBytes([...utf8Bom, ...scriptBytes]);

    try {
      final process = await Process.start(
        'powershell.exe',
        [
          '-NoProfile',
          '-ExecutionPolicy',
          'Bypass',
          '-File',
          tempFile.path,
        ],
        runInShell: true,
      );

      _processoAtivo = process;

      final List<int> stdoutBytes = [];
      final List<int> stderrBytes = [];

      process.stdout.listen((data) => stdoutBytes.addAll(data));
      process.stderr.listen((data) => stderrBytes.addAll(data));

      final exitCode = await process.exitCode;
      final stdout = utf8.decode(stdoutBytes, allowMalformed: true);
      final stderr = utf8.decode(stderrBytes, allowMalformed: true);

      if (exitCode == 0) {
        return stdout;
      } else {
        final errMessage = stderr.trim().isNotEmpty ? stderr.trim() : stdout.trim();
        throw Exception('Erro ao executar script PowerShell (exitCode $exitCode): $errMessage');
      }
    } finally {
      _processoAtivo = null;
      if (await tempFile.exists()) {
        try {
          await tempFile.delete();
        } catch (_) {}
      }
    }
  }

  Future<String?> detectarCaminhoGoogleDrive() async {
    final psScript = '''
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8;
\$drives = Get-PSDrive -PSProvider FileSystem | Where-Object { \$_.Description -match "Google" -or \$_.Name -eq "G" }
if (\$drives) {
    \$d = \$drives[0]
    \$root = \$d.Root
    if (Test-Path -LiteralPath (Join-Path \$root "Meu Drive")) {
        Write-Output (Join-Path \$root "Meu Drive")
        exit
    }
    if (Test-Path -LiteralPath (Join-Path \$root "My Drive")) {
        Write-Output (Join-Path \$root "My Drive")
        exit
    }
    Write-Output \$root
    exit
}

\$userProfile = \$env:USERPROFILE
\$paths = @(
    "\$userProfile\\Google Drive",
    "\$userProfile\\My Drive",
    "G:\\Meu Drive",
    "G:\\My Drive",
    "G:\\"
)

foreach (\$p in \$paths) {
    if (Test-Path -LiteralPath \$p) {
        Write-Output \$p
        exit
    }
}
''';

    try {
      final res = (await executeScriptFile(psScript)).trim();
      if (res.isNotEmpty && !res.startsWith('Erro') && !res.startsWith('Exceção')) {
        return res;
      }
    } catch (_) {}
    return null;
  }

  Future<String> execute(String command) async {
    try {
      final fullCommand = '[Console]::OutputEncoding = [System.Text.Encoding]::UTF8;\n$command';
      return await executeScriptFile(fullCommand);
    } catch (e) {
      return 'Exceção ao executar comando PowerShell: $e';
    }
  }

  Future<String> executeEncoded(String psScript) async {
    try {
      final fullScript = '[Console]::OutputEncoding = [System.Text.Encoding]::UTF8;\n$psScript';
      return await executeScriptFile(fullScript);
    } catch (e) {
      return 'Exceção ao executar script: $e';
    }
  }

  Future<String> descompactarArquivos({
    required List<String> arquivosOrigem,
    required String diretorioDestino,
    required bool criarSubpastaPorArquivo,
    void Function(int processados, int total, String arquivoAtual)? onProgresso,
  }) async {
    final StringBuffer logBuffer = StringBuffer();
    final total = arquivosOrigem.length;

    logBuffer.writeln('Iniciando descompactação de $total arquivo(s)...');
    logBuffer.writeln('Diretório Destino: $diretorioDestino\n');

    for (int i = 0; i < total; i++) {
      final filePath = arquivosOrigem[i];
      final fileName = p.basename(filePath);
      final fileNameWithoutExt = p.basenameWithoutExtension(filePath);

      final String targetDir = criarSubpastaPorArquivo
          ? p.join(diretorioDestino, fileNameWithoutExt)
          : diretorioDestino;

      onProgresso?.call(i + 1, total, fileName);

      logBuffer.writeln('[${i + 1}/$total] Extraindo "$fileName"...');

      final psScript = '''
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8;
\$src = '${filePath.replaceAll("'", "''")}'
\$dest = '${targetDir.replaceAll("'", "''")}'

if (-not (Test-Path -LiteralPath \$dest)) {
    New-Item -ItemType Directory -Force -Path \$dest | Out-Null
}

if (\$src -like "*.zip") {
    Expand-Archive -LiteralPath \$src -DestinationPath \$dest -Force
} else {
    if (Get-Command tar -ErrorAction SilentlyContinue) {
        tar -xf \$src -C \$dest
    } else {
        Expand-Archive -LiteralPath \$src -DestinationPath \$dest -Force
    }
}
Write-Output "Concluído: \$src -> \$dest"
''';

      final res = await executeScriptFile(psScript);
      logBuffer.writeln(res.trim());
      logBuffer.writeln('----------------------------------------');
    }

    logBuffer.writeln('Todas as extrações foram finalizadas.');
    return logBuffer.toString();
  }

  Future<String> copiarItens({
    required List<String> itensOrigem,
    required String diretorioDestino,
    required String regraColisao, // 'substituir', 'pular', 'manter'
    bool organizarNoDestino = false,
    void Function(int processados, int total, String itemAtual)? onProgresso,
  }) async {
    final StringBuffer logBuffer = StringBuffer();
    final total = itensOrigem.length;

    logBuffer.writeln('Iniciando cópia em lote de $total item(ns)...');
    logBuffer.writeln('Diretório Destino: $diretorioDestino');
    logBuffer.writeln('Regra de Colisão: $regraColisao');
    logBuffer.writeln('Organizar no Destino: $organizarNoDestino\n');

    for (int i = 0; i < total; i++) {
      final srcPath = itensOrigem[i];
      final itemName = p.basename(srcPath);

      onProgresso?.call(i + 1, total, itemName);

      logBuffer.writeln('[${i + 1}/$total] Copiando "$itemName"...');

      final escapedSrc = srcPath.replaceAll("'", "''");
      final escapedDest = diretorioDestino.replaceAll("'", "''");
      final escapedName = itemName.replaceAll("'", "''");

      String psScript;
      if (regraColisao == 'pular') {
        psScript = '''
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8;
\$src = '$escapedSrc'
\$destDir = '$escapedDest'
\$name = '$escapedName'
\$target = Join-Path \$destDir \$name

if (-not (Test-Path -LiteralPath \$destDir)) {
    New-Item -ItemType Directory -Force -Path \$destDir | Out-Null
}

if (Test-Path -LiteralPath \$target) {
    Write-Output "PULADO (já existe): \$target"
} else {
    Copy-Item -LiteralPath \$src -Destination \$target -Recurse -Force
    Write-Output "COPIADO: \$src -> \$target"
}
''';
      } else if (regraColisao == 'manter') {
        psScript = '''
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8;
\$src = '$escapedSrc'
\$destDir = '$escapedDest'
\$name = '$escapedName'
\$target = Join-Path \$destDir \$name

if (-not (Test-Path -LiteralPath \$destDir)) {
    New-Item -ItemType Directory -Force -Path \$destDir | Out-Null
}

if (Test-Path -LiteralPath \$target) {
    \$ext = [System.IO.Path]::GetExtension(\$name)
    \$base = [System.IO.Path]::GetFileNameWithoutExtension(\$name)
    \$count = 1
    do {
        \$newName = "\${base}_copia(\$count)\$ext"
        \$target = Join-Path \$destDir \$newName
        \$count++
    } while (Test-Path -LiteralPath \$target)
}

Copy-Item -LiteralPath \$src -Destination \$target -Recurse -Force
Write-Output "COPIADO (CÓPIA): \$src -> \$target"
''';
      } else {
        psScript = '''
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8;
\$src = '$escapedSrc'
\$destDir = '$escapedDest'
\$name = '$escapedName'
\$target = Join-Path \$destDir \$name

if (-not (Test-Path -LiteralPath \$destDir)) {
    New-Item -ItemType Directory -Force -Path \$destDir | Out-Null
}

Copy-Item -LiteralPath \$src -Destination \$target -Recurse -Force
Write-Output "COPIADO (SUBSTITUÍDO): \$src -> \$target"
''';
      }

      final res = await executeScriptFile(psScript);
      logBuffer.writeln(res.trim());
      logBuffer.writeln('----------------------------------------');
    }

    if (organizarNoDestino) {
      logBuffer.writeln('\nOrganizando arquivos copiados no destino...');
      final orgRes = await organizarDiretorio(
        diretorioRaiz: diretorioDestino,
        regras: {
          'Documentos PDF': ['.pdf'],
          'Word Doc': ['.doc', '.docx'],
          'Planilhas': ['.xlsx', '.xls', '.csv'],
          'Músicas': ['.mp3', '.wav', '.flac', '.m4a'],
          'Vídeos': ['.mp4', '.mkv', '.avi', '.mov'],
          'Imagens': ['.jpg', '.jpeg', '.png', '.gif', '.webp'],
          'Arquivos Compactados': ['.zip', '.rar', '.7z', '.tar', '.gz'],
          'Instaladores': ['.exe', '.msi'],
        },
      );
      logBuffer.writeln(orgRes);
    }

    logBuffer.writeln('Todas as cópias foram finalizadas.');
    return logBuffer.toString();
  }

  Future<String> moverItens({
    required List<String> itensOrigem,
    required String diretorioDestino,
    required bool sobrescreverExistentes,
    bool organizarNoDestino = false,
    void Function(int processados, int total, String itemAtual)? onProgresso,
  }) async {
    final StringBuffer logBuffer = StringBuffer();
    final total = itensOrigem.length;

    logBuffer.writeln('Iniciando movimentação em lote de $total item(ns)...');
    logBuffer.writeln('Diretório Destino: $diretorioDestino');
    logBuffer.writeln('Sobrescrever Existentes: $sobrescreverExistentes');
    logBuffer.writeln('Organizar no Destino: $organizarNoDestino\n');

    for (int i = 0; i < total; i++) {
      final srcPath = itensOrigem[i];
      final itemName = p.basename(srcPath);

      onProgresso?.call(i + 1, total, itemName);

      logBuffer.writeln('[${i + 1}/$total] Movendo "$itemName"...');

      final escapedSrc = srcPath.replaceAll("'", "''");
      final escapedDest = diretorioDestino.replaceAll("'", "''");
      final escapedName = itemName.replaceAll("'", "''");

      final psScript = '''
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8;
\$src = '$escapedSrc'
\$destDir = '$escapedDest'
\$name = '$escapedName'
\$target = Join-Path \$destDir \$name

if (-not (Test-Path -LiteralPath \$destDir)) {
    New-Item -ItemType Directory -Force -Path \$destDir | Out-Null
}

try {
    if ("$sobrescreverExistentes" -eq "true") {
        if (Test-Path -LiteralPath \$target) {
            Remove-Item -LiteralPath \$target -Recurse -Force -ErrorAction Stop
        }
        Move-Item -LiteralPath \$src -Destination \$target -Force -ErrorAction Stop
        Write-Output "MOVIDO (Sobrescrito): \$src -> \$target"
    } else {
        if (Test-Path -LiteralPath \$target) {
            Write-Output "PULADO (já existe no destino): \$target"
        } else {
            Move-Item -LiteralPath \$src -Destination \$target -ErrorAction Stop
            Write-Output "MOVIDO: \$src -> \$target"
        }
    }
} catch {
    Write-Output "ERRO ao mover '\$src': \$(\$_.Exception.Message)"
}
''';

      final res = await executeScriptFile(psScript);
      logBuffer.writeln(res.trim());
      logBuffer.writeln('----------------------------------------');
    }

    if (organizarNoDestino) {
      logBuffer.writeln('\nOrganizando arquivos movidos no destino...');
      final orgRes = await organizarDiretorio(
        diretorioRaiz: diretorioDestino,
        regras: {
          'Documentos PDF': ['.pdf'],
          'Word Doc': ['.doc', '.docx'],
          'Planilhas': ['.xlsx', '.xls', '.csv'],
          'Músicas': ['.mp3', '.wav', '.flac', '.m4a'],
          'Vídeos': ['.mp4', '.mkv', '.avi', '.mov'],
          'Imagens': ['.jpg', '.jpeg', '.png', '.gif', '.webp'],
          'Arquivos Compactados': ['.zip', '.rar', '.7z', '.tar', '.gz'],
          'Instaladores': ['.exe', '.msi'],
        },
      );
      logBuffer.writeln(orgRes);
    }

    logBuffer.writeln('Todas as movimentações foram finalizadas.');
    return logBuffer.toString();
  }

  Future<String> organizarDiretorio({
    required String diretorioRaiz,
    required Map<String, List<String>> regras,
    bool incluirSubpastas = false,
    void Function(int processados, int total, String categoriaAtual)? onProgresso,
  }) async {
    final StringBuffer logBuffer = StringBuffer();
    final entries = regras.entries.toList();
    final total = entries.length;

    logBuffer.writeln('Iniciando organização do diretório: $diretorioRaiz');
    logBuffer.writeln('Incluir Subpastas (Recursivo): $incluirSubpastas\n');

    final escapedRoot = diretorioRaiz.replaceAll("'", "''");

    for (int i = 0; i < total; i++) {
      final entry = entries[i];
      final nomeSubpasta = entry.key;
      final extensoes = entry.value.map((e) => e.toLowerCase()).toList();

      if (extensoes.isEmpty) continue;

      onProgresso?.call(i + 1, total, nomeSubpasta);

      logBuffer.writeln('[${i + 1}/$total] Processando Categoria "$nomeSubpasta" (${extensoes.join(', ')})...');

      final extensoesPs = extensoes.map((e) => "'$e'").join(', ');
      final recurseFlag = incluirSubpastas ? '-Recurse' : '';
      final escapedSubfolder = nomeSubpasta.replaceAll("'", "''");

      final psScript = '''
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8;
\$rootDir = '$escapedRoot'
\$targetDir = Join-Path \$rootDir '$escapedSubfolder'
\$exts = @($extensoesPs)

if (-not (Test-Path -LiteralPath \$targetDir)) {
    New-Item -ItemType Directory -Force -Path \$targetDir | Out-Null
}

\$files = Get-ChildItem -LiteralPath \$rootDir $recurseFlag -File -ErrorAction SilentlyContinue | Where-Object {
    \$_.DirectoryName -ne \$targetDir -and \$exts -contains \$_.Extension.ToLower()
}

\$count = 0
foreach (\$f in \$files) {
    try {
        \$dest = Join-Path \$targetDir \$f.Name
        if (-not (Test-Path -LiteralPath \$dest)) {
            Move-Item -LiteralPath \$f.FullName -Destination \$dest -Force -ErrorAction Stop
            \$count++
        }
    } catch {
        Write-Output "Erro ao mover '\$(\$f.Name)': \$(\$_.Exception.Message)"
    }
}

Write-Output "Organizados \$count arquivo(s) na pasta '$nomeSubpasta'."
''';

      final res = await executeScriptFile(psScript);
      logBuffer.writeln(res.trim());
      logBuffer.writeln('----------------------------------------');
    }

    logBuffer.writeln('Organização do diretório concluída.');
    return logBuffer.toString();
  }

  Future<String> organizarItensSelecionados({
    required List<String> caminhosArquivos,
    required String pastaDestinoBase,
  }) async {
    final StringBuffer logBuffer = StringBuffer();
    final total = caminhosArquivos.length;

    logBuffer.writeln('Organizando $total item(ns) selecionados para: $pastaDestinoBase\n');

    final extMap = {
      'Documentos PDF': ['.pdf'],
      'Word Doc': ['.doc', '.docx'],
      'Planilhas': ['.xlsx', '.xls', '.csv'],
      'Músicas': ['.mp3', '.wav', '.flac', '.m4a'],
      'Vídeos': ['.mp4', '.mkv', '.avi', '.mov'],
      'Imagens': ['.jpg', '.jpeg', '.png', '.gif', '.webp'],
      'Arquivos Compactados': ['.zip', '.rar', '.7z', '.tar', '.gz'],
      'Instaladores': ['.exe', '.msi'],
    };

    for (int i = 0; i < total; i++) {
      final src = caminhosArquivos[i];
      final ext = p.extension(src).toLowerCase();
      final fileName = p.basename(src);

      String targetSubfolder = 'Outros';
      extMap.forEach((categoria, exts) {
        if (exts.contains(ext)) {
          targetSubfolder = categoria;
        }
      });

      final targetDir = p.join(pastaDestinoBase, targetSubfolder);
      final escapedSrc = src.replaceAll("'", "''");
      final escapedTargetDir = targetDir.replaceAll("'", "''");
      final escapedFileName = fileName.replaceAll("'", "''");

      final psScript = '''
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8;
\$src = '$escapedSrc'
\$targetDir = '$escapedTargetDir'
\$fileName = '$escapedFileName'
\$dest = Join-Path \$targetDir \$fileName

if (-not (Test-Path -LiteralPath \$targetDir)) {
    New-Item -ItemType Directory -Force -Path \$targetDir | Out-Null
}

try {
    Move-Item -LiteralPath \$src -Destination \$dest -Force -ErrorAction Stop
    Write-Output "ORGANIZADO E MOVIDO: \$src -> \$dest"
} catch {
    Write-Output "ERRO ao mover '\$src': \$(\$_.Exception.Message)"
}
''';

      final res = await executeScriptFile(psScript);
      logBuffer.writeln(res.trim());
    }

    logBuffer.writeln('\nOrganização dos itens selecionados finalizada.');
    return logBuffer.toString();
  }

  Future<List<Map<String, dynamic>>> detectarDuplicados({
    required List<String> searchPaths,
    String categoriaFiltro = 'todos',
    bool includeSubfolders = true,
  }) async {
    if (searchPaths.isEmpty) return [];

    final pathsPs = searchPaths
        .map((path) => "'${path.replaceAll("'", "''")}'")
        .join(', ');
    final recurseFlag = includeSubfolders ? '-Recurse' : '';

    final psScript = '''
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8;
\$paths = @($pathsPs)
\$cat = "$categoriaFiltro"

\$extMap = @{
    'imagens'     = @('.jpg', '.jpeg', '.png', '.webp', '.bmp', '.gif')
    'videos'      = @('.mp4', '.mkv', '.avi', '.mov', '.wmv')
    'audios'      = @('.mp3', '.wav', '.flac', '.aac', '.m4a')
    'textos'      = @('.txt', '.log', '.json', '.csv', '.md', '.xml', '.pdf', '.docx')
    'instaladores'= @('.exe', '.msi', '.iso')
}

\$allFiles = @()
foreach (\$p in \$paths) {
    if (Test-Path -LiteralPath \$p) {
        \$allFiles += Get-ChildItem -LiteralPath \$p $recurseFlag -File -ErrorAction SilentlyContinue | Where-Object {
            if (\$cat -ne "todos" -and \$extMap.ContainsKey(\$cat)) {
                \$extMap[\$cat] -contains \$_.Extension.ToLower()
            } else {
                \$true
            }
        }
    }
}

if (\$null -eq \$allFiles -or \$allFiles.Count -eq 0) {
    Write-Output "[]"
    exit
}

# 1. Agrupar por tamanho em bytes
\$sizeGroups = \$allFiles | Group-Object Length | Where-Object { \$_.Count -gt 1 }

\$hashGroups = @{}
foreach (\$group in \$sizeGroups) {
    foreach (\$file in \$group.Group) {
        try {
            \$hash = (Get-FileHash -LiteralPath \$file.FullName -Algorithm SHA256 -ErrorAction Stop).Hash
            if (-not \$hashGroups.ContainsKey(\$hash)) {
                \$hashGroups[\$hash] = @()
            }
            \$hashGroups[\$hash] += \$file
        } catch {}
    }
}

function Get-MetadataObj(\$f) {
    \$verInfo = (Get-Item -LiteralPath \$f.FullName).VersionInfo
    return @{
        caminho = \$f.FullName
        nome = \$f.Name
        tamanho = \$f.Length
        modificado = \$f.LastWriteTime.ToString("o")
        fileVersion = if (\$verInfo -and \$verInfo.FileVersion) { \$verInfo.FileVersion } else { "" }
        productName = if (\$verInfo -and \$verInfo.ProductName) { \$verInfo.ProductName } else { "" }
        companyName = if (\$verInfo -and \$verInfo.CompanyName) { \$verInfo.CompanyName } else { "" }
    }
}

\$resultList = @()

# Conflitos de conteúdo 100% idêntico (mesmo SHA256)
foreach (\$kv in \$hashGroups.GetEnumerator()) {
    if (\$kv.Value.Count -gt 1) {
        \$fileList = @()
        foreach (\$f in \$kv.Value) {
            \$fileList += Get-MetadataObj \$f
        }
        \$resultList += @{
            tipo = "identical"
            hash = \$kv.Key
            arquivos = \$fileList
        }
    }
}

# Conflitos de mesmo nome mas hashes diferentes
\$nameGroups = \$allFiles | Group-Object Name | Where-Object { \$_.Count -gt 1 }
foreach (\$group in \$nameGroups) {
    \$filesInGroup = \$group.Group
    \$hashes = @()
    foreach (\$f in \$filesInGroup) {
        try {
            \$h = (Get-FileHash -LiteralPath \$f.FullName -Algorithm SHA256).Hash
            \$hashes += \$h
        } catch {}
    }
    \$uniqueHashes = \$hashes | Select-Object -Unique
    if (\$uniqueHashes.Count -gt 1) {
        \$fileList = @()
        foreach (\$f in \$filesInGroup) {
            \$fileList += Get-MetadataObj \$f
        }
        \$resultList += @{
            tipo = "same_name_different_content"
            hash = ""
            arquivos = \$fileList
        }
    }
}

ConvertTo-Json -InputObject \$resultList -Depth 4 -Compress
''';

    final output = await executeScriptFile(psScript);
    final raw = output.trim();
    if (raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return List<Map<String, dynamic>>.from(
          decoded.map((item) => Map<String, dynamic>.from(item)),
        );
      } else if (decoded is Map) {
        return [Map<String, dynamic>.from(decoded)];
      }
    } catch (_) {}

    return [];
  }

  Future<List<FoundFileInfo>> searchFiles({
    required List<String> searchPaths,
    required bool includeSubfolders,
    required String categoriaFiltro,
    required String nameQuery,
    required String sizeFilter,
  }) async {
    if (searchPaths.isEmpty) return [];

    final pathsPs = searchPaths
        .map((path) => "'${path.replaceAll("'", "''")}'")
        .join(', ');
    final recurseFlag = includeSubfolders ? '-Recurse' : '';

    final psScript = '''
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8;
\$paths = @($pathsPs)
\$cat = "$categoriaFiltro"
\$query = "$nameQuery"
\$sizeF = "$sizeFilter"

\$extMap = @{
    'imagens'     = @('.jpg', '.jpeg', '.png', '.webp', '.bmp', '.gif')
    'videos'      = @('.mp4', '.mkv', '.avi', '.mov', '.wmv')
    'audios'      = @('.mp3', '.wav', '.flac', '.aac', '.m4a')
    'textos'      = @('.txt', '.log', '.json', '.csv', '.md', '.xml', '.pdf', '.docx')
    'instaladores'= @('.exe', '.msi', '.iso')
}

\$files = @()
foreach (\$p in \$paths) {
    if (Test-Path -LiteralPath \$p) {
        \$files += Get-ChildItem -LiteralPath \$p $recurseFlag -File -ErrorAction SilentlyContinue
    }
}

\$filtered = \$files | Where-Object {
    \$item = \$_
    \$passCat = \$true
    if (\$cat -ne "todos" -and \$extMap.ContainsKey(\$cat)) {
        \$passCat = \$extMap[\$cat] -contains \$item.Extension.ToLower()
    }

    \$passName = \$true
    if (\$query -and \$query.Trim() -ne "") {
        \$passName = \$item.Name -like "*\$query*"
    }

    \$passSize = \$true
    \$len = \$item.Length
    if (\$sizeF -eq "< 10 MB") {
        \$passSize = \$len -lt 10MB
    } elseif (\$sizeF -eq "10-100 MB") {
        \$passSize = (\$len -ge 10MB) -and (\$len -le 100MB)
    } elseif (\$sizeF -eq "100 MB - 1 GB") {
        \$passSize = (\$len -gt 100MB) -and (\$len -le 1GB)
    } elseif (\$sizeF -eq "> 1 GB") {
        \$passSize = \$len -gt 1GB
    }

    \$passCat -and \$passName -and \$passSize
}

if (\$null -eq \$filtered -or \$filtered.Count -eq 0) {
    Write-Output "[]"
    exit
}

\$resultList = @()
foreach (\$f in \$filtered) {
    \$resultList += @{
        nome = \$f.Name
        caminho = \$f.FullName
        tamanho = \$f.Length
        extensao = \$f.Extension
        modificado = \$f.LastWriteTime.ToString("o")
    }
}

ConvertTo-Json -InputObject \$resultList -Depth 3 -Compress
''';

    final output = await executeScriptFile(psScript);
    final raw = output.trim();
    if (raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return List<FoundFileInfo>.from(
          decoded.map((item) => FoundFileInfo.fromMap(Map<String, dynamic>.from(item))),
        );
      } else if (decoded is Map) {
        return [FoundFileInfo.fromMap(Map<String, dynamic>.from(decoded))];
      }
    } catch (_) {}

    return [];
  }

  Future<bool> apagarArquivo(String caminho) async {
    try {
      final file = File(caminho);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      final escaped = caminho.replaceAll("'", "''");
      final script = "Remove-Item -LiteralPath '$escaped' -Force -ErrorAction Stop";
      final res = await executeScriptFile(script);
      return !res.startsWith('Erro');
    }
  }

  Future<bool> renomearArquivo(String caminhoOriginal, String novoNome) async {
    try {
      final file = File(caminhoOriginal);
      if (await file.exists()) {
        final dir = p.dirname(caminhoOriginal);
        final novoCaminho = p.join(dir, novoNome);
        await file.rename(novoCaminho);
        return true;
      }
      return false;
    } catch (e) {
      final escapedSrc = caminhoOriginal.replaceAll("'", "''");
      final escapedNew = novoNome.replaceAll("'", "''");
      final script = "Rename-Item -LiteralPath '$escapedSrc' -NewName '$escapedNew' -Force -ErrorAction Stop";
      final res = await executeScriptFile(script);
      return !res.startsWith('Erro');
    }
  }
}

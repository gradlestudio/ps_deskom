import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

class PowerShellService {
  Process? _processoAtivo;

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

  Future<String?> detectarCaminhoGoogleDrive() async {
    final psScript = '''
\$drives = Get-PSDrive -PSProvider FileSystem | Where-Object { \$_.Description -match "Google" -or \$_.Name -eq "G" }
if (\$drives) {
    \$d = \$drives[0]
    \$root = \$d.Root
    if (Test-Path (Join-Path \$root "Meu Drive")) {
        Write-Output (Join-Path \$root "Meu Drive")
        exit
    }
    if (Test-Path (Join-Path \$root "My Drive")) {
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
    if (Test-Path \$p) {
        Write-Output \$p
        exit
    }
}
''';

    final res = (await executeEncoded(psScript)).trim();
    if (res.isNotEmpty && !res.startsWith('Erro') && !res.startsWith('Exceção')) {
      return res;
    }
    return null;
  }

  Future<String> execute(String command) async {
    try {
      final fullCommand = '[Console]::OutputEncoding = [System.Text.Encoding]::UTF8;\n$command';
      final result = await Process.run(
        'powershell.exe',
        [
          '-NoProfile',
          '-ExecutionPolicy',
          'Bypass',
          '-Command',
          fullCommand,
        ],
        runInShell: true,
      );

      if (result.exitCode == 0) {
        return result.stdout.toString();
      } else {
        final stderr = result.stderr.toString().trim();
        final stdout = result.stdout.toString().trim();
        final errMessage = stderr.isNotEmpty ? stderr : stdout;
        return 'Erro na execução do PowerShell (Exit Code ${result.exitCode}):\n$errMessage';
      }
    } catch (e) {
      return 'Exceção ao executar comando PowerShell: $e';
    }
  }

  Future<String> executeEncoded(String psScript) async {
    try {
      final fullScript = '[Console]::OutputEncoding = [System.Text.Encoding]::UTF8;\n$psScript';
      final bytes = <int>[];
      for (final charCode in fullScript.codeUnits) {
        bytes.add(charCode & 0xFF);
        bytes.add((charCode >> 8) & 0xFF);
      }
      final encoded = base64.encode(bytes);

      final result = await Process.run(
        'powershell.exe',
        [
          '-NoProfile',
          '-ExecutionPolicy',
          'Bypass',
          '-EncodedCommand',
          encoded,
        ],
        runInShell: true,
      );

      if (result.exitCode == 0) {
        return result.stdout.toString();
      } else {
        final stderr = result.stderr.toString().trim();
        final stdout = result.stdout.toString().trim();
        final errMessage = stderr.isNotEmpty ? stderr : stdout;
        return 'Erro (Exit Code ${result.exitCode}): $errMessage';
      }
    } catch (e) {
      return 'Exceção ao executar comando codificado: $e';
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
\$src = "$filePath"
\$dest = "$targetDir"

if (-not (Test-Path -Path \$dest)) {
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

      final res = await executeEncoded(psScript);
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

      String psScript;
      if (regraColisao == 'pular') {
        psScript = '''
\$src = "$srcPath"
\$destDir = "$diretorioDestino"
\$name = "$itemName"
\$target = Join-Path \$destDir \$name

if (-not (Test-Path -Path \$destDir)) {
    New-Item -ItemType Directory -Force -Path \$destDir | Out-Null
}

if (Test-Path -Path \$target) {
    Write-Output "PULADO (já existe): \$target"
} else {
    Copy-Item -Path \$src -Destination \$target -Recurse -Force
    Write-Output "COPIADO: \$src -> \$target"
}
''';
      } else if (regraColisao == 'manter') {
        psScript = '''
\$src = "$srcPath"
\$destDir = "$diretorioDestino"
\$name = "$itemName"
\$target = Join-Path \$destDir \$name

if (-not (Test-Path -Path \$destDir)) {
    New-Item -ItemType Directory -Force -Path \$destDir | Out-Null
}

if (Test-Path -Path \$target) {
    \$ext = [System.IO.Path]::GetExtension(\$name)
    \$base = [System.IO.Path]::GetFileNameWithoutExtension(\$name)
    \$count = 1
    do {
        \$newName = "\${base}_copia(\$count)\$ext"
        \$target = Join-Path \$destDir \$newName
        \$count++
    } while (Test-Path -Path \$target)
}

Copy-Item -Path \$src -Destination \$target -Recurse -Force
Write-Output "COPIADO (CÓPIA): \$src -> \$target"
''';
      } else {
        // Default: 'substituir'
        psScript = '''
\$src = "$srcPath"
\$destDir = "$diretorioDestino"
\$name = "$itemName"
\$target = Join-Path \$destDir \$name

if (-not (Test-Path -Path \$destDir)) {
    New-Item -ItemType Directory -Force -Path \$destDir | Out-Null
}

Copy-Item -Path \$src -Destination \$target -Recurse -Force
Write-Output "COPIADO (SUBSTITUÍDO): \$src -> \$target"
''';
      }

      final res = await executeEncoded(psScript);
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

      final psScript = '''
\$src = "$srcPath"
\$destDir = "$diretorioDestino"
\$name = "$itemName"
\$target = Join-Path \$destDir \$name

if (-not (Test-Path -Path \$destDir)) {
    New-Item -ItemType Directory -Force -Path \$destDir | Out-Null
}

try {
    if ("$sobrescreverExistentes" -eq "true") {
        if (Test-Path -Path \$target) {
            Remove-Item -Path \$target -Recurse -Force -ErrorAction Stop
        }
        Move-Item -Path \$src -Destination \$target -Force -ErrorAction Stop
        Write-Output "MOVIDO (Sobrescrito): \$src -> \$target"
    } else {
        if (Test-Path -Path \$target) {
            Write-Output "PULADO (já existe no destino): \$target"
        } else {
            Move-Item -Path \$src -Destination \$target -ErrorAction Stop
            Write-Output "MOVIDO: \$src -> \$target"
        }
    }
} catch {
    Write-Output "ERRO ao mover '\$src': \$(\$_.Exception.Message)"
}
''';

      final res = await executeEncoded(psScript);
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

    for (int i = 0; i < total; i++) {
      final entry = entries[i];
      final nomeSubpasta = entry.key;
      final extensoes = entry.value.map((e) => e.toLowerCase()).toList();

      if (extensoes.isEmpty) continue;

      onProgresso?.call(i + 1, total, nomeSubpasta);

      logBuffer.writeln('[${i + 1}/$total] Processando Categoria "$nomeSubpasta" (${extensoes.join(', ')})...');

      final extensoesPs = extensoes.map((e) => "'$e'").join(', ');
      final recurseFlag = incluirSubpastas ? '-Recurse' : '';

      final psScript = '''
\$rootDir = "$diretorioRaiz"
\$targetDir = Join-Path \$rootDir "$nomeSubpasta"
\$exts = @($extensoesPs)

if (-not (Test-Path -Path \$targetDir)) {
    New-Item -ItemType Directory -Force -Path \$targetDir | Out-Null
}

\$files = Get-ChildItem -Path \$rootDir $recurseFlag -File -ErrorAction SilentlyContinue | Where-Object {
    \$_.DirectoryName -ne \$targetDir -and \$exts -contains \$_.Extension.ToLower()
}

\$count = 0
foreach (\$f in \$files) {
    try {
        \$dest = Join-Path \$targetDir \$f.Name
        if (-not (Test-Path -Path \$dest)) {
            Move-Item -LiteralPath \$f.FullName -Destination \$dest -Force -ErrorAction Stop
            \$count++
        }
    } catch {
        Write-Output "Erro ao mover '\$(\$f.Name)': \$(\$_.Exception.Message)"
    }
}

Write-Output "Organizados \$count arquivo(s) na pasta '$nomeSubpasta'."
''';

      final res = await executeEncoded(psScript);
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

      final psScript = '''
\$src = "$src"
\$targetDir = "$targetDir"
\$fileName = "$fileName"
\$dest = Join-Path \$targetDir \$fileName

if (-not (Test-Path -Path \$targetDir)) {
    New-Item -ItemType Directory -Force -Path \$targetDir | Out-Null
}

try {
    Move-Item -LiteralPath \$src -Destination \$dest -Force -ErrorAction Stop
    Write-Output "ORGANIZADO E MOVIDO: \$src -> \$dest"
} catch {
    Write-Output "ERRO ao mover '\$src': \$(\$_.Exception.Message)"
}
''';

      final res = await executeEncoded(psScript);
      logBuffer.writeln(res.trim());
    }

    logBuffer.writeln('\nOrganização dos itens selecionados finalizada.');
    return logBuffer.toString();
  }

  Future<List<Map<String, dynamic>>> detectarDuplicados({
    required String diretorioRaiz,
    String categoriaFiltro = 'todos',
  }) async {
    final psScript = '''
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8;
\$rootDir = "$diretorioRaiz"
\$cat = "$categoriaFiltro"

\$extMap = @{
    'imagens'     = @('.jpg', '.jpeg', '.png', '.webp', '.bmp', '.gif')
    'videos'      = @('.mp4', '.mkv', '.avi', '.mov', '.wmv')
    'audios'      = @('.mp3', '.wav', '.flac', '.aac', '.m4a')
    'textos'      = @('.txt', '.log', '.json', '.csv', '.md', '.xml', '.pdf', '.docx')
    'instaladores'= @('.exe', '.msi', '.iso')
}

\$allFiles = Get-ChildItem -Path \$rootDir -Recurse -File -ErrorAction SilentlyContinue | Where-Object {
    if (\$cat -ne "todos" -and \$extMap.ContainsKey(\$cat)) {
        \$extMap[\$cat] -contains \$_.Extension.ToLower()
    } else {
        \$true
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
    \$verInfo = (Get-Item \$f.FullName).VersionInfo
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

    final bytes = <int>[];
    for (final charCode in psScript.codeUnits) {
      bytes.add(charCode & 0xFF);
      bytes.add((charCode >> 8) & 0xFF);
    }
    final encoded = base64.encode(bytes);

    try {
      final process = await Process.start(
        'powershell.exe',
        [
          '-NoProfile',
          '-ExecutionPolicy',
          'Bypass',
          '-EncodedCommand',
          encoded,
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
        final raw = stdout.trim();
        if (raw.isEmpty) return [];

        final decoded = jsonDecode(raw);
        if (decoded is List) {
          return List<Map<String, dynamic>>.from(
            decoded.map((item) => Map<String, dynamic>.from(item)),
          );
        } else if (decoded is Map) {
          return [Map<String, dynamic>.from(decoded)];
        }
      } else {
        throw Exception('Processo interrompido ou encerrado (exitCode $exitCode): $stderr');
      }
    } catch (e) {
      rethrow;
    } finally {
      _processoAtivo = null;
    }

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
      final script = 'Remove-Item -LiteralPath "$caminho" -Force -ErrorAction Stop';
      final res = await executeEncoded(script);
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
      final script = 'Rename-Item -LiteralPath "$caminhoOriginal" -NewName "$novoNome" -Force -ErrorAction Stop';
      final res = await executeEncoded(script);
      return !res.startsWith('Erro');
    }
  }
}

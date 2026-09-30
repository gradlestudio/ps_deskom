import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class ManualHelpDialog extends StatelessWidget {
  const ManualHelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DefaultTabController(
      length: 4,
      child: Dialog(
        backgroundColor: const Color(0xFF161616),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFF3F3F46)),
        ),
        child: Container(
          width: 720,
          height: 540,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cabeçalho
              Row(
                children: [
                  const Icon(Icons.menu_book_outlined,
                      color: Color(0xFF0078D4), size: 28),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n?.manualTitulo ?? 'PS DesKom — Manual & Guia Rápido',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n?.manualSubtitulo ?? 'Instruções operacionais e boas práticas de gerenciamento de arquivos.',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Aba de Navegação (TabBar)
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFF3F3F46), width: 1),
                  ),
                ),
                child: TabBar(
                  isScrollable: true,
                  labelColor: const Color(0xFF0078D4),
                  unselectedLabelColor: const Color(0xFF888888),
                  indicatorColor: const Color(0xFF0078D4),
                  indicatorWeight: 2,
                  tabs: [
                    Tab(text: l10n?.abaModulos ?? '1. Módulos do Sistema'),
                    Tab(text: l10n?.abaDuplicados ?? '2. Duplicados & Mídia'),
                    Tab(text: l10n?.abaNuvem ?? '3. Dicas & Nuvem'),
                    Tab(text: l10n?.abaSuporte ?? '4. Suporte & Licença'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Área de Conteúdo (TabBarView)
              Expanded(
                child: TabBarView(
                  children: [
                    _buildTabModulo(l10n),
                    _buildTabDuplicados(l10n),
                    _buildTabNuvem(l10n),
                    _buildTabSuporte(l10n),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Rodapé
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0078D4),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    child: Text(l10n?.fecharManual ?? 'Fechar Manual'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabModulo(AppLocalizations? l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SecaoTitulo(titulo: l10n?.mod1Titulo ?? 'Módulo 1: DESCOMPACTAR'),
          _ItemTexto(
            texto: l10n?.mod1Desc ??
                'Extrai arquivos compactados (.zip, .rar, .7z, .tar) em lote via PowerShell nativo. Ative a opção "Criar pasta com o nome do arquivo" para manter o destino limpo.',
          ),
          const SizedBox(height: 12),
          _SecaoTitulo(titulo: l10n?.mod2Titulo ?? 'Módulo 2: COPIAR'),
          _ItemTexto(
            texto: l10n?.mod2Desc ??
                'Copia arquivos ou pastas completas para o destino configurado com regras de colisão personalizáveis: Substituir, Pular duplicados ou Manter Ambos (renomear).',
          ),
          const SizedBox(height: 12),
          _SecaoTitulo(titulo: l10n?.mod3Titulo ?? 'Módulo 3: MOVER'),
          _ItemTexto(
            texto: l10n?.mod3Desc ??
                'Transfere itens no mesmo disco ou entre volumes. Suporta opção de sobrescrever arquivos existentes e tratamento de erros de permissão no Windows.',
          ),
          const SizedBox(height: 12),
          _SecaoTitulo(titulo: l10n?.mod4Titulo ?? 'Módulo 4: ORGANIZAR'),
          _ItemTexto(
            texto: l10n?.mod4Desc ??
                'Classifica automaticamente arquivos soltos em subpastas temáticas (Documentos PDF, Músicas, Imagens, Vídeos, Instaladores, etc.). Permite criar regras customizadas por extensão.',
          ),
          const SizedBox(height: 12),
          _SecaoTitulo(titulo: l10n?.mod5Titulo ?? 'Módulo 5: PROCURAR'),
          _ItemTexto(
            texto: l10n?.mod5Desc ??
                'Varre diretórios em busca de arquivos duplicados via hash binário SHA-256 e arquivos com mesmo nome. Oferece painel de comparação lado a lado.',
          ),
        ],
      ),
    );
  }

  Widget _buildTabDuplicados(AppLocalizations? l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SecaoTitulo(titulo: l10n?.sha256Titulo ?? 'Análise Criptográfica SHA-256'),
          _ItemTexto(
            texto: l10n?.sha256Desc ??
                'A varredura realiza uma triagem prévia por tamanho de arquivo e em seguida calcula o hash SHA-256 dos conteúdos para garantir 100% de certeza ao identificar duplicados idênticos.',
          ),
          const SizedBox(height: 12),
          _SecaoTitulo(titulo: l10n?.audioTitulo ?? 'Reprodutor de Áudio Integrado'),
          _ItemTexto(
            texto: l10n?.audioDesc ??
                'Arquivos de áudio (.mp3, .wav, .flac, .aac, .m4a) possuem pré-visualizador próprio nos cards de comparação com slider de progresso, botão play/pause e mute instantâneo.',
          ),
          const SizedBox(height: 12),
          _SecaoTitulo(titulo: l10n?.videoTitulo ?? 'Execução de Vídeos e Arquivos'),
          _ItemTexto(
            texto: l10n?.videoDesc ??
                'Mídias de vídeo e executáveis contêm botão de ação rápida "Abrir no Player Padrão", permitindo visualizar a mídia no reprodutor nativo do Windows em 0ms.',
          ),
          const SizedBox(height: 12),
          _SecaoTitulo(titulo: l10n?.buscaSeguraTitulo ?? 'Interrupção Segura de Busca'),
          _ItemTexto(
            texto: l10n?.buscaSeguraDesc ??
                'A qualquer momento durante uma varredura longa, clique em "INTERROMPER BUSCA". O processo em segundo plano será encerrado com segurança via taskkill sem travar o app.',
          ),
        ],
      ),
    );
  }

  Widget _buildTabNuvem(AppLocalizations? l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SecaoTitulo(titulo: l10n?.driveTitulo ?? 'Integração com Google Drive Desktop'),
          _ItemTexto(
            texto: l10n?.driveDesc ??
                'Se o aplicativo Google Drive Desktop estiver instalado no Windows, o PS DesKom detectará a unidade automaticamente e exibirá o botão "Google Drive" nos seletores de destino.',
          ),
          const SizedBox(height: 12),
          _SecaoTitulo(titulo: l10n?.pipelinesTitulo ?? 'Pipelines Combinados (Transferir + Organizar)'),
          _ItemTexto(
            texto: l10n?.pipelinesDesc ??
                'Nos módulos Copiar e Mover, marque a caixa "Organizar automaticamente por categorias no destino". Os arquivos serão transferidos e imediatamente classificados nas subpastas adequadas.',
          ),
          const SizedBox(height: 12),
          _SecaoTitulo(titulo: l10n?.otimizacaoTitulo ?? 'Otimização para Discos e Redes'),
          _ItemTexto(
            texto: l10n?.otimizacaoDesc ??
                'A engine opera diretamente sobre o Windows PowerShell Core codificado em UTF-16LE EncodedCommand, garantindo alta performance mesmo ao manipular grandes volumes em NAS ou HDs externos.',
          ),
        ],
      ),
    );
  }

  Widget _buildTabSuporte(AppLocalizations? l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SecaoTitulo(titulo: l10n?.licencaHwidTitulo ?? 'Licença Offline por HWID'),
          _ItemTexto(
            texto: l10n?.licencaHwidDesc ??
                'O PS DesKom é ativado utilizando o identificador único do seu computador (HWID). Uma vez ativada, a licença é permanente e não requer conexão constante com a internet.',
          ),
          const SizedBox(height: 12),
          _SecaoTitulo(titulo: l10n?.atualizacoesTitulo ?? 'Atualizações Vitalícias Incluídas'),
          _ItemTexto(
            texto: l10n?.atualizacoesDesc ??
                'Todas as novas versões e melhorias disponibilizadas pela Gradle Studio no repositório oficial estão inclusas gratuitamente para os clientes licenciados.',
          ),
          const SizedBox(height: 12),
          _SecaoTitulo(titulo: l10n?.canaisSuporteTitulo ?? 'Canais Oficiais de Suporte'),
          const _ItemTexto(
            texto:
                '• WhatsApp: +55 (85) 99642-1006\n• E-mail: gradlestudio.dev@gmail.com\n• Instagram: @gradlestudio.dev\n\nEquipe Técnica Gradle Studio — Fortaleza/CE',
          ),
        ],
      ),
    );
  }
}

class _SecaoTitulo extends StatelessWidget {
  final String titulo;
  const _SecaoTitulo({required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Text(
      titulo,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Color(0xFF4EC9B0),
      ),
    );
  }
}

class _ItemTexto extends StatelessWidget {
  final String texto;
  const _ItemTexto({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFFCCCCCC),
          height: 1.4,
        ),
      ),
    );
  }
}

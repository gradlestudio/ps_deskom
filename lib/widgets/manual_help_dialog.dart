import 'package:flutter/material.dart';

class ManualHelpDialog extends StatelessWidget {
  const ManualHelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
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
                    children: const [
                      Text(
                        'PS DesKom — Manual & Guia Rápido',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Instruções operacionais e boas práticas de gerenciamento de arquivos.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
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
                child: const TabBar(
                  isScrollable: true,
                  labelColor: Color(0xFF0078D4),
                  unselectedLabelColor: Color(0xFF888888),
                  indicatorColor: Color(0xFF0078D4),
                  indicatorWeight: 2,
                  tabs: [
                    Tab(text: '1. Módulos do Sistema'),
                    Tab(text: '2. Duplicados & Mídia'),
                    Tab(text: '3. Dicas & Nuvem'),
                    Tab(text: '4. Suporte & Licença'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Área de Conteúdo (TabBarView)
              Expanded(
                child: TabBarView(
                  children: [
                    _buildTabModulo(),
                    _buildTabDuplicados(),
                    _buildTabNuvem(),
                    _buildTabSuporte(),
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
                    child: const Text('Fechar Manual'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabModulo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _SecaoTitulo(titulo: 'Módulo 1: DESCOMPACTAR'),
          _ItemTexto(
            texto:
                'Extrai arquivos compactados (.zip, .rar, .7z, .tar) em lote via PowerShell nativo. Ative a opção "Criar pasta com o nome do arquivo" para manter o destino limpo.',
          ),
          SizedBox(height: 12),
          _SecaoTitulo(titulo: 'Módulo 2: COPIAR'),
          _ItemTexto(
            texto:
                'Copia arquivos ou pastas completas para o destino configurado com regras de colisão personalizáveis: Substituir, Pular duplicados ou Manter Ambos (renomear).',
          ),
          SizedBox(height: 12),
          _SecaoTitulo(titulo: 'Módulo 3: MOVER'),
          _ItemTexto(
            texto:
                'Transfere itens no mesmo disco ou entre volumes. Suporta opção de sobrescrever arquivos existentes e tratamento de erros de permissão no Windows.',
          ),
          SizedBox(height: 12),
          _SecaoTitulo(titulo: 'Módulo 4: ORGANIZAR'),
          _ItemTexto(
            texto:
                'Classifica automaticamente arquivos soltos em subpastas temáticas (Documentos PDF, Músicas, Imagens, Vídeos, Instaladores, etc.). Permite criar regras customizadas por extensão.',
          ),
          SizedBox(height: 12),
          _SecaoTitulo(titulo: 'Módulo 5: PROCURAR'),
          _ItemTexto(
            texto:
                'Varre diretórios em busca de arquivos duplicados via hash binário SHA-256 e arquivos com mesmo nome. Oferece painel de comparação lado a lado.',
          ),
        ],
      ),
    );
  }

  Widget _buildTabDuplicados() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _SecaoTitulo(titulo: 'Análise Criptográfica SHA-256'),
          _ItemTexto(
            texto:
                'A varredura realiza uma triagem prévia por tamanho de arquivo e em seguida calcula o hash SHA-256 dos conteúdos para garantir 100% de certeza ao identificar duplicados idênticos.',
          ),
          SizedBox(height: 12),
          _SecaoTitulo(titulo: 'Reprodutor de Áudio Integrado'),
          _ItemTexto(
            texto:
                'Arquivos de áudio (.mp3, .wav, .flac, .aac, .m4a) possuem pré-visualizador próprio nos cards de comparação com slider de progresso, botão play/pause e mute instantâneo.',
          ),
          SizedBox(height: 12),
          _SecaoTitulo(titulo: 'Execução de Vídeos e Arquivos'),
          _ItemTexto(
            texto:
                'Mídias de vídeo e executáveis contêm botão de ação rápida "Abrir no Player Padrão", permitindo visualizar a mídia no reprodutor nativo do Windows em 0ms.',
          ),
          SizedBox(height: 12),
          _SecaoTitulo(titulo: 'Interrupção Segura de Busca'),
          _ItemTexto(
            texto:
                'A qualquer momento durante uma varredura longa, clique em "INTERROMPER BUSCA". O processo em segundo plano será encerrado com segurança via taskkill sem travar o app.',
          ),
        ],
      ),
    );
  }

  Widget _buildTabNuvem() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _SecaoTitulo(titulo: 'Integração com Google Drive Desktop'),
          _ItemTexto(
            texto:
                'Se o aplicativo Google Drive Desktop estiver instalado no Windows, o PS DesKom detectará a unidade automaticamente e exibirá o botão "Google Drive" nos seletores de destino.',
          ),
          SizedBox(height: 12),
          _SecaoTitulo(titulo: 'Pipelines Combinados (Transferir + Organizar)'),
          _ItemTexto(
            texto:
                'Nos módulos Copiar e Mover, marque a caixa "Organizar automaticamente por categorias no destino". Os arquivos serão transferidos e imediatamente classificados nas subpastas adequadas.',
          ),
          SizedBox(height: 12),
          _SecaoTitulo(titulo: 'Otimização para Discos e Redes'),
          _ItemTexto(
            texto:
                'A engine opera diretamente sobre o Windows PowerShell Core codificado em UTF-16LE EncodedCommand, garantindo alta performance mesmo ao manipular grandes volumes em NAS ou HDs externos.',
          ),
        ],
      ),
    );
  }

  Widget _buildTabSuporte() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _SecaoTitulo(titulo: 'Licença Offline por HWID'),
          _ItemTexto(
            texto:
                'O PS DesKom é ativado utilizando o identificador único do seu computador (HWID). Uma vez ativada, a licença é permanente e não requer conexão constante com a internet.',
          ),
          SizedBox(height: 12),
          _SecaoTitulo(titulo: 'Atualizações Vitalícias Incluídas'),
          _ItemTexto(
            texto:
                'Todas as novas versões e melhorias disponibilizadas pela Gradle Studio no repositório oficial estão inclusas gratuitamente para os clientes licenciados.',
          ),
          SizedBox(height: 12),
          _SecaoTitulo(titulo: 'Canais Oficiais de Suporte'),
          _ItemTexto(
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

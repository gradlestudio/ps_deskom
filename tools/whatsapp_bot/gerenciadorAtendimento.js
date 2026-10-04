import { MENUS_ATENDIMENTO } from './fluxoAtendimento.js';

const SESSION_TIMEOUT_MS = 20 * 60 * 1000; // 20 Minutos
const ADMIN_NOTIFICATION_TARGETS = [
  '5585997829657@s.whatsapp.net',
  '558597829657@s.whatsapp.net',
];

class GerenciadorAtendimento {
  constructor() {
    this.sessoes = new Map();
  }

  _getSessao(sender) {
    const agora = Date.now();
    let sessao = this.sessoes.get(sender);
    let isNovaSessao = false;

    if (sessao) {
      if (agora - sessao.lastInteraction > SESSION_TIMEOUT_MS) {
        this.sessoes.delete(sender);
        sessao = null;
      } else {
        sessao.lastInteraction = agora;
      }
    }

    if (!sessao) {
      isNovaSessao = true;
      sessao = {
        etapa: 'MENU_INICIAL',
        tipoPessoa: null,
        setor: null,
        descricao: null,
        lastInteraction: agora
      };
      this.sessoes.set(sender, sessao);
    }

    return { sessao, isNovaSessao };
  }

  _reiniciarSessao(sender) {
    this.sessoes.delete(sender);
  }

  async processarMensagem(socket, sender, texto, lang = 'PT') {
    const { sessao, isNovaSessao } = this._getSessao(sender);
    const t = MENUS_ATENDIMENTO[lang] || MENUS_ATENDIMENTO.PT;
    const inputClean = texto.trim().toLowerCase();

    // Se é uma nova sessão (primeira mensagem do contato ou sessão expirada)
    if (isNovaSessao) {
      if (inputClean === '1') {
        sessao.etapa = 'TIPO_PESSOA';
        await socket.sendMessage(sender, { text: t.menuTipoPessoa });
        return;
      } else if (inputClean === '2') {
        await socket.sendMessage(sender, { text: t.opcaoOutrosServicos });
        return;
      } else if (inputClean === '3') {
        sessao.etapa = 'ATENDIMENTO_HUMANO';
        await socket.sendMessage(sender, { text: t.transfereAtendimento });
        return;
      } else {
        // Envia EXCLUSIVAMENTE o menu inicial de acolhimento sem o alerta de opção inválida
        await socket.sendMessage(sender, { text: t.menuInicial });
        return;
      }
    }

    // Opção de retorno ao menu principal
    if (inputClean === '0' || inputClean === 'menu' || inputClean === 'inicio') {
      sessao.etapa = 'MENU_INICIAL';
      await socket.sendMessage(sender, { text: t.menuInicial });
      return;
    }

    switch (sessao.etapa) {
      case 'MENU_INICIAL': {
        if (inputClean === '1') {
          sessao.etapa = 'TIPO_PESSOA';
          await socket.sendMessage(sender, { text: t.menuTipoPessoa });
        } else if (inputClean === '2') {
          await socket.sendMessage(sender, { text: t.opcaoOutrosServicos });
        } else if (inputClean === '3') {
          sessao.etapa = 'ATENDIMENTO_HUMANO';
          await socket.sendMessage(sender, { text: t.transfereAtendimento });
        } else {
          await socket.sendMessage(sender, { text: `${t.opcaoInvalida}\n\n${t.menuInicial}` });
        }
        break;
      }

      case 'TIPO_PESSOA': {
        if (inputClean === '1') {
          sessao.tipoPessoa = 'Pessoa Jurídica (PJ)';
          sessao.etapa = 'SETOR';
          await socket.sendMessage(sender, { text: t.menuSetor });
        } else if (inputClean === '2') {
          sessao.tipoPessoa = 'Pessoa Física (PF)';
          sessao.etapa = 'SETOR';
          await socket.sendMessage(sender, { text: t.menuSetor });
        } else {
          await socket.sendMessage(sender, { text: `${t.opcaoInvalida}\n\n${t.menuTipoPessoa}` });
        }
        break;
      }

      case 'SETOR': {
        const opcaoNum = parseInt(inputClean, 10);
        const setoresMap = {
          1: 'Alimentação / Delivery',
          2: 'Automotivo',
          3: 'Escritório / Corporativo',
          4: 'Comércio Atacado / Varejo',
          5: 'Logística / Rastreio',
          6: 'Developer / Engenharia de Software',
          7: 'Outros Setores'
        };

        if (opcaoNum >= 1 && opcaoNum <= 7) {
          sessao.setor = setoresMap[opcaoNum];
          sessao.etapa = 'DESCRICAO';

          const resumo = t.resumoSetor[opcaoNum] || '';
          const msgSetor = `${resumo}\n\n${t.solicitarDescricao}`;
          await socket.sendMessage(sender, { text: msgSetor });
        } else {
          await socket.sendMessage(sender, { text: `${t.opcaoInvalida}\n\n${t.menuSetor}` });
        }
        break;
      }

      case 'DESCRICAO': {
        sessao.descricao = texto.trim();

        // Encerramento para o cliente
        await socket.sendMessage(sender, { text: t.encerramentoLead });

        // Notificação formatada para o Administrador
        const cleanJid = (sender || '').split('@')[0].split(':')[0];
        const clientePhone = cleanJid.replace(/[^0-9]/g, '');
        const notificacaoAdmin =
`🔔 *Novo Lead Qualificado — Gradle Studio*

• *Cliente:* +${clientePhone}
• *Perfil:* ${sessao.tipoPessoa || 'Não especificado'}
• *Setor de Interesse:* ${sessao.setor || 'Geral'}
• *Descrição da Demanda:*
"${sessao.descricao}"

_Horário: ${new Date().toLocaleString('pt-BR', { timeZone: 'America/Fortaleza' })}_`;

        // Dispara notificação para todos os JIDs configurados para o administrador
        for (const targetJid of ADMIN_NOTIFICATION_TARGETS) {
          try {
            await socket.sendMessage(targetJid, { text: notificacaoAdmin });
            console.log(`  [NOTIFICAÇÃO DE LEAD ENVIADA AO ADMIN (${targetJid})]`);
          } catch (err) {
            console.error(`  [ERRO AO ENVIAR NOTIFICAÇÃO DE LEAD AO ADMIN (${targetJid})]:`, err.message);
          }
        }

        // Reinicia sessão após qualificação completa
        this._reiniciarSessao(sender);
        break;
      }

      case 'ATENDIMENTO_HUMANO': {
        // Se já está em atendimento humano, não interfere a menos que digite '0' ou 'menu'
        break;
      }

      default: {
        sessao.etapa = 'MENU_INICIAL';
        await socket.sendMessage(sender, { text: t.menuInicial });
        break;
      }
    }
  }
}

export const gerenciadorAtendimento = new GerenciadorAtendimento();

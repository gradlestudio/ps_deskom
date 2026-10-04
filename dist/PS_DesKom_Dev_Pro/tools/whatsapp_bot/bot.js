import {
  makeWASocket,
  useMultiFileAuthState,
  DisconnectReason,
} from '@whiskeysockets/baileys';
import qrcode from 'qrcode-terminal';
import crypto from 'crypto';
import pino from 'pino';
import { gerenciadorAtendimento } from './gerenciadorAtendimento.js';

const SECRET_SALT = 'GRADLE-STUDIO-2026-SECRET';
const HWID_REGEX = /DESK-(?:[A-Z0-9]+-)*[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}/i;

const ADMIN_NUMBERS = [
  '5585996421006@s.whatsapp.net', // Gradle Studio Suporte
  '5585997829657@s.whatsapp.net', // Número Pessoal do Desenvolvedor
];

const TEMPLATES_COMERCIAIS = {
  PT: {
    title: '🔐 *Ativação PS DesKom — Gradle Studio*',
    device: 'Identificamos sua solicitação de licença para o dispositivo:',
    hwid: '💻 *HWID:*',
    keyTitle: 'Sua Chave de Licença Comercial é:',
    tip: '_(Dica: Toque/clique na chave acima para copiá-la diretamente)_',
    instructionsTitle: '*Instruções de Ativação:*',
    step1: '1. Abra o *PS DesKom* no seu computador.',
    step2: '2. Acesse *Sobre > Ativação de Licença*.',
    step3: '3. Cole a chave acima no campo *License Key* e clique em *Validar e Ativar Licença*.',
    thanks: 'Agradecemos por escolher o *PS DesKom*!'
  },
  IT: {
    title: '🔐 *Attivazione PS DesKom — Gradle Studio*',
    device: 'Abbiamo identificato la tua richiesta di licenza per il dispositivo:',
    hwid: '💻 *HWID:*',
    keyTitle: 'La tua Chiave di Licenza Commerciale è:',
    tip: '_(Suggerimento: Tocca/fai clic sulla chiave sopra per copiarla direttamente)_',
    instructionsTitle: '*Istruzioni per l\'Attivazione:*',
    step1: '1. Apri *PS DesKom* sul tuo computer.',
    step2: '2. Vai su *Informazioni > Attivazione Licenza*.',
    step3: '3. Incolla la chiave sopra nel campo *License Key* e fai clic su *Convalida e Attiva Licenza*.',
    thanks: 'Grazie per aver scelto *PS DesKom*!'
  },
  EN: {
    title: '🔐 *PS DesKom Activation — Gradle Studio*',
    device: 'We identified your license request for the device:',
    hwid: '💻 *HWID:*',
    keyTitle: 'Your Commercial License Key is:',
    tip: '_(Tip: Tap/click on the key above to copy it directly)_',
    instructionsTitle: '*Activation Instructions:*',
    step1: '1. Open *PS DesKom* on your computer.',
    step2: '2. Go to *About > License Activation*.',
    step3: '3. Paste the key above into the *License Key* field and click *Validate and Activate License*.',
    thanks: 'Thank you for choosing *PS DesKom*!'
  },
  ES: {
    title: '🔐 *Activación PS DesKom — Gradle Studio*',
    device: 'Hemos identificado su solicitud de licencia para el dispositivo:',
    hwid: '💻 *HWID:*',
    keyTitle: 'Su Clave de Licencia Comercial es:',
    tip: '_(Consejo: Toque/haga clic en la clave de arriba para copiarla directamente)_',
    instructionsTitle: '*Instrucciones de Activación:*',
    step1: '1. Abra *PS DesKom* en su ordenador.',
    step2: '2. Vaya a *Acerca de > Activación de Licencia*.',
    step3: '3. Pegue la clave arriba en el campo *License Key* y haga clic en *Validar y Activar Licencia*.',
    thanks: '¡Gracias por elegir *PS DesKom*!'
  },
  FR: {
    title: '🔐 *Activation PS DesKom — Gradle Studio*',
    device: 'Nous avons identifié votre demande de licence pour l\'appareil :',
    hwid: '💻 *HWID :*',
    keyTitle: 'Votre Clé de Licence Commerciale est :',
    tip: '_(Astuce : Appuyez/cliquez sur la clé ci-dessus pour la copier directement)_',
    instructionsTitle: '*Instructions d\'Activation :*',
    step1: '1. Ouvrez *PS DesKom* sur votre ordinateur.',
    step2: '2. Allez dans *À Propos > Activation de Licence*.',
    step3: '3. Collez la clé ci-dessus dans le champ *License Key* et cliquez sur *Valider et Activer la Licence*.',
    thanks: 'Merci d\'avoir choisi *PS DesKom* !'
  },
  DE: {
    title: '🔐 *PS DesKom Aktivierung — Gradle Studio*',
    device: 'Wir haben Ihre Lizenzanfrage für das Gerät identifiziert:',
    hwid: '💻 *HWID:*',
    keyTitle: 'Ihr kommerzieller Lizenzschlüssel lautet:',
    tip: '_(Tipp: Tippen/klicken Sie auf den obigen Schlüssel, um ihn direkt zu kopieren)_',
    instructionsTitle: '*Aktivierungsanweisungen:*',
    step1: '1. Öffnen Sie *PS DesKom* auf Ihrem Computer.',
    step2: '2. Gehen Sie zu *Über > Lizenzaktivierung*.',
    step3: '3. Fügen Sie den Schlüssel in das Feld *License Key* ein und klicken Sie auf *Lizenz Prüfen und Aktivieren*.',
    thanks: 'Vielen Dank, dass Sie sich für *PS DesKom* entschieden haben!'
  }
};

function resolverIdioma(texto, remoteJid, participant) {
  // 1. Prioridade máxima: Tag explícita [LANG:XX]
  const matchTag = (texto || '').match(/\[LANG:(PT|EN|IT|ES|FR|DE)\]/i);
  if (matchTag) {
    return matchTag[1].toUpperCase();
  }

  // 2. Extração limpa dos números (testando remoteJid e participant)
  const phone1 = (remoteJid || '').replace(/[^0-9]/g, '');
  const phone2 = (participant || '').replace(/[^0-9]/g, '');
  const cleanPhone = phone1.startsWith('55') ? phone1 : (phone2.startsWith('55') ? phone2 : phone1);

  // 3. Verificação por DDI internacional
  if (cleanPhone.startsWith('55')) return 'PT';
  if (cleanPhone.startsWith('39')) return 'IT';
  if (cleanPhone.startsWith('34')) return 'ES';
  if (cleanPhone.startsWith('33')) return 'FR';
  if (cleanPhone.startsWith('49')) return 'DE';

  // 4. Fallback padrão da Gradle Studio DEVE SER PORTUGUÊS (PT)
  return 'PT';
}

function calcularLicencaComercial(hwid) {
  const cleanHwid = hwid.trim().toUpperCase();
  const inputStr = `${cleanHwid}-${SECRET_SALT}`;
  const digest = crypto.createHash('sha256').update(inputStr, 'utf8').digest('hex').toUpperCase();

  const b1 = digest.substring(0, 4);
  const b2 = digest.substring(4, 8);
  const b3 = digest.substring(8, 12);
  const b4 = digest.substring(12, 16);

  return `KEY-${b1}-${b2}-${b3}-${b4}`;
}

async function iniciarBot() {
  const { state, saveCreds } = await useMultiFileAuthState('./auth_info_baileys');

  const socket = makeWASocket({
    auth: state,
    printQRInTerminal: false,
    logger: pino({ level: 'silent' }),
  });

  socket.ev.on('creds.update', saveCreds);

  socket.ev.on('connection.update', (update) => {
    const { connection, lastDisconnect, qr } = update;

    if (qr) {
      console.log('\n===========================================================');
      console.log('  ESCANEIE O QR CODE ABAIXO PARA CONECTAR O BOT WHATSAPP');
      console.log('===========================================================\n');
      qrcode.generate(qr, { small: true });
    }

    if (connection === 'open') {
      console.log('\n===========================================================');
      console.log('  BOT DE LICENCIAMENTO WHATSAPP CONECTADO COM SUCESSO!     ');
      console.log('  Gradle Studio — Suporte Técnico (+55 85 99642-1006)      ');
      console.log('===========================================================\n');
    }

    if (connection === 'close') {
      const statusCode = lastDisconnect?.error?.output?.statusCode;
      const shouldReconnect = statusCode !== DisconnectReason.loggedOut;
      console.log(`Conexão fechada. Motivo: ${statusCode}. Reconectando: ${shouldReconnect}`);
      if (shouldReconnect) {
        iniciarBot();
      }
    }
  });

  socket.ev.on('messages.upsert', async ({ messages, type }) => {
    if (type !== 'notify') return;

    for (const msg of messages) {
      const sender = msg.key.remoteJid;
      const isFromMe = msg.key.fromMe === true;
      const isAdmin = isFromMe || ADMIN_NUMBERS.includes(sender);

      const texto =
        msg.message?.conversation ||
        msg.message?.extendedTextMessage?.text ||
        '';

      if (!texto) continue;

      const match = texto.match(HWID_REGEX);
      if (match) {
        const hwidEncontrado = match[0].toUpperCase();
        const chaveGerada = calcularLicencaComercial(hwidEncontrado);

        console.log(`\n[SOLICITAÇÃO DE LICENÇA RECEBIDA] De: ${sender} (isFromMe: ${isFromMe}, isAdmin: ${isAdmin})`);
        console.log(`  HWID Detectado: ${hwidEncontrado}`);
        console.log(`  Chave Gerada:   ${chaveGerada}`);

        if (isAdmin) {
          const respostaAdmin =
`👑 *Licença Master (Admin/Creator) — PS DesKom*

Identificamos a solicitação de licença do Administrador para o dispositivo:
💻 *HWID:* \`${hwidEncontrado}\`

Sua Chave Master Comercial Gerada é:
\`\`\`${chaveGerada}\`\`\`
_(Dica: Toque/clique na chave acima para copiá-la diretamente)_

*Status:* Cota Irrestrita / Licenciamento Vitalício Ativo
*Gradle Studio — Engenharia de Software*`;

          await socket.sendMessage(sender, { text: respostaAdmin });
          console.log(`  [RESPOSTA MASTER ADMIN ENVIADA COM SUCESSO]`);
        } else {
          // TODO: Validação de cota multiuser por chave de compra
          const lang = resolverIdioma(texto, sender, msg.key.participant);
          const t = TEMPLATES_COMERCIAIS[lang] || TEMPLATES_COMERCIAIS.PT;

          const respostaComercial =
`${t.title}

${t.device}
${t.hwid} \`${hwidEncontrado}\`

${t.keyTitle}
\`\`\`${chaveGerada}\`\`\`
${t.tip}

${t.instructionsTitle}
${t.step1}
${t.step2}
${t.step3}

${t.thanks}`;

          await socket.sendMessage(sender, { text: respostaComercial });
          console.log(`  [RESPOSTA COMERCIAL (${lang}) ENVIADA COM SUCESSO]`);
        }
      } else {
        // Atendente Virtual (Grad Bot) para mensagens gerais de clientes
        if (!isFromMe) {
          const lang = resolverIdioma(texto, sender, msg.key.participant);
          console.log(`\n[MENSAGEM DE ATENDIMENTO RECEBIDA] De: ${sender} (${lang})`);
          await gerenciadorAtendimento.processarMensagem(socket, sender, texto, lang);
        }
      }
    }
  });
}

iniciarBot().catch((err) => {
  console.error('Erro fatal no Bot de Licenciamento WhatsApp:', err);
});

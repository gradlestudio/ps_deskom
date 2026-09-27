; Script NSIS - PS DesKom
; Desenvolvido por Gradle Studio
; Compatível com NSIS 3.x e HM NIS Edit

!define PRODUCT_NAME "PS DesKom"
!define PRODUCT_VERSION "1.0.0"
!define PRODUCT_PUBLISHER "Gradle Studio"
!define PRODUCT_WEB_SITE "https://github.com/gradlestudio"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\ps_deskom.exe"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"

SetCompressor lzma
Unicode true
RequestExecutionLevel admin

; MUI Modern UI 2
!include "MUI2.nsh"

; Definições Visuais
!define MUI_ABORTWARNING
!define MUI_ICON "assets\icones\PS-DesKom.ico"
!define MUI_UNICON "assets\icones\PS-DesKom.ico"

; Definições de Seleção de Idioma
!define MUI_LANGDLL_REGISTRY_ROOT "${PRODUCT_UNINST_ROOT_KEY}"
!define MUI_LANGDLL_REGISTRY_KEY "${PRODUCT_UNINST_KEY}"
!define MUI_LANGDLL_REGISTRY_VALUENAME "NSIS:Language"

; Páginas do Instalador
!insertmacro MUI_PAGE_WELCOME
!define MUI_LICENSEPAGE_CHECKBOX
!insertmacro MUI_PAGE_LICENSE "eula.txt"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES

; Página Final
!define MUI_FINISHPAGE_RUN "$INSTDIR\ps_deskom.exe"
!define MUI_FINISHPAGE_RUN_TEXT "Executar o ${PRODUCT_NAME}"
!define MUI_FINISHPAGE_SHOWREADME "$INSTDIR\README.txt"
!define MUI_FINISHPAGE_SHOWREADME_TEXT "Abrir o ficheiro README"
!insertmacro MUI_PAGE_FINISH

; Páginas do Desinstalador
!insertmacro MUI_UNPAGE_INSTFILES

; Idiomas Suportados
!insertmacro MUI_LANGUAGE "PortugueseBR"
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "Spanish"
!insertmacro MUI_LANGUAGE "French"
!insertmacro MUI_LANGUAGE "German"
!insertmacro MUI_LANGUAGE "Italian"

; Configurações Gerais do Executável
Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "installer_output\PS_DesKom_Setup_v1.0.0.exe"
InstallDir "$PROGRAMFILES64\Gradle Studio\PS DesKom"
InstallDirRegKey HKLM "${PRODUCT_DIR_REGKEY}" ""
ShowInstDetails show
ShowUnInstDetails show

Function .onInit
  !insertmacro MUI_LANGDLL_DISPLAY
FunctionEnd

Section "SeçãoPrincipal" SEC01
  ; Habilita visão do sistema de 64-bit para evitar redirecionamento WoW64
  SetRegView 64

  SetOutPath "$INSTDIR"
  SetOverwrite try

  ; Copia todos os binários e subdiretórios da compilação Release
  File /r "build\windows\x64\runner\Release\*.*"

  ; Copia a documentação de apoio
  File "README.txt"
  File "eula.txt"

  ; Criação de Atalhos
  CreateDirectory "$SMPROGRAMS\PS DesKom"
  CreateShortCut "$SMPROGRAMS\PS DesKom\PS DesKom.lnk" "$INSTDIR\ps_deskom.exe" "" "$INSTDIR\data\flutter_assets\assets\icones\PS-DesKom.ico"
  CreateShortCut "$DESKTOP\PS DesKom.lnk" "$INSTDIR\ps_deskom.exe" "" "$INSTDIR\data\flutter_assets\assets\icones\PS-DesKom.ico"
SectionEnd

Section -Post
  SetRegView 64
  WriteUninstaller "$INSTDIR\uninst.exe"
  WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR\ps_deskom.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\ps_deskom.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
SectionEnd

Function un.onUninstSuccess
  HideWindow
  MessageBox MB_ICONINFORMATION|MB_OK "$(^Name) foi removido com sucesso do seu computador."
FunctionEnd

Function un.onInit
  !insertmacro MUI_UNGETLANGUAGE
  MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "Tem a certeza de que pretende desinstalar $(^Name) e todos os seus componentes?" IDYES +2
  Abort
FunctionEnd

Section Uninstall
  SetRegView 64

  ; Remove os atalhos
  Delete "$DESKTOP\PS DesKom.lnk"
  Delete "$SMPROGRAMS\PS DesKom\PS DesKom.lnk"
  RMDir "$SMPROGRAMS\PS DesKom"

  ; Remove os ficheiros e diretório principal
  RMDir /r "$INSTDIR"

  ; Limpeza do Registo do Windows
  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
  DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
  SetAutoClose true
SectionEnd
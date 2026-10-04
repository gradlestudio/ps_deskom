#include <windows.h>
#include <objbase.h>
#include "payload_reader.h"
#include "installer_window.h"

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow) {
    CoInitializeEx(NULL, COINIT_APARTMENTTHREADED);

    GsseFooter footer = {};
    std::string jsonStr;
    std::vector<uint8_t> zipBytes;

    bool hasPayload = PayloadReader::ReadSelfPayload(footer, jsonStr, zipBytes);

    GsseManifestData manifest;
    if (hasPayload) {
        PayloadReader::ParseManifestJson(jsonStr, manifest);
    } else {
        // Fallback em caso de teste do executável isolado antes do empacotamento
        manifest.appName = L"PS DesKom";
        manifest.appEdition = L"Pro";
        manifest.version = L"1.0.0";
        manifest.publisher = L"Gradle Studio";
        manifest.defaultInstallDir = L"C:\\Program Files\\Gradle Studio\\PS DesKom";
        manifest.mainExecutable = L"ps_deskom.exe";
        manifest.createDesktopShortcut = true;
        manifest.createStartMenuShortcut = true;
        manifest.runAfterInstall = true;

        MessageBoxW(NULL, L"Gradle Studio Setup Engine (GSSE v1.0)\n\nInstalador autônomo iniciado com sucesso!", L"PS DesKom Setup", MB_OK | MB_ICONINFORMATION);
    }

    InstallerWindow::ShowWindowAndInstall(hInstance, manifest, zipBytes);

    CoUninitialize();
    return 0;
}

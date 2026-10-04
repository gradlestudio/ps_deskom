#include "installer_window.h"
#include "system_integration.h"
#include <shlobj.h>
#include <commctrl.h>
#include <fstream>
#include <sstream>

#pragma comment(lib, "comctl32.lib")

static HWND g_hWnd = NULL;
static HWND g_hProgressBar = NULL;
static HWND g_hStatusText = NULL;
static HWND g_hInstallDirEdit = NULL;
static HWND g_hInstallButton = NULL;
static HWND g_hCancelButton = NULL;

static GsseManifestData g_Manifest;
static std::vector<uint8_t> g_ZipBytes;
static bool g_Installing = false;

static HBRUSH g_hDarkBrush = NULL;
static HBRUSH g_hCardBrush = NULL;

static bool ExtractZipPayloadToFolder(const std::vector<uint8_t>& zipBytes, const std::wstring& targetDir) {
    CreateDirectoryW(targetDir.c_str(), NULL);

    // Grava temporariamente o arquivo ZIP para descompactação rápida
    wchar_t tempPath[MAX_PATH];
    GetTempPathW(MAX_PATH, tempPath);
    std::wstring tempZipFile = std::wstring(tempPath) + L"gsse_temp_payload.zip";

    HANDLE hFile = CreateFileW(tempZipFile.c_str(), GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
    if (hFile != INVALID_HANDLE_VALUE) {
        DWORD bytesWritten = 0;
        WriteFile(hFile, zipBytes.data(), (DWORD)zipBytes.size(), &bytesWritten, NULL);
        CloseHandle(hFile);
    }

    // Executa comando nativo do PowerShell para extração segura e preservação da estrutura
    std::wstring psCmd = L"powershell.exe -Command \"Expand-Archive -Path '" + tempZipFile + L"' -DestinationPath '" + targetDir + L"' -Force\"";

    STARTUPINFOW si = { sizeof(si) };
    PROCESS_INFORMATION pi = {};
    si.dwFlags = STARTF_USESHOWWINDOW;
    si.wShowWindow = SW_HIDE;

    if (CreateProcessW(NULL, (LPWSTR)psCmd.c_str(), NULL, NULL, FALSE, CREATE_NO_WINDOW, NULL, NULL, &si, &pi)) {
        WaitForSingleObject(pi.hProcess, INFINITE);
        CloseHandle(pi.hProcess);
        CloseHandle(pi.hThread);
    }

    DeleteFileW(tempZipFile.c_str());
    return true;
}

static DWORD WINAPI PerformInstallationThread(LPVOID lpParam) {
    g_Installing = true;

    SetWindowTextW(g_hStatusText, L"Criando diretórios no sistema...");
    SendMessage(g_hProgressBar, PBM_SETPOS, 20, 0);

    wchar_t customDir[MAX_PATH];
    GetWindowTextW(g_hInstallDirEdit, customDir, MAX_PATH);
    std::wstring targetInstallDir = customDir;
    if (targetInstallDir.empty()) {
        targetInstallDir = g_Manifest.defaultInstallDir;
    }

    SetWindowTextW(g_hStatusText, L"Extraindo arquivos da aplicação...");
    SendMessage(g_hProgressBar, PBM_SETPOS, 40, 0);

    ExtractZipPayloadToFolder(g_ZipBytes, targetInstallDir);

    SetWindowTextW(g_hStatusText, L"Criando atalhos no Desktop e Menu Iniciar...");
    SendMessage(g_hProgressBar, PBM_SETPOS, 70, 0);

    std::wstring mainExePath = targetInstallDir + L"\\" + g_Manifest.mainExecutable;

    if (g_Manifest.createDesktopShortcut) {
        std::wstring desktopDir = SystemIntegration::GetSpecialFolderPath(CSIDL_DESKTOPDIRECTORY);
        if (!desktopDir.empty()) {
            std::wstring shortcutPath = desktopDir + L"\\" + g_Manifest.appName + L".lnk";
            SystemIntegration::CreateShortcut(mainExePath, shortcutPath, g_Manifest.appName);
        }
    }

    if (g_Manifest.createStartMenuShortcut) {
        std::wstring startMenuDir = SystemIntegration::GetSpecialFolderPath(CSIDL_PROGRAMS);
        if (!startMenuDir.empty()) {
            std::wstring shortcutPath = startMenuDir + L"\\" + g_Manifest.appName + L".lnk";
            SystemIntegration::CreateShortcut(mainExePath, shortcutPath, g_Manifest.appName);
        }
    }

    SetWindowTextW(g_hStatusText, L"Registrando aplicativo no Windows...");
    SendMessage(g_hProgressBar, PBM_SETPOS, 85, 0);
    SystemIntegration::RegisterUninstallEntry(g_Manifest, targetInstallDir);

    SendMessage(g_hProgressBar, PBM_SETPOS, 100, 0);
    SetWindowTextW(g_hStatusText, L"Instalação concluída com sucesso!");

    SetWindowTextW(g_hInstallButton, L"Concluir");
    EnableWindow(g_hInstallButton, TRUE);
    g_Installing = false;

    if (g_Manifest.runAfterInstall) {
        ShellExecuteW(NULL, L"open", mainExePath.c_str(), NULL, targetInstallDir.c_str(), SW_SHOW);
    }

    return 0;
}

static LRESULT CALLBACK WndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam) {
    switch (message) {
    case WM_CREATE: {
        g_hDarkBrush = CreateSolidBrush(RGB(22, 22, 22));
        g_hCardBrush = CreateSolidBrush(RGB(37, 37, 38));

        // Título e Versão
        std::wstring titleStr = g_Manifest.appName + (g_Manifest.appEdition.empty() ? L"" : L" (" + g_Manifest.appEdition + L")");
        CreateWindowW(L"STATIC", titleStr.c_str(), WS_VISIBLE | WS_CHILD | SS_CENTER,
            20, 20, 520, 30, hWnd, NULL, NULL, NULL);

        std::wstring verStr = L"Instalador Oficial — " + g_Manifest.publisher + L" (v" + g_Manifest.version + L")";
        CreateWindowW(L"STATIC", verStr.c_str(), WS_VISIBLE | WS_CHILD | SS_CENTER,
            20, 55, 520, 20, hWnd, NULL, NULL, NULL);

        // Campo de Destino
        CreateWindowW(L"STATIC", L"Diretório de Instalação:", WS_VISIBLE | WS_CHILD,
            30, 95, 500, 20, hWnd, NULL, NULL, NULL);

        g_hInstallDirEdit = CreateWindowExW(WS_EX_CLIENTEDGE, L"EDIT", g_Manifest.defaultInstallDir.c_str(),
            WS_VISIBLE | WS_CHILD | ES_AUTOHSCROLL, 30, 120, 500, 26, hWnd, NULL, NULL, NULL);

        // Barra de Progresso
        INITCOMMONCONTROLSEX icex = { sizeof(icex), ICC_PROGRESS_CLASS };
        InitCommonControlsEx(&icex);

        g_hProgressBar = CreateWindowExW(0, PROGRESS_CLASSW, NULL,
            WS_CHILD | WS_VISIBLE | PBS_SMOOTH, 30, 165, 500, 22, hWnd, NULL, NULL, NULL);

        g_hStatusText = CreateWindowW(L"STATIC", L"Pronto para instalar. Clique em 'Instalar agora'.",
            WS_VISIBLE | WS_CHILD | SS_LEFT, 30, 195, 500, 20, hWnd, NULL, NULL, NULL);

        // Botões de Ação
        g_hInstallButton = CreateWindowW(L"BUTTON", L"Instalar Agora",
            WS_VISIBLE | WS_CHILD | BS_DEFPUSHBUTTON, 290, 235, 120, 32, hWnd, (HMENU)101, NULL, NULL);

        g_hCancelButton = CreateWindowW(L"BUTTON", L"Cancelar",
            WS_VISIBLE | WS_CHILD | BS_PUSHBUTTON, 420, 235, 110, 32, hWnd, (HMENU)102, NULL, NULL);

        break;
    }

    case WM_COMMAND: {
        int wmId = LOWORD(wParam);
        if (wmId == 101) { // Instalar / Concluir
            wchar_t btnText[64];
            GetWindowTextW(g_hInstallButton, btnText, 64);
            if (wcscmp(btnText, L"Concluir") == 0) {
                DestroyWindow(hWnd);
            } else if (!g_Installing) {
                EnableWindow(g_hInstallButton, FALSE);
                CreateThread(NULL, 0, PerformInstallationThread, NULL, 0, NULL);
            }
        } else if (wmId == 102) { // Cancelar
            if (!g_Installing) {
                DestroyWindow(hWnd);
            }
        }
        break;
    }

    case WM_CTLCOLORSTATIC: {
        HDC hdcStatic = (HDC)wParam;
        SetTextColor(hdcStatic, RGB(220, 220, 220));
        SetBkColor(hdcStatic, RGB(22, 22, 22));
        return (INT_PTR)g_hDarkBrush;
    }

    case WM_DESTROY:
        if (g_hDarkBrush) DeleteObject(g_hDarkBrush);
        if (g_hCardBrush) DeleteObject(g_hCardBrush);
        PostQuitMessage(0);
        break;

    default:
        return DefWindowProcW(hWnd, message, wParam, lParam);
    }
    return 0;
}

bool InstallerWindow::ShowWindowAndInstall(HINSTANCE hInstance, const GsseManifestData& manifest, const std::vector<uint8_t>& zipBytes) {
    g_Manifest = manifest;
    g_ZipBytes = zipBytes;

    const wchar_t CLASS_NAME[] = L"GsseInstallerWindowClass";

    WNDCLASSW wc = {};
    wc.lpfnWndProc = WndProc;
    wc.hInstance = hInstance;
    wc.lpszClassName = CLASS_NAME;
    wc.hbrBackground = CreateSolidBrush(RGB(22, 22, 22));
    wc.hIcon = LoadIcon(NULL, IDI_APPLICATION);
    wc.hCursor = LoadCursor(NULL, IDC_ARROW);

    RegisterClassW(&wc);

    std::wstring winTitle = manifest.appName + L" Setup — Gradle Studio";
    g_hWnd = CreateWindowExW(
        0,
        CLASS_NAME,
        winTitle.c_str(),
        WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_MINIMIZEBOX,
        CW_USEDEFAULT, CW_USEDEFAULT, 575, 320,
        NULL, NULL, hInstance, NULL
    );

    if (g_hWnd == NULL) {
        return false;
    }

    // Centralizar na tela
    RECT rc;
    GetWindowRect(g_hWnd, &rc);
    int xPos = (GetSystemMetrics(SM_CXSCREEN) - (rc.right - rc.left)) / 2;
    int yPos = (GetSystemMetrics(SM_CYSCREEN) - (rc.bottom - rc.top)) / 2;
    SetWindowPos(g_hWnd, NULL, xPos, yPos, 0, 0, SWP_NOZORDER | SWP_NOSIZE);

    ShowWindow(g_hWnd, SW_SHOW);
    UpdateWindow(g_hWnd);

    MSG msg = {};
    while (GetMessageW(&msg, NULL, 0, 0)) {
        TranslateMessage(&msg);
        DispatchMessageW(&msg);
    }

    return true;
}

#include "system_integration.h"
#include <shlobj.h>
#include <shlguid.h>

std::wstring SystemIntegration::GetSpecialFolderPath(int csidl) {
    wchar_t path[MAX_PATH];
    if (SUCCEEDED(SHGetFolderPathW(NULL, csidl, NULL, 0, path))) {
        return std::wstring(path);
    }
    return L"";
}

bool SystemIntegration::CreateShortcut(const std::wstring& targetExePath, const std::wstring& shortcutPath, const std::wstring& description) {
    IShellLinkW* pShellLink = NULL;
    HRESULT hr = CoCreateInstance(CLSID_ShellLink, NULL, CLSCTX_INPROC_SERVER, IID_IShellLinkW, (void**)&pShellLink);

    if (SUCCEEDED(hr)) {
        pShellLink->SetPath(targetExePath.c_str());
        pShellLink->SetDescription(description.c_str());

        std::wstring workingDir = targetExePath.substr(0, targetExePath.find_last_of(L"\\/"));
        pShellLink->SetWorkingDirectory(workingDir.c_str());

        IPersistFile* pPersistFile = NULL;
        hr = pShellLink->QueryInterface(IID_IPersistFile, (void**)&pPersistFile);

        if (SUCCEEDED(hr)) {
            hr = pPersistFile->Save(shortcutPath.c_str(), TRUE);
            pPersistFile->Release();
        }
        pShellLink->Release();
    }

    return SUCCEEDED(hr);
}

bool SystemIntegration::RegisterUninstallEntry(const GsseManifestData& manifest, const std::wstring& installDir) {
    HKEY hKey;
    std::wstring regPath = L"Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\" + manifest.appName;

    LONG result = RegCreateKeyExW(
        HKEY_CURRENT_USER,
        regPath.c_str(),
        0,
        NULL,
        REG_OPTION_NON_VOLATILE,
        KEY_WRITE,
        NULL,
        &hKey,
        NULL
    );

    if (result != ERROR_SUCCESS) {
        return false;
    }

    std::wstring displayName = manifest.appName + (manifest.appEdition.empty() ? L"" : L" (" + manifest.appEdition + L")");
    std::wstring mainExePath = installDir + L"\\" + manifest.mainExecutable;

    RegSetValueExW(hKey, L"DisplayName", 0, REG_SZ, (BYTE*)displayName.c_str(), (DWORD)(displayName.length() * sizeof(wchar_t)));
    RegSetValueExW(hKey, L"DisplayVersion", 0, REG_SZ, (BYTE*)manifest.version.c_str(), (DWORD)(manifest.version.length() * sizeof(wchar_t)));
    RegSetValueExW(hKey, L"Publisher", 0, REG_SZ, (BYTE*)manifest.publisher.c_str(), (DWORD)(manifest.publisher.length() * sizeof(wchar_t)));
    RegSetValueExW(hKey, L"InstallLocation", 0, REG_SZ, (BYTE*)installDir.c_str(), (DWORD)(installDir.length() * sizeof(wchar_t)));
    RegSetValueExW(hKey, L"UninstallString", 0, REG_SZ, (BYTE*)mainExePath.c_str(), (DWORD)(mainExePath.length() * sizeof(wchar_t)));

    DWORD noModify = 1;
    RegSetValueExW(hKey, L"NoModify", 0, REG_DWORD, (BYTE*)&noModify, sizeof(DWORD));
    RegSetValueExW(hKey, L"NoRepair", 0, REG_DWORD, (BYTE*)&noModify, sizeof(DWORD));

    RegCloseKey(hKey);
    return true;
}

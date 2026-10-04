#pragma once
#include <windows.h>
#include <string>
#include "payload_reader.h"

class SystemIntegration {
public:
    static bool CreateShortcut(const std::wstring& targetExePath, const std::wstring& shortcutPath, const std::wstring& description);
    static bool RegisterUninstallEntry(const GsseManifestData& manifest, const std::wstring& installDir);
    static std::wstring GetSpecialFolderPath(int csidl);
};

#pragma once
#include <windows.h>
#include <string>
#include "payload_reader.h"

class InstallerWindow {
public:
    static bool ShowWindowAndInstall(HINSTANCE hInstance, const GsseManifestData& manifest, const std::vector<uint8_t>& zipBytes);
};

#pragma once
#include <windows.h>
#include <cstdint>
#include <string>
#include <vector>

#pragma pack(push, 1)
struct GsseFooter {
    uint64_t payloadOffset;
    uint64_t manifestOffset;
    uint64_t manifestSize;
    char magic[8]; // "GSSE_V10"
};
#pragma pack(pop)

struct GsseManifestData {
    std::wstring appName;
    std::wstring appEdition;
    std::wstring version;
    std::wstring publisher;
    std::wstring website;
    std::wstring defaultInstallDir;
    std::wstring mainExecutable;
    bool createDesktopShortcut = true;
    bool createStartMenuShortcut = true;
    bool runAfterInstall = true;
    std::wstring eulaText;
};

class PayloadReader {
public:
    static bool ReadSelfPayload(GsseFooter& outFooter, std::string& outManifestJson, std::vector<uint8_t>& outZipBytes);
    static bool ParseManifestJson(const std::string& jsonStr, GsseManifestData& outManifest);
};

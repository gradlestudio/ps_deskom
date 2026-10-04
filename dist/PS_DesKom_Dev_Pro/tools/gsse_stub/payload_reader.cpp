#include "payload_reader.h"
#include <fstream>
#include <iostream>
#include <sstream>

static std::wstring Utf8ToWString(const std::string& str) {
    if (str.empty()) return L"";
    int sizeNeeded = MultiByteToWideChar(CP_UTF8, 0, &str[0], (int)str.size(), NULL, 0);
    std::wstring wstrTo(sizeNeeded, 0);
    MultiByteToWideChar(CP_UTF8, 0, &str[0], (int)str.size(), &wstrTo[0], sizeNeeded);
    return wstrTo;
}

bool PayloadReader::ReadSelfPayload(GsseFooter& outFooter, std::string& outManifestJson, std::vector<uint8_t>& outZipBytes) {
    wchar_t exePath[MAX_PATH];
    if (GetModuleFileNameW(NULL, exePath, MAX_PATH) == 0) {
        return false;
    }

    HANDLE hFile = CreateFileW(exePath, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
    if (hFile == INVALID_HANDLE_VALUE) {
        return false;
    }

    LARGE_INTEGER fileSize;
    if (!GetFileSizeEx(hFile, &fileSize) || fileSize.QuadPart < 32) {
        CloseHandle(hFile);
        return false;
    }

    // 1. Ler o Footer de 32 bytes do final do arquivo
    LARGE_INTEGER footerOffset;
    footerOffset.QuadPart = fileSize.QuadPart - 32;
    SetFilePointerEx(hFile, footerOffset, NULL, FILE_BEGIN);

    DWORD bytesRead = 0;
    if (!ReadFile(hFile, &outFooter, sizeof(GsseFooter), &bytesRead, NULL) || bytesRead != sizeof(GsseFooter)) {
        CloseHandle(hFile);
        return false;
    }

    // 2. Validar a assinatura mágica "GSSE_V10"
    if (memcmp(outFooter.magic, "GSSE_V10", 8) != 0) {
        CloseHandle(hFile);
        return false;
    }

    // 3. Ler o Manifesto JSON
    if (outFooter.manifestOffset + outFooter.manifestSize > (uint64_t)fileSize.QuadPart) {
        CloseHandle(hFile);
        return false;
    }

    LARGE_INTEGER manifestOffset;
    manifestOffset.QuadPart = (LONGLONG)outFooter.manifestOffset;
    SetFilePointerEx(hFile, manifestOffset, NULL, FILE_BEGIN);

    std::vector<char> jsonBuffer(outFooter.manifestSize + 1, 0);
    if (!ReadFile(hFile, jsonBuffer.data(), (DWORD)outFooter.manifestSize, &bytesRead, NULL) || bytesRead != outFooter.manifestSize) {
        CloseHandle(hFile);
        return false;
    }
    outManifestJson = std::string(jsonBuffer.data(), outFooter.manifestSize);

    // 4. Ler o Payload ZIP
    uint64_t zipSize = outFooter.manifestOffset - outFooter.payloadOffset;
    LARGE_INTEGER payloadOffset;
    payloadOffset.QuadPart = (LONGLONG)outFooter.payloadOffset;
    SetFilePointerEx(hFile, payloadOffset, NULL, FILE_BEGIN);

    outZipBytes.resize(zipSize);
    if (!ReadFile(hFile, outZipBytes.data(), (DWORD)zipSize, &bytesRead, NULL) || bytesRead != zipSize) {
        CloseHandle(hFile);
        return false;
    }

    CloseHandle(hFile);
    return true;
}

static std::string ExtractJsonValue(const std::string& json, const std::string& key) {
    std::string searchKey = "\"" + key + "\"";
    size_t pos = json.find(searchKey);
    if (pos == std::string::npos) return "";

    size_t colon = json.find(":", pos);
    if (colon == std::string::npos) return "";

    size_t startQuote = json.find("\"", colon);
    if (startQuote == std::string::npos) return "";

    size_t endQuote = json.find("\"", startQuote + 1);
    if (endQuote == std::string::npos) return "";

    return json.substr(startQuote + 1, endQuote - startQuote - 1);
}

static bool ExtractJsonBool(const std::string& json, const std::string& key, bool defaultValue) {
    std::string searchKey = "\"" + key + "\"";
    size_t pos = json.find(searchKey);
    if (pos == std::string::npos) return defaultValue;

    size_t colon = json.find(":", pos);
    if (colon == std::string::npos) return defaultValue;

    size_t truePos = json.find("true", colon);
    size_t falsePos = json.find("false", colon);

    if (truePos != std::string::npos && (falsePos == std::string::npos || truePos < falsePos)) {
        return true;
    }
    if (falsePos != std::string::npos) {
        return false;
    }
    return defaultValue;
}

bool PayloadReader::ParseManifestJson(const std::string& jsonStr, GsseManifestData& outManifest) {
    outManifest.appName = Utf8ToWString(ExtractJsonValue(jsonStr, "appName"));
    if (outManifest.appName.empty()) outManifest.appName = L"PS DesKom";

    outManifest.appEdition = Utf8ToWString(ExtractJsonValue(jsonStr, "appEdition"));
    outManifest.version = Utf8ToWString(ExtractJsonValue(jsonStr, "version"));
    if (outManifest.version.empty()) outManifest.version = L"1.0.0";

    outManifest.publisher = Utf8ToWString(ExtractJsonValue(jsonStr, "publisher"));
    if (outManifest.publisher.empty()) outManifest.publisher = L"Gradle Studio";

    outManifest.website = Utf8ToWString(ExtractJsonValue(jsonStr, "website"));
    outManifest.defaultInstallDir = Utf8ToWString(ExtractJsonValue(jsonStr, "defaultInstallDir"));
    if (outManifest.defaultInstallDir.empty()) {
        outManifest.defaultInstallDir = L"C:\\Program Files\\Gradle Studio\\PS DesKom";
    }

    outManifest.mainExecutable = Utf8ToWString(ExtractJsonValue(jsonStr, "mainExecutable"));
    if (outManifest.mainExecutable.empty()) outManifest.mainExecutable = L"ps_deskom.exe";

    outManifest.createDesktopShortcut = ExtractJsonBool(jsonStr, "createDesktopShortcut", true);
    outManifest.createStartMenuShortcut = ExtractJsonBool(jsonStr, "createStartMenuShortcut", true);
    outManifest.runAfterInstall = ExtractJsonBool(jsonStr, "runAfterInstall", true);
    outManifest.eulaText = Utf8ToWString(ExtractJsonValue(jsonStr, "eulaText"));

    return true;
}

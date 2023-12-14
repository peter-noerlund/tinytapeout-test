#include <filesystem>
#include <string>
#include <system_error>

#ifdef _WIN32
#include <windows.h>
#else // _WIN32
#include <unistd.h>
#endif // _WIN32

std::filesystem::path executablePath()
{
#ifdef _WIN32
    std::string buffer;
    buffer.resize(MAX_PATH);

    auto moduleHandle = GetModuleHandleA(nullptr);
    while (true)
    {
        DWORD size = GetModuleFileNameA(moduleHandle, buffer.data(), buffer.size());
        if (size == 0)
        {
            throw std::system_error(GetLastError(), std::system_category());
        }
        if (size == buffer.size() && GetLastError() == ERROR_INSUFFICIENT_BUFFER)
        {
            buffer.resize(buffer.size() + MAX_PATH);
            continue;
        }

        buffer.resize(size);
        break;
    }

    return std::filesystem::path(buffer);
#else  // _WIN32
    std::string buffer;
    buffer.resize(4096);

    auto size = readlink("/proc/self/exe", static_cast<char *>(buffer.data()),
                         buffer.size());
    if (size == -1)
    {
        throw std::system_error(errno, std::system_category());
    }
    buffer.resize(size);

    return std::filesystem::path(buffer);
#endif // _WIN32
}

int main()
{
    std::filesystem::current_path(executablePath().parent_path());

    if (execlp(VVP_PATH, "vvp", "-n", DESIGN, NULL) == -1)
    {
        throw std::system_error(errno, std::system_category());
    }

    return EXIT_SUCCESS;
}
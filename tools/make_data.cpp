#include <array>
#include <cstdlib>
#include <exception>
#include <iostream>
#include <filesystem>
#include <fstream>
#include <map>
#include <stdexcept>
#include <string>
#include <string_view>

enum class Command : std::uint8_t
{
    Noop = 0,
    End,
    Read,
    Write,
    Enable,
    Disable
};

enum Register : std::uint8_t
{
    WordLength = 0,
    ResultMask = 1,
    Offset = 2,
    Char0 = 8,
    Char1,
    Char2,
    Char3,
    Char4,
    Char5,
    Char6,
    Char7,
    Mask0,
    Mask1,
    Mask2,
    Mask3,
    Mask4,
    Mask5,
    Mask6,
    Mask7,
    Result0,
    Result1,
    Result2,
    Result3,
    Result4,
    Result5,
    Result6,
    Result7
};

static void writeChar(std::ostream& stream, char c)
{
    stream.write(&c, sizeof(c));
}

static void writeCommand(std::ostream& stream, Command command)
{
    char buffer = static_cast<char>(command);
    stream.write(&buffer, sizeof(buffer));
}

static void readData(std::ostream& stream, std::uint8_t reg)
{
    std::array<char, 2> buffer{static_cast<char>(Command::Read), static_cast<char>(reg)};
    stream.write(buffer.data(), buffer.size());
}

template<typename T>
static void writeData(std::ostream& stream, std::uint8_t reg, T value)
{
    std::array<char, 3> buffer{static_cast<char>(Command::Write), static_cast<char>(reg), static_cast<char>(value)};
    stream.write(buffer.data(), buffer.size());
}

static std::map<char, std::uint8_t> analyzeWord(std::string_view word)
{
    std::map<char, std::uint8_t> chars;
    for (std::size_t i = 0; i != word.size(); ++i)
    {
        auto c = word[i];
        auto it = chars.find(c);
        if (it == chars.end())
        {
            chars[c] = 1 << i;
        }
        else
        {
            it->second |= 1 << i;
        }
    }
    return chars;
}

static void makeData(std::string_view word, const std::filesystem::path& wordsFilename, const std::filesystem::path& binFilename)
{
    if (word.size() > 8)
    {
        throw std::invalid_argument("Word too long");
    }

    std::ofstream out(binFilename, std::ofstream::out | std::ofstream::binary | std::ofstream::trunc);
    if (!out.is_open())
    {
        throw std::runtime_error("Error creating binary file");
    }

    std::ifstream in(wordsFilename);
    if (!in.is_open())
    {
        throw std::runtime_error("Error opening words file");
    }

    writeCommand(out, Command::Disable);
    writeData(out, Register::WordLength, word.size());
    writeData(out, Register::ResultMask, 1 << (word.size() - 1));
    writeData(out, Register::Offset, 0);

    auto analysis = analyzeWord(word);
    std::size_t pos = 0;
    for (auto [c, mask] : analysis)
    {
        writeData(out, Register::Char0 + pos, c);
        writeData(out, Register::Mask0 + pos, mask);
        ++pos;
    }
    for (; pos != 8; ++pos)
    {
        writeData(out, Register::Char0 + pos, 0);
        writeData(out, Register::Mask0 + pos, 0);
    }

    writeCommand(out, Command::Enable);

    std::string line;
    std::size_t count = 0;
    while (std::getline(in, line).good())
    {
        for (auto c : line)
        {
            writeChar(out, c);
        }
        writeCommand(out, Command::End);

        if (++count % 8 == 0)
        {
            writeCommand(out, Command::Noop);
            writeCommand(out, Command::Noop);
            writeCommand(out, Command::Noop);
            readData(out, Register::Result0);
            readData(out, Register::Result1);
            readData(out, Register::Result2);
            readData(out, Register::Result3);
            readData(out, Register::Result4);
            readData(out, Register::Result5);
            readData(out, Register::Result6);
            readData(out, Register::Result7);
        }
    }

    if (count != 0)
    {
        for (std::size_t i = 0; i != 8 - count % 8; ++i)
        {
            readData(out, Register::Result0 + i);
        }
    }
}

int main(int argc, char** argv)
{
    if (argc < 4)
    {
        std::cerr << "Usage: make_data WORD WORDS_FILE BIN_FILE" << std::endl;
        return EXIT_FAILURE;
    }

    try
    {
        makeData(argv[1], argv[2], argv[3]);
        return EXIT_SUCCESS;
    }
    catch (const std::exception& exception)
    {
        std::cerr << exception.what() << std::endl;
        return EXIT_FAILURE;
    }
}
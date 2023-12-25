cmake_minimum_required(VERSION 3.18)

project(tinytapeout-test LANGUAGES CXX)

find_program(IVERILOG_PATH NAMES iverilog HINTS ${IVERILOG_ROOT} ENV IVERILOG_ROOT REQUIRED)
find_program(VVP_PATH NAMES vvp HINTS ${IVERILOG_ROOT} ENV IVERILOG_ROOT REQUIRED)

add_executable(run tools/run.cpp)
target_compile_features(run PRIVATE cxx_std_20)
target_compile_definitions(run PRIVATE VVP_PATH="${VVP_PATH}" DESIGN="tb")
if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    target_compile_options(run PRIVATE -Wall -W -Wextra -Wpedantic)
endif()

add_custom_target(
    testbench ALL
    COMMAND ${IVERILOG_PATH} -g2012 -Wall -o ${CMAKE_CURRENT_BINARY_DIR}/tb $<FILTER:$<TARGET_PROPERTY:testbench,SOURCES>,EXCLUDE,testbench>
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMAND_EXPAND_LISTS
    VERBATIM
    SOURCES
        src/comparator.v
        src/levenshtein.v
        src/spi_controller.v
        src/spi_tester.v
        src/tb.v
        src/tt_um_pchri03_top.v
)
add_dependencies(run testbench)

add_executable(make_data EXCLUDE_FROM_ALL tools/make_data.cpp)
target_compile_features(run PRIVATE cxx_std_20)
if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    target_compile_options(run PRIVATE -Wall -W -Wextra -Wpedantic)
endif()

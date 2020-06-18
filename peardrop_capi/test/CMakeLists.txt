cmake_minimum_required(VERSION 3.11)
set(CMAKE_CXX_STANDARD 11)

project(peardrop_capi_tests)

add_executable(peardrop_capi_tests
	src/test_ack.cpp
	src/test_ad.cpp
	src/test_sender.cpp
)

include(ExternalProject)

set_directory_properties(PROPERTIES EP_PREFIX ${CMAKE_BINARY_DIR}/Rust)

ExternalProject_Add(
	peardrop_capi
	DOWNLOAD_COMMAND ""
	CONFIGURE_COMMAND ""
	BUILD_COMMAND cargo build COMMAND cargo build --release
	BINARY_DIR "${CMAKE_SOURCE_DIR}/.."
	INSTALL_COMMAND ""
	LOG_BUILD ON
)

add_dependencies(peardrop_capi_tests peardrop_capi)

include_directories(${CMAKE_SOURCE_DIR}/../include)

target_link_libraries(peardrop_capi_tests
	debug "${CMAKE_SOURCE_DIR}/../target/debug/libpeardrop_capi.a"
	optimized "${CMAKE_SOURCE_DIR}/../target/release/libpeardrop_capi.a"
)

# Googletest stuff

add_subdirectory(externals/googletest)

include_directories(${gtest_SOURCE_DIR}/include ${gtest_SOURCE_DIR})

target_link_libraries(peardrop_capi_tests gtest gtest_main)

enable_testing()

add_test(all peardrop_capi_tests)

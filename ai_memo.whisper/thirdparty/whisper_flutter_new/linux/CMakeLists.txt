cmake_minimum_required(VERSION 3.10)

set(PROJECT_NAME "whisper_library_flutter")
project(${PROJECT_NAME} LANGUAGES CXX)

include(GNUInstallDirs)
#set(CMAKE_INSTALL_LIBDIR lib)
add_subdirectory("${CMAKE_CURRENT_SOURCE_DIR}/../src" src)

#set(whisper_library_flutter_bundled_libraries
#  # Defined in ../src/CMakeLists.txt.
#  # This can be changed to accommodate different builds. 
#  "${CMAKE_CURRENT_SOURCE_DIR}/libwhisper.so"
#  PARENT_SCOPE
#)

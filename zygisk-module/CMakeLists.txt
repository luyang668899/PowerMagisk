cmake_minimum_required(VERSION 3.18)
project(zygisk_example)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 添加 Zygisk 头文件
include_directories(${CMAKE_SOURCE_DIR}/include)

# 添加源文件
add_library(zygisk_example SHARED
    src/main.cpp
)

# 链接库
target_link_libraries(zygisk_example
    log
)

# 设置输出目录
set_target_properties(zygisk_example PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/lib/${ANDROID_ABI}"
)

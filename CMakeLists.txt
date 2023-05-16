cmake_minimum_required(VERSION 3.19)
project(xv6 C)

include_directories(xv6-labs-2020)
include_directories(xv6-labs-2020/kernel)
include_directories(xv6-labs-2020/user)


file (GLOB_RECURSE files xv6-labs-2020/kernel/*)
add_executable(kernel ${files})
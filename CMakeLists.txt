project(openvpnshell)
cmake_minimum_required(VERSION 2.8)

file(GLOB_RECURSE SRC_LIST src/*.c* src/*.h*)

################################################################################

add_executable(${PROJECT_NAME} ${SRC_LIST})

################################################################################
# Enabling C++11. Add these two lines after add_executable
set_property(TARGET ${PROJECT_NAME} PROPERTY CXX_STANDARD 11)
set_property(TARGET ${PROJECT_NAME} PROPERTY CXX_STANDARD_REQUIRED ON)

################################################################################

install(PROGRAMS ${CMAKE_SOURCE_DIR}/resources/openvpn.sh DESTINATION bin)
install(TARGETS ${PROJECT_NAME} RUNTIME DESTINATION bin)
install(FILES ${CMAKE_SOURCE_DIR}/resources/openvpn4ucs_logo.svg DESTINATION /usr/share/icons/hicolor/scalable/apps)
install(FILES ${CMAKE_SOURCE_DIR}/resources/OpenVPN.desktop DESTINATION /usr/share/applications/)
install(FILES ${CMAKE_SOURCE_DIR}/resources/Standalone\ OpenVPN.desktop DESTINATION /usr/share/applications/)
install(FILES ${CMAKE_SOURCE_DIR}/resources/openvpn DESTINATION /etc/sudoers.d PERMISSIONS OWNER_READ GROUP_READ)



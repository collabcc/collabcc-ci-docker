cmake_minimum_required(VERSION 3.0 FATAL_ERROR)

project(collabcc-ci-docker LANGUAGES NONE)

macro(ReadVar varname)
    if("${${varname}}" STREQUAL "")
        set(${varname} "$ENV{${varname}}")
        if("${${varname}}" STREQUAL "")
            message(FATAL_ERROR "${varname} is not defined (or empty).")
        endif()
    endif()
endmacro()

ReadVar(OS_NAME)
ReadVar(OS_VER)

set(TAG "collabccci/${OS_NAME}:${OS_VER}")

if ("${OS_NAME}" MATCHES "^(ubuntu|debian)$")
    configure_file(
        Dockerfile.apt.cmakein
        Dockerfile
        @ONLY)
elseif ("${OS_NAME}" MATCHES "^(centos|fedora)$")
    configure_file(
        Dockerfile.yum.cmakein
        Dockerfile
        @ONLY)
endif()

add_custom_target(
    build_docker_image
    ALL
    COMMAND sudo docker build --rm --force-rm --pull --tag "${TAG}" "${CMAKE_CURRENT_BINARY_DIR}"
    VERBATIM
    SOURCES "${CMAKE_CURRENT_BINARY_DIR}/Dockerfile")

add_custom_command(
    TARGET build_docker_image
    POST_BUILD
    COMMAND sudo docker push "${TAG}"
    VERBATIM)


RESOURCES_LIBRARY()


INCLUDE(resources.inc)
IF(USE_SYSTEM_JDK)
    MESSAGE(WARNING DEFAULT_JDK are disabled)
ELSEIF(JDK_REAL_VERSION == "18")
    DECLARE_EXTERNAL_HOST_RESOURCES_BUNDLE(
        JDK_DEFAULT
        ${JDK18_DARWIN} FOR DARWIN
        ${JDK18_DARWIN_ARM64} FOR DARWIN-ARM64
        ${JDK18_LINUX} FOR LINUX
        ${JDK18_WINDOWS} FOR WIN32
    )
    IF(NOT HOST_OS_LINUX AND NOT HOST_OS_WINDOWS AND NOT HOST_OS_DARWIN)
        MESSAGE(FATAL_ERROR Unsupported platform for JDK18)
    ENDIF()
ELSEIF(JDK_REAL_VERSION == "17")
    DECLARE_EXTERNAL_HOST_RESOURCES_BUNDLE(
        JDK_DEFAULT
        ${JDK17_DARWIN} FOR DARWIN
        ${JDK17_DARWIN_ARM64} FOR DARWIN-ARM64
        ${JDK17_LINUX} FOR LINUX
        ${JDK17_WINDOWS} FOR WIN32
    )
    IF(NOT HOST_OS_LINUX AND NOT HOST_OS_WINDOWS AND NOT HOST_OS_DARWIN)
        MESSAGE(FATAL_ERROR Unsupported platform for JDK17)
    ENDIF()
ELSEIF(JDK_REAL_VERSION == "16")
    DECLARE_EXTERNAL_HOST_RESOURCES_BUNDLE(
        JDK_DEFAULT
        ${JDK16_DARWIN} FOR DARWIN
        ${JDK16_DARWIN_ARM64} FOR DARWIN-ARM64
        ${JDK16_LINUX} FOR LINUX
        ${JDK16_WINDOWS} FOR WIN32
    )
    IF(NOT HOST_OS_LINUX AND NOT HOST_OS_WINDOWS AND NOT HOST_OS_DARWIN)
        MESSAGE(FATAL_ERROR Unsupported platform for JDK16)
    ENDIF()
ELSEIF(JDK_REAL_VERSION == "15")
    DECLARE_EXTERNAL_HOST_RESOURCES_BUNDLE(
        JDK_DEFAULT
        ${JDK15_DARWIN} FOR DARWIN
        ${JDK15_DARWIN_ARM64} FOR DARWIN-ARM64
        ${JDK15_LINUX} FOR LINUX
        ${JDK15_WINDOWS} FOR WIN32
    )
    IF(NOT HOST_OS_LINUX AND NOT HOST_OS_WINDOWS AND NOT HOST_OS_DARWIN)
        MESSAGE(FATAL_ERROR Unsupported platform for JDK15)
    ENDIF()
ELSEIF(JDK_REAL_VERSION == "14")
    DECLARE_EXTERNAL_HOST_RESOURCES_BUNDLE(
        JDK_DEFAULT
        ${JDK14_DARWIN} FOR DARWIN
        ${JDK14_LINUX} FOR LINUX
        ${JDK14_WINDOWS} FOR WIN32
    )
    IF(NOT HOST_OS_LINUX AND NOT HOST_OS_WINDOWS AND NOT HOST_OS_DARWIN)
        MESSAGE(FATAL_ERROR Unsupported platform for JDK14)
    ENDIF()
ELSEIF(JDK_REAL_VERSION == "13")
    DECLARE_EXTERNAL_HOST_RESOURCES_BUNDLE(
        JDK_DEFAULT
        ${JDK13_DARWIN} FOR DARWIN
        ${JDK13_LINUX} FOR LINUX
        ${JDK13_WINDOWS} FOR WIN32
    )
    IF(NOT HOST_OS_LINUX AND NOT HOST_OS_WINDOWS AND NOT HOST_OS_DARWIN)
        MESSAGE(FATAL_ERROR Unsupported platform for JDK13)
    ENDIF()
ELSEIF(JDK_REAL_VERSION == "12")
    DECLARE_EXTERNAL_HOST_RESOURCES_BUNDLE(
        JDK_DEFAULT
        ${JDK12_DARWIN} FOR DARWIN
        ${JDK12_LINUX} FOR LINUX
        ${JDK12_WINDOWS} FOR WIN32
    )
    IF(NOT HOST_OS_LINUX AND NOT HOST_OS_WINDOWS AND NOT HOST_OS_DARWIN)
        MESSAGE(FATAL_ERROR Unsupported platform for JDK12)
    ENDIF()
ELSEIF(JDK_REAL_VERSION == "11")
    DECLARE_EXTERNAL_HOST_RESOURCES_BUNDLE(
        JDK_DEFAULT
        ${JDK11_DARWIN} FOR DARWIN
        ${JDK11_DARWIN_ARM64} FOR DARWIN-ARM64
        ${JDK11_LINUX} FOR LINUX
        ${JDK11_WINDOWS} FOR WIN32
    )
    IF(NOT HOST_OS_LINUX AND NOT HOST_OS_WINDOWS AND NOT HOST_OS_DARWIN)
        MESSAGE(FATAL_ERROR Unsupported platform for JDK11)
    ENDIF()
ELSEIF(JDK_REAL_VERSION == "10")
    DECLARE_EXTERNAL_HOST_RESOURCES_BUNDLE(
        JDK_DEFAULT
        ${JDK10_DARWIN} FOR DARWIN
        ${JDK10_LINUX} FOR LINUX
        ${JDK10_WINDOWS} FOR WIN32
    )
ELSEIF(JDK_REAL_VERSION == "8")
    DECLARE_EXTERNAL_HOST_RESOURCES_BUNDLE(
        JDK_DEFAULT
        ${JDK8_DARWIN_ARM64} FOR DARWIN-ARM64
        ${JDK8_DARWIN} FOR DARWIN
        ${JDK8_LINUX} FOR LINUX
        ${JDK8_WINDOWS} FOR WIN32
    )
    IF(NOT HOST_OS_LINUX AND NOT HOST_OS_WINDOWS AND NOT HOST_OS_DARWIN)
        MESSAGE(FATAL_ERROR Unsupported platform for JDK8)
    ENDIF()
ELSE()
    MESSAGE(FATAL_ERROR Unsupported JDK version ${JDK_REAL_VERSION})
ENDIF()

IF(USE_SYSTEM_JDK)
    MESSAGE(WARNING System JDK $USE_SYSTEM_JDK will be used)
ELSEIF(JDK_REAL_VERSION == "18")
    IF(OS_DARWIN AND ARCH_ARM64)
        DECLARE_EXTERNAL_RESOURCE(WITH_JDK ${JDK18_DARWIN_ARM64})
    ELSEIF(OS_DARWIN)
        DECLARE_EXTERNAL_RESOURCE(WITH_JDK ${JDK18_DARWIN})
    ELSEIF(OS_LINUX)
        DECLARE_EXTERNAL_RESOURCE(WITH_JDK ${JDK18_LINUX})
    ELSEIF(OS_WINDOWS)
        DECLARE_EXTERNAL_RESOURCE(WITH_JDK ${JDK18_WINDOWS})
    ENDIF()
ELSEIF(JDK_REAL_VERSION == "17")
    IF(OS_DARWIN AND ARCH_ARM64)
        DECLARE_EXTERNAL_RESOURCE(WITH_JDK ${JDK17_DARWIN_ARM64})
    ELSEIF(OS_DARWIN)
        DECLARE_EXTERNAL_RESOURCE(WITH_JDK ${JDK17_DARWIN})
    ELSEIF(OS_LINUX)
        DECLARE_EXTERNAL_RESOURCE(WITH_JDK ${JDK17_LINUX})
    ELSEIF(OS_WINDOWS)
        DECLARE_EXTERNAL_RESOURCE(WITH_JDK ${JDK17_WINDOWS})
    ENDIF()
ELSEIF(JDK_REAL_VERSION == "16")
    IF(OS_DARWIN AND ARCH_ARM64)
        DECLARE_EXTERNAL_RESOURCE(WITH_JDK ${JDK16_DARWIN_ARM64})
    ELSEIF(OS_DARWIN)
        DECLARE_EXTERNAL_RESOURCE(WITH_JDK ${JDK16_DARWIN})
    ELSEIF(OS_LINUX)
        DECLARE_EXTERNAL_RESOURCE(WITH_JDK ${JDK16_LINUX})
    ELSEIF(OS_WINDOWS)
        DECLARE_EXTERNAL_RESOURCE(WITH_JDK ${JDK16_WINDOWS})
    ENDIF()
ELSEIF(JDK_REAL_VERSION == "15")
    IF(OS_DARWIN AND ARCH_ARM64)
        DECLARE_EXTERNAL_RESOURCE(WITH_JDK ${JDK15_DARWIN_ARM64})
    ELSEIF(OS_DARWIN)
        DECLARE_EXTERNAL_RESOURCE(WITH_JDK ${JDK15_DARWIN})
    ELSEIF(OS_LINUX)
        DECLARE_EXTERNAL_RESOURCE(WITH_JDK ${JDK15_LINUX})
    ELSEIF(OS_WINDOWS)
        DECLARE_EXTERNAL_RESOURCE(WITH_JDK ${JDK15_WINDOWS})
    ENDIF()
ELSEIF(JDK_REAL_VERSION == "14")
    IF(OS_DARWIN)
        DECLARE_EXTERNAL_RESOURCE(WITH_JDK ${JDK14_DARWIN})
    ELSEIF(OS_LINUX)
        DECLARE_EXTERNAL_RESOURCE(WITH_JDK ${JDK14_LINUX})
    ELSEIF(OS_WINDOWS)
        DECLARE_EXTERNAL_RESOURCE(WITH_JDK ${JDK14_WINDOWS})
    ENDIF()
ELSEIF(JDK_REAL_VERSION == "13")
    IF(SANITIZER_TYPE == "address")
        IF(HOST_OS_LINUX)
            DECLARE_EXTERNAL_RESOURCE(JDK_FOR_TESTS ${JDK13_LINUX_ASAN})
        ELSE()
            MESSAGE(FATAL_ERROR Unsupported platform for JDK13 with asan)
        ENDIF()
    ENDIF()

    IF(OS_DARWIN)
        DECLARE_EXTERNAL_RESOURCE(WITH_JDK ${JDK13_DARWIN})
    ELSEIF(OS_LINUX)
        DECLARE_EXTERNAL_RESOURCE(WITH_JDK ${JDK13_LINUX})
    ELSEIF(OS_WINDOWS)
        DECLARE_EXTERNAL_RESOURCE(WITH_JDK ${JDK13_WINDOWS})
    ENDIF()
ELSEIF(JDK_REAL_VERSION == "12")
    IF(OS_DARWIN)
        DECLARE_EXTERNAL_RESOURCE(WITH_JDK ${JDK12_DARWIN})
    ELSEIF(OS_LINUX)
        DECLARE_EXTERNAL_RESOURCE(WITH_JDK ${JDK12_LINUX})
    ELSEIF(OS_WINDOWS)
        DECLARE_EXTERNAL_RESOURCE(WITH_JDK ${JDK12_WINDOWS})
    ENDIF()
ELSEIF(JDK_REAL_VERSION == "11")
    IF(OS_DARWIN AND ARCH_ARM64)
        DECLARE_EXTERNAL_RESOURCE(WITH_JDK ${JDK11_DARWIN_ARM64})
    ELSEIF(OS_DARWIN)
        DECLARE_EXTERNAL_RESOURCE(WITH_JDK ${JDK11_DARWIN})
    ELSEIF(OS_LINUX)
        DECLARE_EXTERNAL_RESOURCE(WITH_JDK ${JDK11_LINUX})
    ELSEIF(OS_WINDOWS)
        DECLARE_EXTERNAL_RESOURCE(WITH_JDK ${JDK11_WINDOWS})
    ENDIF()
ELSEIF(JDK_REAL_VERSION == "10")
    IF(OS_DARWIN)
        DECLARE_EXTERNAL_RESOURCE(WITH_JDK ${JDK10_DARWIN})
    ELSEIF(OS_LINUX)
        DECLARE_EXTERNAL_RESOURCE(WITH_JDK ${JDK10_LINUX})
    ELSEIF(OS_WINDOWS)
        DECLARE_EXTERNAL_RESOURCE(WITH_JDK ${JDK10_WINDOWS})
    ENDIF()
ELSEIF(JDK_REAL_VERSION == "8")
    IF(OS_DARWIN AND ARCH_ARM64)
        DECLARE_EXTERNAL_RESOURCE(WITH_JDK ${JDK8_DARWIN_ARM64})
    ELSEIF(OS_DARWIN)
        DECLARE_EXTERNAL_RESOURCE(WITH_JDK ${JDK8_DARWIN})
    ELSEIF(OS_LINUX)
        DECLARE_EXTERNAL_RESOURCE(WITH_JDK ${JDK8_LINUX})
    ELSEIF(OS_WINDOWS)
        DECLARE_EXTERNAL_RESOURCE(WITH_JDK ${JDK8_WINDOWS})
    ENDIF()
ELSE()
    MESSAGE(FATAL_ERROR Unsupported JDK version)
ENDIF()

END()

RECURSE(
    jdk8
    jdk10
    jdk11
    jdk12
    jdk13
    jdk14
    jdk15
    jdk16
    jdk17
    jdk18
)

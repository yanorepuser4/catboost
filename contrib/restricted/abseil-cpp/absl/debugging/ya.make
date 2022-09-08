# Generated by devtools/yamaker.

LIBRARY()



LICENSE(Apache-2.0)

LICENSE_TEXTS(.yandex_meta/licenses.list.txt)

PEERDIR(
    contrib/restricted/abseil-cpp/absl/base
)

ADDINCL(
    GLOBAL contrib/restricted/abseil-cpp
)

NO_COMPILER_WARNINGS()

NO_UTIL()

CFLAGS(
    -DNOMINMAX
)

SRCS(
    failure_signal_handler.cc
    internal/address_is_readable.cc
    internal/demangle.cc
    internal/elf_mem_image.cc
    internal/examine_stack.cc
    internal/vdso_support.cc
    leak_check.cc
    stacktrace.cc
    symbolize.cc
)

END()

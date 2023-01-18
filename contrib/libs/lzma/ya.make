# Generated by devtools/yamaker from nixpkgs 22.05.

LIBRARY()

LICENSE(Public-Domain)

LICENSE_TEXTS(.yandex_meta/licenses.list.txt)



VERSION(5.4.0)

ORIGINAL_SOURCE(https://tukaani.org/xz/xz-5.4.0.tar.bz2)

ADDINCL(
    GLOBAL contrib/libs/lzma/liblzma/api
    contrib/libs/lzma/common
    contrib/libs/lzma/liblzma
    contrib/libs/lzma/liblzma/check
    contrib/libs/lzma/liblzma/common
    contrib/libs/lzma/liblzma/delta
    contrib/libs/lzma/liblzma/lz
    contrib/libs/lzma/liblzma/lzma
    contrib/libs/lzma/liblzma/rangecoder
    contrib/libs/lzma/liblzma/simple
)

NO_COMPILER_WARNINGS()

NO_RUNTIME()

CFLAGS(
    -DHAVE_CONFIG_H
    -DTUKLIB_SYMBOL_PREFIX=lzma_
    GLOBAL -DLZMA_API_STATIC
)

SRCS(
    common/tuklib_cpucores.c
    common/tuklib_physmem.c
    liblzma/check/check.c
    liblzma/check/crc32_fast.c
    liblzma/check/crc32_table.c
    liblzma/check/crc64_fast.c
    liblzma/check/crc64_table.c
    liblzma/check/sha256.c
    liblzma/common/alone_decoder.c
    liblzma/common/alone_encoder.c
    liblzma/common/auto_decoder.c
    liblzma/common/block_buffer_decoder.c
    liblzma/common/block_buffer_encoder.c
    liblzma/common/block_decoder.c
    liblzma/common/block_encoder.c
    liblzma/common/block_header_decoder.c
    liblzma/common/block_header_encoder.c
    liblzma/common/block_util.c
    liblzma/common/common.c
    liblzma/common/easy_buffer_encoder.c
    liblzma/common/easy_decoder_memusage.c
    liblzma/common/easy_encoder.c
    liblzma/common/easy_encoder_memusage.c
    liblzma/common/easy_preset.c
    liblzma/common/file_info.c
    liblzma/common/filter_buffer_decoder.c
    liblzma/common/filter_buffer_encoder.c
    liblzma/common/filter_common.c
    liblzma/common/filter_decoder.c
    liblzma/common/filter_encoder.c
    liblzma/common/filter_flags_decoder.c
    liblzma/common/filter_flags_encoder.c
    liblzma/common/hardware_cputhreads.c
    liblzma/common/hardware_physmem.c
    liblzma/common/index.c
    liblzma/common/index_decoder.c
    liblzma/common/index_encoder.c
    liblzma/common/index_hash.c
    liblzma/common/lzip_decoder.c
    liblzma/common/microlzma_decoder.c
    liblzma/common/microlzma_encoder.c
    liblzma/common/outqueue.c
    liblzma/common/stream_buffer_decoder.c
    liblzma/common/stream_buffer_encoder.c
    liblzma/common/stream_decoder.c
    liblzma/common/stream_decoder_mt.c
    liblzma/common/stream_encoder.c
    liblzma/common/stream_encoder_mt.c
    liblzma/common/stream_flags_common.c
    liblzma/common/stream_flags_decoder.c
    liblzma/common/stream_flags_encoder.c
    liblzma/common/string_conversion.c
    liblzma/common/vli_decoder.c
    liblzma/common/vli_encoder.c
    liblzma/common/vli_size.c
    liblzma/delta/delta_common.c
    liblzma/delta/delta_decoder.c
    liblzma/delta/delta_encoder.c
    liblzma/lz/lz_decoder.c
    liblzma/lz/lz_encoder.c
    liblzma/lz/lz_encoder_mf.c
    liblzma/lzma/fastpos_table.c
    liblzma/lzma/lzma2_decoder.c
    liblzma/lzma/lzma2_encoder.c
    liblzma/lzma/lzma_decoder.c
    liblzma/lzma/lzma_encoder.c
    liblzma/lzma/lzma_encoder_optimum_fast.c
    liblzma/lzma/lzma_encoder_optimum_normal.c
    liblzma/lzma/lzma_encoder_presets.c
    liblzma/rangecoder/price_table.c
    liblzma/simple/arm.c
    liblzma/simple/arm64.c
    liblzma/simple/armthumb.c
    liblzma/simple/ia64.c
    liblzma/simple/powerpc.c
    liblzma/simple/simple_coder.c
    liblzma/simple/simple_decoder.c
    liblzma/simple/simple_encoder.c
    liblzma/simple/sparc.c
    liblzma/simple/x86.c
)

END()

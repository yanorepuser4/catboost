#include "bitops.h"

#include <library/cpp/testing/unittest/registar.h>

#include <util/string/builder.h>

template <typename T>
static void TestCTZ() {
    for (unsigned int i = 0; i < (sizeof(T) << 3); ++i) {
        UNIT_ASSERT_VALUES_EQUAL(CountTrailingZeroBits(T(1) << i), i);
    }
}

template <typename T>
static void TestFastClp2ForEachPowerOf2() {
    for (size_t i = 0; i < sizeof(T) * 8 - 1; ++i) {
        const auto current = T(1) << i;
        UNIT_ASSERT_VALUES_EQUAL(FastClp2(current), current);
    }

    UNIT_ASSERT_VALUES_EQUAL(FastClp2(T(1)), T(1));
    for (size_t i = 1; i < sizeof(T) * 8 - 1; ++i) {
        for (size_t j = 0; j < i; ++j) {
            const auto value = (T(1) << i) | (T(1) << j);
            const auto next = T(1) << (i + 1);
            UNIT_ASSERT_VALUES_EQUAL(FastClp2(value), next);
        }
    }
}

template <typename T>
static T ReverseBitsSlow(T v) {
    T r = v;                    // r will be reversed bits of v; first get LSB of v
    ui32 s = sizeof(v) * 8 - 1; // extra shift needed at end

    for (v >>= 1; v; v >>= 1) {
        r <<= 1;
        r |= v & 1;
        --s;
    }

    r <<= s; // shift when v's highest bits are zero
    return r;
}

// DO_NOT_STYLE
Y_UNIT_TEST_SUITE(TBitOpsTest) {
    Y_UNIT_TEST(TestCountTrailingZeroBits) {
        TestCTZ<unsigned int>();
        TestCTZ<unsigned long>();
        TestCTZ<unsigned long long>();
    }

    Y_UNIT_TEST(TestIsPowerOf2) {
        UNIT_ASSERT(!IsPowerOf2(-2));
        UNIT_ASSERT(!IsPowerOf2(-1));
        UNIT_ASSERT(!IsPowerOf2(0));
        UNIT_ASSERT(IsPowerOf2(1));
        UNIT_ASSERT(IsPowerOf2(2));
        UNIT_ASSERT(!IsPowerOf2(3));
        UNIT_ASSERT(IsPowerOf2(4));
        UNIT_ASSERT(!IsPowerOf2(5));
        UNIT_ASSERT(IsPowerOf2(0x10000000u));
        UNIT_ASSERT(!IsPowerOf2(0x10000001u));
        UNIT_ASSERT(IsPowerOf2(0x1000000000000000ull));
        UNIT_ASSERT(!IsPowerOf2(0x1000000000000001ull));
    }

    Y_UNIT_TEST(TestFastClp2) {
        TestFastClp2ForEachPowerOf2<unsigned>();
        TestFastClp2ForEachPowerOf2<unsigned long>();
        TestFastClp2ForEachPowerOf2<unsigned long long>();
    }

    Y_UNIT_TEST(TestMask) {
        for (ui32 i = 0; i < 64; ++i) {
            UNIT_ASSERT_VALUES_EQUAL(MaskLowerBits(i), (ui64{1} << i) - 1);
            UNIT_ASSERT_VALUES_EQUAL(InverseMaskLowerBits(i), ~MaskLowerBits(i));
            UNIT_ASSERT_VALUES_EQUAL(MaskLowerBits(i, i / 2), (ui64{1} << i) - 1 << (i / 2));
            UNIT_ASSERT_VALUES_EQUAL(InverseMaskLowerBits(i, i / 2), ~MaskLowerBits(i, i / 2));
        }
    }

    Y_UNIT_TEST(TestMostSignificantBit) {
        static_assert(MostSignificantBitCT(0) == 0, ".");
        static_assert(MostSignificantBitCT(1) == 0, ".");
        static_assert(MostSignificantBitCT(5) == 2, ".");

        for (ui32 i = 0; i < 64; ++i) {
            UNIT_ASSERT_VALUES_EQUAL(i, MostSignificantBit(ui64{1} << i));
        }

        for (ui32 i = 0; i < 63; ++i) {
            UNIT_ASSERT_VALUES_EQUAL(i + 1, MostSignificantBit(ui64{3} << i));
        }
    }

    Y_UNIT_TEST(TestLeastSignificantBit) {
        for (ui32 i = 0; i < 64; ++i) {
            UNIT_ASSERT_VALUES_EQUAL(i, LeastSignificantBit(ui64{1} << i));
        }

        for (ui32 i = 0; i < 63; ++i) {
            UNIT_ASSERT_VALUES_EQUAL(i, LeastSignificantBit(ui64{3} << i));
        }

        for (ui32 i = 0; i < 64; ++i) {
            ui64 value = (ui64(-1)) << i;
            UNIT_ASSERT_VALUES_EQUAL(i, LeastSignificantBit(value));
        }
    }

    Y_UNIT_TEST(TestCeilLog2) {
        UNIT_ASSERT_VALUES_EQUAL(CeilLog2(ui64{1}), 1);

        for (ui32 i = 2; i < 64; ++i) {
            UNIT_ASSERT_VALUES_EQUAL(CeilLog2(ui64{1} << i), i);
            UNIT_ASSERT_VALUES_EQUAL(CeilLog2((ui64{1} << i) | ui64{1}), i + 1);
        }
    }

    Y_UNIT_TEST(TestReverse) {
        for (ui64 i = 0; i < 0x100; ++i) {
            UNIT_ASSERT_VALUES_EQUAL(ReverseBits((ui8)i), ReverseBitsSlow((ui8)i));
            UNIT_ASSERT_VALUES_EQUAL(ReverseBits((ui16)i), ReverseBitsSlow((ui16)i));
            UNIT_ASSERT_VALUES_EQUAL(ReverseBits((ui32)i), ReverseBitsSlow((ui32)i));
            UNIT_ASSERT_VALUES_EQUAL(ReverseBits((ui64)i), ReverseBitsSlow((ui64)i));
            UNIT_ASSERT_VALUES_EQUAL(ReverseBits((ui16)~i), ReverseBitsSlow((ui16)~i));
            UNIT_ASSERT_VALUES_EQUAL(ReverseBits((ui32)~i), ReverseBitsSlow((ui32)~i));
            UNIT_ASSERT_VALUES_EQUAL(ReverseBits((ui64)~i), ReverseBitsSlow((ui64)~i));
        }

        ui32 v = 0xF0F0F0F0; // 11110000111100001111000011110000
        for (ui32 i = 0; i < 4; ++i) {
            UNIT_ASSERT_VALUES_EQUAL(ReverseBits(v, i + 1), v);
            UNIT_ASSERT_VALUES_EQUAL(ReverseBits(v, 4 + 2 * i, 4 - i), v);
        }

        UNIT_ASSERT_VALUES_EQUAL(ReverseBits(v, 8), 0xF0F0F00Fu);
        UNIT_ASSERT_VALUES_EQUAL(ReverseBits(v, 8, 4), 0xF0F0FF00u);

        for (ui32 i = 0; i < 0x10000; ++i) {
            for (ui32 j = 0; j <= 32; ++j) {
                UNIT_ASSERT_VALUES_EQUAL_C(i, ReverseBits(ReverseBits(i, j), j), (TString)(TStringBuilder() << i << " " << j));
            }
        }
    }

    Y_UNIT_TEST(TestRotateBitsLeft) {
        static_assert(RotateBitsLeftCT<ui8>(0b00000000u, 0) == 0b00000000u, "");
        static_assert(RotateBitsLeftCT<ui8>(0b00000001u, 0) == 0b00000001u, "");
        static_assert(RotateBitsLeftCT<ui8>(0b10000000u, 0) == 0b10000000u, "");
        static_assert(RotateBitsLeftCT<ui8>(0b00000001u, 1) == 0b00000010u, "");
        static_assert(RotateBitsLeftCT<ui8>(0b10000000u, 1) == 0b00000001u, "");
        static_assert(RotateBitsLeftCT<ui8>(0b00000101u, 1) == 0b00001010u, "");
        static_assert(RotateBitsLeftCT<ui8>(0b10100000u, 1) == 0b01000001u, "");
        static_assert(RotateBitsLeftCT<ui8>(0b10000000u, 7) == 0b01000000u, "");

        UNIT_ASSERT_VALUES_EQUAL(RotateBitsLeft<ui8>(0b00000000u, 0), 0b00000000u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsLeft<ui8>(0b00000001u, 0), 0b00000001u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsLeft<ui8>(0b10000000u, 0), 0b10000000u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsLeft<ui8>(0b00000001u, 1), 0b00000010u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsLeft<ui8>(0b10000000u, 1), 0b00000001u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsLeft<ui8>(0b00000101u, 1), 0b00001010u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsLeft<ui8>(0b10100000u, 1), 0b01000001u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsLeft<ui8>(0b10000000u, 7), 0b01000000u);

        static_assert(RotateBitsLeftCT<ui16>(0b0000000000000000u, 0) == 0b0000000000000000u, "");
        static_assert(RotateBitsLeftCT<ui16>(0b0000000000000001u, 0) == 0b0000000000000001u, "");
        static_assert(RotateBitsLeftCT<ui16>(0b1000000000000000u, 0) == 0b1000000000000000u, "");
        static_assert(RotateBitsLeftCT<ui16>(0b0000000000000001u, 1) == 0b0000000000000010u, "");
        static_assert(RotateBitsLeftCT<ui16>(0b1000000000000000u, 1) == 0b0000000000000001u, "");
        static_assert(RotateBitsLeftCT<ui16>(0b0000000000000101u, 1) == 0b0000000000001010u, "");
        static_assert(RotateBitsLeftCT<ui16>(0b1010000000000000u, 1) == 0b0100000000000001u, "");
        static_assert(RotateBitsLeftCT<ui16>(0b1000000000000000u, 15) == 0b0100000000000000u, "");

        UNIT_ASSERT_VALUES_EQUAL(RotateBitsLeft<ui16>(0b0000000000000000u, 0), 0b0000000000000000u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsLeft<ui16>(0b0000000000000001u, 0), 0b0000000000000001u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsLeft<ui16>(0b1000000000000000u, 0), 0b1000000000000000u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsLeft<ui16>(0b0000000000000001u, 1), 0b0000000000000010u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsLeft<ui16>(0b1000000000000000u, 1), 0b0000000000000001u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsLeft<ui16>(0b0000000000000101u, 1), 0b0000000000001010u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsLeft<ui16>(0b1010000000000000u, 1), 0b0100000000000001u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsLeft<ui16>(0b1000000000000000u, 15), 0b0100000000000000u);

        static_assert(RotateBitsLeftCT<ui32>(0b00000000000000000000000000000000u, 0) == 0b00000000000000000000000000000000u, "");
        static_assert(RotateBitsLeftCT<ui32>(0b00000000000000000000000000000001u, 0) == 0b00000000000000000000000000000001u, "");
        static_assert(RotateBitsLeftCT<ui32>(0b10000000000000000000000000000000u, 0) == 0b10000000000000000000000000000000u, "");
        static_assert(RotateBitsLeftCT<ui32>(0b00000000000000000000000000000001u, 1) == 0b00000000000000000000000000000010u, "");
        static_assert(RotateBitsLeftCT<ui32>(0b10000000000000000000000000000000u, 1) == 0b00000000000000000000000000000001u, "");
        static_assert(RotateBitsLeftCT<ui32>(0b00000000000000000000000000000101u, 1) == 0b00000000000000000000000000001010u, "");
        static_assert(RotateBitsLeftCT<ui32>(0b10100000000000000000000000000000u, 1) == 0b01000000000000000000000000000001u, "");
        static_assert(RotateBitsLeftCT<ui32>(0b10000000000000000000000000000000u, 31) == 0b01000000000000000000000000000000u, "");

        UNIT_ASSERT_VALUES_EQUAL(RotateBitsLeft<ui32>(0b00000000000000000000000000000000u, 0), 0b00000000000000000000000000000000u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsLeft<ui32>(0b00000000000000000000000000000001u, 0), 0b00000000000000000000000000000001u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsLeft<ui32>(0b10000000000000000000000000000000u, 0), 0b10000000000000000000000000000000u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsLeft<ui32>(0b00000000000000000000000000000001u, 1), 0b00000000000000000000000000000010u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsLeft<ui32>(0b10000000000000000000000000000000u, 1), 0b00000000000000000000000000000001u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsLeft<ui32>(0b00000000000000000000000000000101u, 1), 0b00000000000000000000000000001010u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsLeft<ui32>(0b10100000000000000000000000000000u, 1), 0b01000000000000000000000000000001u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsLeft<ui32>(0b10000000000000000000000000000000u, 31), 0b01000000000000000000000000000000u);

        static_assert(RotateBitsLeftCT<ui64>(0b0000000000000000000000000000000000000000000000000000000000000000u, 0) == 0b0000000000000000000000000000000000000000000000000000000000000000u, "");
        static_assert(RotateBitsLeftCT<ui64>(0b0000000000000000000000000000000000000000000000000000000000000001u, 0) == 0b0000000000000000000000000000000000000000000000000000000000000001u, "");
        static_assert(RotateBitsLeftCT<ui64>(0b1000000000000000000000000000000000000000000000000000000000000000u, 0) == 0b1000000000000000000000000000000000000000000000000000000000000000u, "");
        static_assert(RotateBitsLeftCT<ui64>(0b0000000000000000000000000000000000000000000000000000000000000001u, 1) == 0b0000000000000000000000000000000000000000000000000000000000000010u, "");
        static_assert(RotateBitsLeftCT<ui64>(0b1000000000000000000000000000000000000000000000000000000000000000u, 1) == 0b0000000000000000000000000000000000000000000000000000000000000001u, "");
        static_assert(RotateBitsLeftCT<ui64>(0b0000000000000000000000000000000000000000000000000000000000000101u, 1) == 0b0000000000000000000000000000000000000000000000000000000000001010u, "");
        static_assert(RotateBitsLeftCT<ui64>(0b1010000000000000000000000000000000000000000000000000000000000000u, 1) == 0b0100000000000000000000000000000000000000000000000000000000000001u, "");
        static_assert(RotateBitsLeftCT<ui64>(0b1000000000000000000000000000000000000000000000000000000000000000u, 63) == 0b0100000000000000000000000000000000000000000000000000000000000000u, "");

        UNIT_ASSERT_VALUES_EQUAL(RotateBitsLeft<ui64>(0b0000000000000000000000000000000000000000000000000000000000000000u, 0), 0b0000000000000000000000000000000000000000000000000000000000000000u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsLeft<ui64>(0b0000000000000000000000000000000000000000000000000000000000000001u, 0), 0b0000000000000000000000000000000000000000000000000000000000000001u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsLeft<ui64>(0b1000000000000000000000000000000000000000000000000000000000000000u, 0), 0b1000000000000000000000000000000000000000000000000000000000000000u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsLeft<ui64>(0b0000000000000000000000000000000000000000000000000000000000000001u, 1), 0b0000000000000000000000000000000000000000000000000000000000000010u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsLeft<ui64>(0b1000000000000000000000000000000000000000000000000000000000000000u, 1), 0b0000000000000000000000000000000000000000000000000000000000000001u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsLeft<ui64>(0b0000000000000000000000000000000000000000000000000000000000000101u, 1), 0b0000000000000000000000000000000000000000000000000000000000001010u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsLeft<ui64>(0b1010000000000000000000000000000000000000000000000000000000000000u, 1), 0b0100000000000000000000000000000000000000000000000000000000000001u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsLeft<ui64>(0b1000000000000000000000000000000000000000000000000000000000000000u, 63), 0b0100000000000000000000000000000000000000000000000000000000000000u);
    }

    Y_UNIT_TEST(TestRotateBitsRight) {
        static_assert(RotateBitsRightCT<ui8>(0b00000000u, 0) == 0b00000000u, "");
        static_assert(RotateBitsRightCT<ui8>(0b00000001u, 0) == 0b00000001u, "");
        static_assert(RotateBitsRightCT<ui8>(0b10000000u, 0) == 0b10000000u, "");
        static_assert(RotateBitsRightCT<ui8>(0b00000001u, 1) == 0b10000000u, "");
        static_assert(RotateBitsRightCT<ui8>(0b10000000u, 1) == 0b01000000u, "");
        static_assert(RotateBitsRightCT<ui8>(0b00000101u, 1) == 0b10000010u, "");
        static_assert(RotateBitsRightCT<ui8>(0b10100000u, 1) == 0b01010000u, "");
        static_assert(RotateBitsRightCT<ui8>(0b00000001u, 7) == 0b00000010u, "");

        UNIT_ASSERT_VALUES_EQUAL(RotateBitsRight<ui8>(0b00000000u, 0), 0b00000000u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsRight<ui8>(0b00000001u, 0), 0b00000001u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsRight<ui8>(0b10000000u, 0), 0b10000000u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsRight<ui8>(0b00000001u, 1), 0b10000000u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsRight<ui8>(0b10000000u, 1), 0b01000000u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsRight<ui8>(0b00000101u, 1), 0b10000010u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsRight<ui8>(0b10100000u, 1), 0b01010000u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsRight<ui8>(0b00000001u, 7), 0b00000010u);

        static_assert(RotateBitsRightCT<ui16>(0b0000000000000000u, 0) == 0b0000000000000000u, "");
        static_assert(RotateBitsRightCT<ui16>(0b0000000000000001u, 0) == 0b0000000000000001u, "");
        static_assert(RotateBitsRightCT<ui16>(0b1000000000000000u, 0) == 0b1000000000000000u, "");
        static_assert(RotateBitsRightCT<ui16>(0b0000000000000001u, 1) == 0b1000000000000000u, "");
        static_assert(RotateBitsRightCT<ui16>(0b1000000000000000u, 1) == 0b0100000000000000u, "");
        static_assert(RotateBitsRightCT<ui16>(0b0000000000000101u, 1) == 0b1000000000000010u, "");
        static_assert(RotateBitsRightCT<ui16>(0b1010000000000000u, 1) == 0b0101000000000000u, "");
        static_assert(RotateBitsRightCT<ui16>(0b0000000000000001u, 15) == 0b0000000000000010u, "");

        UNIT_ASSERT_VALUES_EQUAL(RotateBitsRight<ui16>(0b0000000000000000u, 0), 0b0000000000000000u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsRight<ui16>(0b0000000000000001u, 0), 0b0000000000000001u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsRight<ui16>(0b1000000000000000u, 0), 0b1000000000000000u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsRight<ui16>(0b0000000000000001u, 1), 0b1000000000000000u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsRight<ui16>(0b1000000000000000u, 1), 0b0100000000000000u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsRight<ui16>(0b0000000000000101u, 1), 0b1000000000000010u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsRight<ui16>(0b1010000000000000u, 1), 0b0101000000000000u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsRight<ui16>(0b0000000000000001u, 15), 0b0000000000000010u);

        static_assert(RotateBitsRightCT<ui32>(0b00000000000000000000000000000000u, 0) == 0b00000000000000000000000000000000u, "");
        static_assert(RotateBitsRightCT<ui32>(0b00000000000000000000000000000001u, 0) == 0b00000000000000000000000000000001u, "");
        static_assert(RotateBitsRightCT<ui32>(0b10000000000000000000000000000000u, 0) == 0b10000000000000000000000000000000u, "");
        static_assert(RotateBitsRightCT<ui32>(0b00000000000000000000000000000001u, 1) == 0b10000000000000000000000000000000u, "");
        static_assert(RotateBitsRightCT<ui32>(0b10000000000000000000000000000000u, 1) == 0b01000000000000000000000000000000u, "");
        static_assert(RotateBitsRightCT<ui32>(0b00000000000000000000000000000101u, 1) == 0b10000000000000000000000000000010u, "");
        static_assert(RotateBitsRightCT<ui32>(0b10100000000000000000000000000000u, 1) == 0b01010000000000000000000000000000u, "");
        static_assert(RotateBitsRightCT<ui32>(0b00000000000000000000000000000001u, 31) == 0b00000000000000000000000000000010u, "");

        UNIT_ASSERT_VALUES_EQUAL(RotateBitsRight<ui32>(0b00000000000000000000000000000000u, 0), 0b00000000000000000000000000000000u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsRight<ui32>(0b00000000000000000000000000000001u, 0), 0b00000000000000000000000000000001u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsRight<ui32>(0b10000000000000000000000000000000u, 0), 0b10000000000000000000000000000000u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsRight<ui32>(0b00000000000000000000000000000001u, 1), 0b10000000000000000000000000000000u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsRight<ui32>(0b10000000000000000000000000000000u, 1), 0b01000000000000000000000000000000u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsRight<ui32>(0b00000000000000000000000000000101u, 1), 0b10000000000000000000000000000010u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsRight<ui32>(0b10100000000000000000000000000000u, 1), 0b01010000000000000000000000000000u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsRight<ui32>(0b00000000000000000000000000000001u, 31), 0b00000000000000000000000000000010u);

        static_assert(RotateBitsRightCT<ui64>(0b0000000000000000000000000000000000000000000000000000000000000000u, 0) == 0b0000000000000000000000000000000000000000000000000000000000000000u, "");
        static_assert(RotateBitsRightCT<ui64>(0b0000000000000000000000000000000000000000000000000000000000000001u, 0) == 0b0000000000000000000000000000000000000000000000000000000000000001u, "");
        static_assert(RotateBitsRightCT<ui64>(0b1000000000000000000000000000000000000000000000000000000000000000u, 0) == 0b1000000000000000000000000000000000000000000000000000000000000000u, "");
        static_assert(RotateBitsRightCT<ui64>(0b0000000000000000000000000000000000000000000000000000000000000001u, 1) == 0b1000000000000000000000000000000000000000000000000000000000000000u, "");
        static_assert(RotateBitsRightCT<ui64>(0b1000000000000000000000000000000000000000000000000000000000000000u, 1) == 0b0100000000000000000000000000000000000000000000000000000000000000u, "");
        static_assert(RotateBitsRightCT<ui64>(0b0000000000000000000000000000000000000000000000000000000000000101u, 1) == 0b1000000000000000000000000000000000000000000000000000000000000010u, "");
        static_assert(RotateBitsRightCT<ui64>(0b1010000000000000000000000000000000000000000000000000000000000000u, 1) == 0b0101000000000000000000000000000000000000000000000000000000000000u, "");
        static_assert(RotateBitsRightCT<ui64>(0b0000000000000000000000000000000000000000000000000000000000000001u, 63) == 0b0000000000000000000000000000000000000000000000000000000000000010u, "");

        UNIT_ASSERT_VALUES_EQUAL(RotateBitsRight<ui64>(0b0000000000000000000000000000000000000000000000000000000000000000u, 0), 0b0000000000000000000000000000000000000000000000000000000000000000u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsRight<ui64>(0b0000000000000000000000000000000000000000000000000000000000000001u, 0), 0b0000000000000000000000000000000000000000000000000000000000000001u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsRight<ui64>(0b1000000000000000000000000000000000000000000000000000000000000000u, 0), 0b1000000000000000000000000000000000000000000000000000000000000000u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsRight<ui64>(0b0000000000000000000000000000000000000000000000000000000000000001u, 1), 0b1000000000000000000000000000000000000000000000000000000000000000u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsRight<ui64>(0b1000000000000000000000000000000000000000000000000000000000000000u, 1), 0b0100000000000000000000000000000000000000000000000000000000000000u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsRight<ui64>(0b0000000000000000000000000000000000000000000000000000000000000101u, 1), 0b1000000000000000000000000000000000000000000000000000000000000010u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsRight<ui64>(0b1010000000000000000000000000000000000000000000000000000000000000u, 1), 0b0101000000000000000000000000000000000000000000000000000000000000u);
        UNIT_ASSERT_VALUES_EQUAL(RotateBitsRight<ui64>(0b0000000000000000000000000000000000000000000000000000000000000001u, 63), 0b0000000000000000000000000000000000000000000000000000000000000010u);
    }

    Y_UNIT_TEST(TestSelectBits) {
        ui8 firstui8Test = SelectBits<3, 4, ui8>(0b11111111u);
        ui8 secondui8Test = SelectBits<2, 5, ui8>(0b11101101u);
        UNIT_ASSERT_VALUES_EQUAL(firstui8Test, 0b00001111u);
        UNIT_ASSERT_VALUES_EQUAL(secondui8Test, 0b00011011u);

        ui16 firstui16Test = SelectBits<9, 2, ui16>(0b1111111111111111u);
        ui16 secondui16Test = SelectBits<3, 6, ui16>(0b1010011111010001u);
        UNIT_ASSERT_VALUES_EQUAL(firstui16Test, 0b0000000000000011u);
        UNIT_ASSERT_VALUES_EQUAL(secondui16Test, 0b0000000000111010u);

        ui32 firstui32Test = SelectBits<23, 31, ui32>(0b11111111111111111111111111111111u);
        ui32 secondui32Test = SelectBits<0, 31, ui32>(0b10001011101010011111010000111111u);
        UNIT_ASSERT_VALUES_EQUAL(firstui32Test, 0b00000000000000000000000111111111u);
        UNIT_ASSERT_VALUES_EQUAL(secondui32Test, 0b00001011101010011111010000111111);

        ui64 firstui64Test = SelectBits<1, 62, ui64>(0b1111000000000000000000000000000000000000000000000000000000000000u);
        ui64 secondui64Test = SelectBits<32, 43, ui64>(0b1111111111111111111111111111111111111111111111111111111111111111u);
        UNIT_ASSERT_VALUES_EQUAL(firstui64Test, 0b0011100000000000000000000000000000000000000000000000000000000000u);
        UNIT_ASSERT_VALUES_EQUAL(secondui64Test, 0b0000000000000000000000000000000011111111111111111111111111111111u);
    }

    Y_UNIT_TEST(TestSetBits) {
        ui8 firstui8Test = 0b11111111u;
        SetBits<3, 4, ui8>(firstui8Test, 0b00001111u);
        ui8 secondui8Test = 0b11101101u;
        SetBits<2, 7, ui8>(secondui8Test, 0b01110111u);
        UNIT_ASSERT_VALUES_EQUAL(firstui8Test, 0b11111111u);
        UNIT_ASSERT_VALUES_EQUAL(secondui8Test, 0b11011101u);

        ui16 firstui16Test = 0b1111111111111111u;
        SetBits<9, 4, ui16>(firstui16Test, 0b000000000000111u);
        ui16 secondui16Test = 0b1010011111010001u;
        SetBits<3, 15, ui16>(secondui16Test, 0b0010011111010001u);
        UNIT_ASSERT_VALUES_EQUAL(firstui16Test, 0b1110111111111111u);
        UNIT_ASSERT_VALUES_EQUAL(secondui16Test, 0b0011111010001001u);

        ui32 firstui32Test = 0b11111111111111111111111111111111u;
        SetBits<23, 31, ui32>(firstui32Test, 0b01100001111111111001111101111111u);
        ui32 secondui32Test = 0b10001011101010011111010000111111u;
        SetBits<0, 31, ui32>(secondui32Test, 0b01111111111111111111111111111111u);
        UNIT_ASSERT_VALUES_EQUAL(firstui32Test, 0b10111111111111111111111111111111u);
        UNIT_ASSERT_VALUES_EQUAL(secondui32Test, 0b11111111111111111111111111111111u);

        ui64 firstui64Test = 0b1111000000000000000000000000000000000000000000000000000000000000u;
        SetBits<1, 62, ui64>(firstui64Test, 0b0001000000000000000000000000000000000000000000000000000001010101u);
        ui64 secondui64Test = 0b1111111111111111111111111111111111111111111111111111111111111111u;
        SetBits<32, 43, ui64>(secondui64Test, 0b0000000000000000000000000000000000000111111111111111111111111111u);
        UNIT_ASSERT_VALUES_EQUAL(firstui64Test, 0b1010000000000000000000000000000000000000000000000000000010101010u);
        UNIT_ASSERT_VALUES_EQUAL(secondui64Test, 0b0000011111111111111111111111111111111111111111111111111111111111u);
    }
}

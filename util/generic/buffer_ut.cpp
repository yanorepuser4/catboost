#include <library/unittest/registar.h>

#include <util/system/datetime.h>
#include "string.h"
#include "vector.h"
#include "buffer.h"

SIMPLE_UNIT_TEST_SUITE(TBufferTest) {
    SIMPLE_UNIT_TEST(TestEraseBack) {
        TBuffer buf;

        buf.Append("1234567", 7);
        buf.Reserve(1000);
        buf.Resize(6);
        buf.EraseBack(2);

        UNIT_ASSERT_EQUAL(TString(~buf, +buf), "1234");
    }

    SIMPLE_UNIT_TEST(TestAppend) {
        const char data[] = "1234567890qwertyuiop";

        TBuffer buf(13);
        TString str;

        for (size_t i = 0; i < 10; ++i) {
            for (size_t j = 0; j < sizeof(data) - 1; ++j) {
                buf.Append(data, j);
                buf.Append('q');
                str.append(data, j);
                str.append('q');
            }
        }

        UNIT_ASSERT_EQUAL(TString(~buf, +buf), str);
    }

    SIMPLE_UNIT_TEST(TestReset) {
        char content[] = "some text";
        TBuffer buf;

        buf.Append(content, sizeof(content));
        buf.Clear();

        UNIT_ASSERT(buf.Capacity() != 0);

        buf.Append(content, sizeof(content));
        buf.Reset();

        UNIT_ASSERT_EQUAL(buf.Capacity(), 0);
    }

    SIMPLE_UNIT_TEST(TestResize) {
        char content[] = "some text";
        TBuffer buf;

        buf.Resize(10);
        UNIT_ASSERT_VALUES_EQUAL(+buf, 10u);

        buf.Resize(0);
        UNIT_ASSERT_VALUES_EQUAL(+buf, 0u);

        buf.Resize(9);
        memcpy(~buf, content, 9);
        UNIT_ASSERT_VALUES_EQUAL(TString(~buf, +buf), "some text");

        buf.Resize(4);
        UNIT_ASSERT_VALUES_EQUAL(TString(~buf, +buf), "some");
    }

    SIMPLE_UNIT_TEST(TestReserve) {
        TBuffer buf;
        UNIT_ASSERT_EQUAL(buf.Capacity(), 0);

        buf.Reserve(4);
        UNIT_ASSERT_EQUAL(buf.Capacity(), 4);

        buf.Reserve(6);
        UNIT_ASSERT_EQUAL(buf.Capacity(), 8);

        buf.Reserve(32);
        UNIT_ASSERT_EQUAL(buf.Capacity(), 32);

        buf.Reserve(33);
        UNIT_ASSERT_EQUAL(buf.Capacity(), 64);
        buf.Reserve(64);
        UNIT_ASSERT_EQUAL(buf.Capacity(), 64);

        buf.Resize(128);
        UNIT_ASSERT_EQUAL(buf.Capacity(), 128);

        buf.Append('a');
        UNIT_ASSERT_EQUAL(buf.Capacity(), 256);
        TString tmp1 = "abcdef";
        buf.Append(~tmp1, +tmp1);
        UNIT_ASSERT_EQUAL(buf.Capacity(), 256);

        TString tmp2 = "30498290sfokdsflj2308w";
        buf.Resize(1020);
        buf.Append(~tmp2, +tmp2);
        UNIT_ASSERT_EQUAL(buf.Capacity(), 2048);
    }

    SIMPLE_UNIT_TEST(TestShrinkToFit) {
        TBuffer buf;

        TString content = "some text";
        buf.Append(~content, +content);
        UNIT_ASSERT_EQUAL(buf.Size(), 9);
        UNIT_ASSERT_EQUAL(buf.Capacity(), 16);

        buf.ShrinkToFit();
        UNIT_ASSERT_EQUAL(buf.Size(), 9);
        UNIT_ASSERT_EQUAL(buf.Capacity(), 9);
        UNIT_ASSERT_EQUAL(TString(~buf, +buf), content);

        const size_t MB = 1024 * 1024;
        buf.Resize(MB);
        UNIT_ASSERT_EQUAL(buf.Capacity(), MB);
        buf.ShrinkToFit();
        UNIT_ASSERT_EQUAL(buf.Capacity(), MB);
        buf.Resize(MB + 100);
        UNIT_ASSERT_EQUAL(buf.Capacity(), 2 * MB);
        buf.ShrinkToFit();
        UNIT_ASSERT_EQUAL(buf.Capacity(), MB + 100);
    }

#if 0
SIMPLE_UNIT_TEST(TestAlignUp) {
    char content[] = "some text";
    TBuffer buf;

    buf.Append(content, sizeof(content));
    buf.AlignUp(4, '!');

    UNIT_ASSERT(buf.Size() % 4 == 0);
    UNIT_ASSERT_VALUES_EQUAL(TString(~buf, +buf), "some text!!!");

    char addContent[] = "1234";
    buf.Append(addContent, sizeof(addContent));
    buf.AlignUp(4, 'X');
    UNIT_ASSERT(buf.Size() % 4 == 0);
    UNIT_ASSERT_VALUES_EQUAL(TString(~buf, +buf), "some text!!!1234");
}
#endif

#if 0
SIMPLE_UNIT_TEST(TestSpeed) {
    const char data[] = "1234567890qwertyuiop";
    const size_t c = 100000;
    ui64 t1 = 0;
    ui64 t2 = 0;

    {
        TBuffer buf;

        t1 = MicroSeconds();

        for (size_t i = 0; i < c; ++i) {
            buf.Append(data, sizeof(data));
        }

        t1 = MicroSeconds() - t1;
    }

    {
        yvector<char> buf;

        t2 = MicroSeconds();

        for (size_t i = 0; i < c; ++i) {
            buf.insert(buf.end(), data, data + sizeof(data));
        }

        t2 = MicroSeconds() - t2;
    }

    UNIT_ASSERT(t1 < t2);
}
#endif

    SIMPLE_UNIT_TEST(TestFillAndChop) {
        TBuffer buf;
        buf.Append("Some ", 5);
        buf.Fill('!', 5);
        buf.Append(" text.", 6);
        UNIT_ASSERT_VALUES_EQUAL(TString(~buf, +buf), "Some !!!!! text.");

        buf.Chop(5, 6);
        UNIT_ASSERT_VALUES_EQUAL(TString(~buf, +buf), "Some text.");
    }

} // TBufferTest

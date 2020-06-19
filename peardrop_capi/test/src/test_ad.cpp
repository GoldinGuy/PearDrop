#include <gtest/gtest.h>
#include <peardrop.h>

constexpr uint8_t TCP_EXTENSION_TYPE = 0;

TEST(adpacket, read) {
    uint8_t data[] = {
        0, /* ext_len */
    };
    adpacket* packet = adpacket_read(data, sizeof(data));
    ASSERT_NE(packet, nullptr);
    // closest thing we have to ext len
    uint16_t port;
    ASSERT_EQ(adpacket_ext_tcp_get(packet, &port), 0);
    EXPECT_EQ(port, 0);
    adpacket_free(packet);
}

TEST(adpacket, write) {
    uint8_t expected[] = {
        0, /* ext_len */
    };
    adpacket* packet = adpacket_create();
    ASSERT_NE(packet, nullptr);
    uint8_t* out;
    uintptr_t len;
    ASSERT_EQ(adpacket_write(packet, &out, &len), 0);
    EXPECT_EQ(memcmp(out, expected, sizeof(expected)), 0);
    adpacket_free(packet);
}

TEST(adext, tcp_read) {
    uint16_t port = 14678;
    uint8_t data[] = {
        1, /* ext_len */
        /* tcp_extension */
        TCP_EXTENSION_TYPE,
        static_cast<uint8_t>((port >> 8) & 0xff),
        static_cast<uint8_t>(port & 0xff),
    };
    adpacket* packet = adpacket_read(data, sizeof(data));
    ASSERT_NE(packet, nullptr);
    uint16_t port2;
    ASSERT_EQ(adpacket_ext_tcp_get(packet, &port2), 0);
    EXPECT_EQ(port, port2);
    adpacket_free(packet);
}

TEST(adext, tcp_write) {
    uint16_t port = 14678;
    adpacket* packet = adpacket_create();
    ASSERT_NE(packet, nullptr);
    ASSERT_EQ(adpacket_ext_tcp_update(packet, port), 0);
    uint8_t expected[] = {
        1, /* ext_len */
        /* tcp_extension */
        TCP_EXTENSION_TYPE,
        static_cast<uint8_t>((port >> 8) & 0xff),
        static_cast<uint8_t>(port & 0xff),
    };
    uint8_t* out;
    uintptr_t len;
    ASSERT_EQ(adpacket_write(packet, &out, &len), 0);
    EXPECT_EQ(memcmp(out, expected, sizeof(expected)), 0);
    adpacket_free(packet);
}

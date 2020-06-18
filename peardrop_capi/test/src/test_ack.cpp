#include <gtest/gtest.h>
#include <peardrop.h>

constexpr uint8_t ACKTYPETYPE_AD_PACKET = 2;
constexpr uint8_t ACKTYPETYPE_DATA_PACKET = 1;
constexpr uint8_t ACKTYPETYPE_SENDER_PACKET = 0;

constexpr uint8_t ACK_TCP_EXTENSION_TYPE = 0;

TEST(acktype, data) {
  acktype* type = acktype_from_raw(ACKTYPETYPE_DATA_PACKET);
  ASSERT_NE(type, nullptr);
  uint8_t type2;
  ASSERT_EQ(acktype_get_type(type, &type2), 0);
  EXPECT_EQ(type2, ACKTYPETYPE_DATA_PACKET);
  uint8_t is_accepted;
  ASSERT_EQ(acktype_is_accepted(type, &is_accepted), 0);
  EXPECT_EQ(is_accepted, 0);
  uint8_t raw;
  ASSERT_EQ(acktype_to_raw(type, &raw), 0);
  EXPECT_EQ(raw, ACKTYPETYPE_DATA_PACKET);
  acktype_free(type);
}

TEST(acktype, sender_reject) {
  uint8_t data = 0 << 3 | ACKTYPETYPE_SENDER_PACKET;
  acktype* type = acktype_from_raw(data);
  ASSERT_NE(type, nullptr);
  uint8_t type2;
  ASSERT_EQ(acktype_get_type(type, &type2), 0);
  EXPECT_EQ(type2, ACKTYPETYPE_SENDER_PACKET);
  uint8_t is_accepted;
  ASSERT_EQ(acktype_is_accepted(type, &is_accepted), 0);
  EXPECT_EQ(is_accepted, 0);
  uint8_t raw;
  ASSERT_EQ(acktype_to_raw(type, &raw), 0);
  EXPECT_EQ(raw, data);
  acktype_free(type);
}

TEST(acktype, sender_accept) {
  uint8_t data = 1 << 3 | ACKTYPETYPE_SENDER_PACKET;
  acktype* type = acktype_from_raw(data);
  ASSERT_NE(type, nullptr);
  uint8_t type2;
  ASSERT_EQ(acktype_get_type(type, &type2), 0);
  EXPECT_EQ(type2, ACKTYPETYPE_SENDER_PACKET);
  uint8_t is_accepted;
  ASSERT_EQ(acktype_is_accepted(type, &is_accepted), 0);
  EXPECT_EQ(is_accepted, 1);
  uint8_t raw;
  ASSERT_EQ(acktype_to_raw(type, &raw), 0);
  EXPECT_EQ(raw, data);
  acktype_free(type);
}

TEST(acktype, ad_reject) {
  uint8_t data = 0 << 3 | ACKTYPETYPE_AD_PACKET;
  acktype* type = acktype_from_raw(data);
  ASSERT_NE(type, nullptr);
  uint8_t type2;
  ASSERT_EQ(acktype_get_type(type, &type2), 0);
  EXPECT_EQ(type2, ACKTYPETYPE_AD_PACKET);
  uint8_t is_accepted;
  ASSERT_EQ(acktype_is_accepted(type, &is_accepted), 0);
  EXPECT_EQ(is_accepted, 0);
  uint8_t raw;
  ASSERT_EQ(acktype_to_raw(type, &raw), 0);
  EXPECT_EQ(raw, data);
  acktype_free(type);
}

TEST(acktype, ad_accept) {
  uint8_t data = 1 << 3 | ACKTYPETYPE_AD_PACKET;
  acktype* type = acktype_from_raw(data);
  ASSERT_NE(type, nullptr);
  uint8_t type2;
  ASSERT_EQ(acktype_get_type(type, &type2), 0);
  EXPECT_EQ(type2, ACKTYPETYPE_AD_PACKET);
  uint8_t is_accepted;
  ASSERT_EQ(acktype_is_accepted(type, &is_accepted), 0);
  EXPECT_EQ(is_accepted, 1);
  uint8_t raw;
  ASSERT_EQ(acktype_to_raw(type, &raw), 0);
  EXPECT_EQ(raw, data);
  acktype_free(type);
}


TEST(ackpacket, write) {
  acktype* type = acktype_create_normal(ACKTYPETYPE_DATA_PACKET);
  uint8_t raw;
  ASSERT_NE(type, nullptr);
  ASSERT_EQ(acktype_to_raw(type, &raw), 0);
  ackpacket* packet = ackpacket_create(type);
  ASSERT_NE(packet, nullptr);
  uint8_t expected[] = {
      static_cast<uint8_t>(raw << 4 | 0),
  };
  uint8_t* out;
  uintptr_t len;
  ASSERT_EQ(ackpacket_write(packet, &out, &len), 0);
  EXPECT_EQ(memcmp(out, expected, sizeof(expected)), 0);
  ackpacket_free(packet);
}

TEST(ackext, tcp_read) {
  acktype* type = acktype_create_accept(ACKTYPETYPE_AD_PACKET);
  uint8_t raw;
  ASSERT_NE(type, nullptr);
  ASSERT_EQ(acktype_to_raw(type, &raw), 0);
  uint16_t port = 14678;
  uint8_t data[] = {
      static_cast<uint8_t>(raw << 4 | 1), /* ext_len */
      ACK_TCP_EXTENSION_TYPE,
      static_cast<uint8_t>((port >> 8) & 0xff),
      static_cast<uint8_t>(port & 0xff),
  };
  ackpacket* packet = ackpacket_read(data, sizeof(data));
  ASSERT_NE(packet, nullptr);
  uint16_t port2;
  ASSERT_EQ(ackpacket_ext_tcp_get(packet, &port2), 0);
  EXPECT_EQ(port, port2);
  ackpacket_free(packet);
}

TEST(ackext, tcp_write) {
  acktype* type = acktype_create_accept(ACKTYPETYPE_AD_PACKET);
  uint8_t raw;
  ASSERT_NE(type, nullptr);
  ASSERT_EQ(acktype_to_raw(type, &raw), 0);
  uint16_t port = 14678;
  uint8_t expected[] = {
      static_cast<uint8_t>(raw << 4 | 1), /* ext_len */
      ACK_TCP_EXTENSION_TYPE,
      static_cast<uint8_t>((port >> 8) & 0xff),
      static_cast<uint8_t>(port & 0xff),
  };
  ackpacket* packet = ackpacket_create(type);
  ASSERT_EQ(ackpacket_ext_tcp_update(packet, port), 0);
  uint8_t* out;
  uintptr_t len;
  ASSERT_EQ(ackpacket_write(packet, &out, &len), 0);
  EXPECT_EQ(memcmp(out, expected, sizeof(expected)), 0);
  ackpacket_free(packet);
}

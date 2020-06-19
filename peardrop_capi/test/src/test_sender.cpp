#include <cstring>
#include <vector>
#include <string>
#include <gtest/gtest.h>
#include <peardrop.h>

TEST(sender, read) {
    const std::string& filename = "example.txt";
    const std::string& mimetype = "text/plain";
    uint64_t data_len = 278475344;
    uint32_t triple_byte = (filename.size() << 12) | mimetype.size();
    std::vector<uint8_t> data;
    data.push_back(triple_byte >> 16 & 0xff);
    data.push_back(triple_byte >> 8 & 0xff);
    data.push_back(triple_byte & 0xff);
    data.insert(data.end(), filename.begin(), filename.end());
    data.insert(data.end(), mimetype.begin(), mimetype.end());
    data.push_back(0); // exts_len
    data.push_back(data_len >> 56 & 0xff);
    data.push_back(data_len >> 48 & 0xff);
    data.push_back(data_len >> 40 & 0xff);
    data.push_back(data_len >> 32 & 0xff);
    data.push_back(data_len >> 24 & 0xff);
    data.push_back(data_len >> 16 & 0xff);
    data.push_back(data_len >> 8 & 0xff);
    data.push_back(data_len & 0xff);

    senderpacket* packet = senderpacket_read(data.data(), data.size());
    ASSERT_NE(packet, nullptr);
    // no way to check ext_len :(
    uint8_t* filename2 = senderpacket_get_filename(packet);
    ASSERT_NE(filename2, nullptr);
    EXPECT_EQ(strncmp(
        reinterpret_cast<char*>(filename2),
        filename.c_str(),
        filename.size()
    ), 0);
    string_free(filename2);
    uint8_t* mimetype2 = senderpacket_get_mimetype(packet);
    ASSERT_NE(mimetype2, nullptr);
    EXPECT_EQ(strncmp(
        reinterpret_cast<char*>(mimetype2),
        mimetype.c_str(),
        mimetype.size()
    ), 0);
    string_free(mimetype2);
    uint64_t data_len2;
    ASSERT_EQ(senderpacket_get_data_length(packet, &data_len2), 0);
    EXPECT_EQ(data_len, data_len2);
    senderpacket_free(packet);
}

TEST(sender, write) {
    const std::string& filename = "example.txt";
    const std::string& mimetype = "text/plain";
    uint64_t data_len = 278475344;
    uint32_t triple_byte = (filename.size() << 12) | mimetype.size();
    std::vector<uint8_t> expected;
    expected.push_back(triple_byte >> 16 & 0xff);
    expected.push_back(triple_byte >> 8 & 0xff);
    expected.push_back(triple_byte & 0xff);
    expected.insert(expected.end(), filename.begin(), filename.end());
    expected.insert(expected.end(), mimetype.begin(), mimetype.end());
    expected.push_back(0); // exts_len
    expected.push_back(data_len >> 56 & 0xff);
    expected.push_back(data_len >> 48 & 0xff);
    expected.push_back(data_len >> 40 & 0xff);
    expected.push_back(data_len >> 32 & 0xff);
    expected.push_back(data_len >> 24 & 0xff);
    expected.push_back(data_len >> 16 & 0xff);
    expected.push_back(data_len >> 8 & 0xff);
    expected.push_back(data_len & 0xff);

    senderpacket* packet = senderpacket_create(
        reinterpret_cast<const uint8_t*>(filename.c_str()),
        reinterpret_cast<const uint8_t*>(mimetype.c_str()),
        data_len
    );
    ASSERT_NE(packet, nullptr);
    uint8_t* out;
    uintptr_t len;
    ASSERT_EQ(senderpacket_write(packet, &out, &len), 0);
    EXPECT_EQ(memcmp(out, expected.data(), expected.size()), 0);
    senderpacket_free(packet);
}

#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

typedef void ackpacket;

typedef void acktype;

typedef void adpacket;

typedef void senderpacket;

#ifdef __cplusplus
extern "C" {
#endif // __cplusplus

/**
 * Frees an AckPacket.
 */
void ackpacket_free(ackpacket *packet);

/**
 * Creates an AckPacket from the given buffer.
 *
 * Returns NULL on error.
 */
ackpacket *ackpacket_read(const uint8_t *buf, uintptr_t len);

/**
 * Writes an AckPacket to a buffer and returns it.
 *
 * Returns non-zero on error.
 */
int32_t ackpacket_write(const ackpacket *packet, uint8_t **out_buf, uintptr_t *out_len);

/**
 * Creates an AckType that is accepting.
 *
 * Returns NULL on error.
 */
acktype *acktype_create_accept(uint8_t type_);

/**
 * Creates a normal AckType.
 *
 * Returns NULL on error.
 */
acktype *acktype_create_normal(uint8_t type_);

/**
 * Creates an AckType that is rejecting.
 *
 * Returns NULL on error.
 */
acktype *acktype_create_reject(uint8_t type_);

/**
 * Frees an AckType.
 */
void acktype_free(acktype *type_);

/**
 * Frees an AdPacket.
 */
void adpacket_free(adpacket *packet);

/**
 * Creates an AdPacket from the given buffer.
 *
 * Returns NULL on error.
 */
adpacket *adpacket_read(const uint8_t *buf, int32_t len);

/**
 * Writes an AdPacket to a buffer and returns it.
 *
 * Returns non-zero on error.
 */
int32_t adpacket_write(const adpacket *packet, uint8_t **out_buf, uintptr_t *out_len);

/**
 * Frees a SenderPacket.
 */
void senderpacket_free(senderpacket *packet);

/**
 * Get the data length of a SenderPacket.
 *
 * Returns non-zero on error.
 */
int32_t senderpacket_get_data_length(const senderpacket *packet, uint64_t *out_len);

/**
 * Get the filename of a SenderPacket.
 *
 * Returns NULL on error.
 */
uint8_t *senderpacket_get_filename(const senderpacket *packet);

/**
 * Get the MIME type of a SenderPacket.
 *
 * Returns NULL on error.
 */
uint8_t *senderpacket_get_mimetype(const senderpacket *packet);

/**
 * Creates a SenderPacket from the given buffer.
 *
 * Returns NULL on error.
 */
senderpacket *senderpacket_read(const uint8_t *buf, int32_t len);

/**
 * Writes a SenderPacket to a buffer and returns it.
 *
 * Returns non-zero on error.
 */
int32_t senderpacket_write(const senderpacket *packet, uint8_t **out_buf, uintptr_t *out_len);

/**
 * Frees a string previously retrieved from this API.
 */
void string_free(uint8_t *s);

#ifdef __cplusplus
} // extern "C"
#endif // __cplusplus

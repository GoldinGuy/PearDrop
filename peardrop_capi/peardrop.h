#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

typedef void ackpacket;

typedef void acktype;

typedef void adpacket;

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

#ifdef __cplusplus
} // extern "C"
#endif // __cplusplus

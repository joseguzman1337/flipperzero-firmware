/**
 * @file buffer_stream.h
<<<<<<< HEAD
 * 
=======
 *
>>>>>>> origin/dev
 * This file implements the concept of a buffer stream.
 * Data is written to the buffer until the buffer is full.
 * Then the buffer pointer is written to the stream, and the new write buffer is taken from the buffer pool.
 * After the buffer has been read by the receiving thread, it is sent to the free buffer pool.
<<<<<<< HEAD
 * 
=======
 *
>>>>>>> origin/dev
 * This will speed up sending large chunks of data between threads, compared to using a stream directly.
 */
#pragma once
#include <furi.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct Buffer Buffer;

/**
 * @brief Get buffer data pointer
<<<<<<< HEAD
 * @param buffer 
 * @return uint8_t* 
=======
 * @param buffer
 * @return uint8_t*
>>>>>>> origin/dev
 */
uint8_t* buffer_get_data(Buffer* buffer);

/**
 * @brief Get buffer size
<<<<<<< HEAD
 * @param buffer 
 * @return size_t 
=======
 * @param buffer
 * @return size_t
>>>>>>> origin/dev
 */
size_t buffer_get_size(Buffer* buffer);

/**
 * @brief Reset buffer and send to free buffer pool
<<<<<<< HEAD
 * @param buffer 
=======
 * @param buffer
>>>>>>> origin/dev
 */
void buffer_reset(Buffer* buffer);

typedef struct BufferStream BufferStream;

/**
 * @brief Allocate a new BufferStream instance
<<<<<<< HEAD
 * @param buffer_size 
 * @param buffers_count 
 * @return BufferStream* 
=======
 * @param buffer_size
 * @param buffers_count
 * @return BufferStream*
>>>>>>> origin/dev
 */
BufferStream* buffer_stream_alloc(size_t buffer_size, size_t buffers_count);

/**
 * @brief Free a BufferStream instance
<<<<<<< HEAD
 * @param buffer_stream 
=======
 * @param buffer_stream
>>>>>>> origin/dev
 */
void buffer_stream_free(BufferStream* buffer_stream);

/**
 * @brief Write data to buffer stream, from ISR context
 * Data will be written to the buffer until the buffer is full, and only then will the buffer be sent.
<<<<<<< HEAD
 * @param buffer_stream 
 * @param data 
 * @param size 
 * @return bool 
=======
 * @param buffer_stream
 * @param data
 * @param size
 * @return bool
>>>>>>> origin/dev
 */
bool buffer_stream_send_from_isr(BufferStream* buffer_stream, const uint8_t* data, size_t size);

/**
 * @brief Receive buffer from stream
<<<<<<< HEAD
 * @param buffer_stream 
 * @param timeout 
 * @return Buffer* 
=======
 * @param buffer_stream
 * @param timeout
 * @return Buffer*
>>>>>>> origin/dev
 */
Buffer* buffer_stream_receive(BufferStream* buffer_stream, uint32_t timeout);

/**
 * @brief Get stream overrun count
<<<<<<< HEAD
 * @param buffer_stream 
 * @return size_t 
=======
 * @param buffer_stream
 * @return size_t
>>>>>>> origin/dev
 */
size_t buffer_stream_get_overrun_count(BufferStream* buffer_stream);

/**
 * @brief Reset stream and buffer pool
<<<<<<< HEAD
 * @param buffer_stream 
=======
 * @param buffer_stream
>>>>>>> origin/dev
 */
void buffer_stream_reset(BufferStream* buffer_stream);

#ifdef __cplusplus
}
#endif

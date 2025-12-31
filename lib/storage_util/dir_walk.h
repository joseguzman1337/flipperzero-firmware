#pragma once
#include <storage/storage.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct DirWalk DirWalk;

typedef enum {
    DirWalkOK, /**< OK */
    DirWalkError, /**< Error */
    DirWalkLast, /**< Last element */
} DirWalkResult;

typedef bool (*DirWalkFilterCb)(const char* name, FileInfo* fileinfo, void* ctx);

/**
 * Allocate DirWalk
<<<<<<< HEAD
 * @param storage 
 * @return DirWalk* 
=======
 * @param storage
 * @return DirWalk*
>>>>>>> origin/dev
 */
DirWalk* dir_walk_alloc(Storage* storage);

/**
 * Free DirWalk
<<<<<<< HEAD
 * @param dir_walk 
=======
 * @param dir_walk
>>>>>>> origin/dev
 */
void dir_walk_free(DirWalk* dir_walk);

/**
 * Set recursive mode (true by default)
<<<<<<< HEAD
 * @param dir_walk 
 * @param recursive 
=======
 * @param dir_walk
 * @param recursive
>>>>>>> origin/dev
 */
void dir_walk_set_recursive(DirWalk* dir_walk, bool recursive);

/**
 * Set filter callback (Should return true if the data is valid)
<<<<<<< HEAD
 * @param dir_walk 
 * @param cb 
 * @param context 
=======
 * @param dir_walk
 * @param cb
 * @param context
>>>>>>> origin/dev
 */
void dir_walk_set_filter_cb(DirWalk* dir_walk, DirWalkFilterCb cb, void* context);

/**
<<<<<<< HEAD
 * Open directory 
 * @param dir_walk 
 * @param path 
 * @return true 
 * @return false 
=======
 * Open directory
 * @param dir_walk
 * @param path
 * @return true
 * @return false
>>>>>>> origin/dev
 */
bool dir_walk_open(DirWalk* dir_walk, const char* path);

/**
 * Get error id
<<<<<<< HEAD
 * @param dir_walk 
 * @return FS_Error 
=======
 * @param dir_walk
 * @return FS_Error
>>>>>>> origin/dev
 */
FS_Error dir_walk_get_error(DirWalk* dir_walk);

/**
 * Read next element from directory
<<<<<<< HEAD
 * @param dir_walk 
 * @param return_path 
 * @param fileinfo 
 * @return DirWalkResult 
=======
 * @param dir_walk
 * @param return_path
 * @param fileinfo
 * @return DirWalkResult
>>>>>>> origin/dev
 */
DirWalkResult dir_walk_read(DirWalk* dir_walk, FuriString* return_path, FileInfo* fileinfo);

/**
 * Close directory
<<<<<<< HEAD
 * @param dir_walk 
=======
 * @param dir_walk
>>>>>>> origin/dev
 */
void dir_walk_close(DirWalk* dir_walk);

#ifdef __cplusplus
}
#endif

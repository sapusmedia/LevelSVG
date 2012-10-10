#import <Foundation/Foundation.h>
#import "zlib.h"

@interface NSData (DDData)

// gzip compression utilities
- (NSData *)gzipInflate;
- (NSData *)gzipDeflate;

@end
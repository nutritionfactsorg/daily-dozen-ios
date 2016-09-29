//
//  SQLiteFormat.m
//  Amigo
//
//  Created by Adam Venturella on 1/14/16.
//  Copyright © 2016 BLITZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"
#import "SQLiteFormat.h"

@implementation SQLiteFormat
+ (nonnull NSString *)format:(nullable char *)format, ...{
    va_list ap;
    va_start(ap, format);

    char *result = sqlite3_vmprintf(format, ap);
    NSString * string = @(result);
    sqlite3_free(result);

    va_end(ap);
    return string;
}

+ (nonnull NSString *)escapeWithQuotes:(nullable NSString *)value{
    const char* utf8 = value.UTF8String;
    return [SQLiteFormat format:"%Q", utf8];
}

+ (nonnull NSString *)escapeWithoutQuotes:(nullable NSString *)value{
    const char* utf8 = value.UTF8String;
    return [SQLiteFormat format:"%q", utf8];
}

+ (nonnull NSString *)escapeBlob:(nullable NSData *)value {
    if (value == nil){
        return [self escapeWithQuotes: nil];
    }

    NSString* hex = [self hexStringWithData:value];

    if (hex == [NSString string]){
        return [self escapeWithQuotes: nil];
    }

    NSString* escapedHex = [self escapeWithoutQuotes: hex];

    // http://permalink.gmane.org/gmane.comp.db.sqlite.general/64150
    // https://www.sqlite.org/lang_expr.html
    // BLOB literals are string literals containing hexadecimal data and
    // preceded by a single "x" or "X" character. Example: X'53514C697465'
    NSString* result = [NSString stringWithFormat:@"x'%@'", escapedHex];

    return result;
}

+ (nonnull NSString *)hexStringWithData:(nonnull NSData *)data{
    // https://gist.github.com/hlung/6333269

    const unsigned char* dataBuffer = (const unsigned char *)[data bytes];
    NSUInteger dataLength  = [data length];

    if (!dataBuffer) {
        return [NSString string];
    }

    NSMutableString* hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];

    for (int i = 0; i < dataLength; ++i) {
        [hexString appendString:[NSString stringWithFormat: @"%02lx", (unsigned long)dataBuffer[i]]];
    }

    return [NSString stringWithString: [hexString lowercaseString]];
}

@end

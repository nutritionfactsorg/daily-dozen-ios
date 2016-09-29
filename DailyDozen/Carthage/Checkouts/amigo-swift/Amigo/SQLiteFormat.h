//
//  SQLiteFormat.h
//  Amigo
//
//  Created by Adam Venturella on 1/14/16.
//  Copyright © 2016 BLITZ. All rights reserved.
//

#pragma once

@interface SQLiteFormat : NSObject
+ (nonnull NSString *)format:(nullable char *)format, ...;
+ (nonnull NSString *)escapeWithQuotes:(nullable NSString *)value;
+ (nonnull NSString *)escapeWithoutQuotes:(nullable NSString *)value;
+ (nonnull NSString *)escapeBlob:(nullable NSData *)value;
+ (nonnull NSString *)hexStringWithData:(nonnull NSData *)data;
@end


//
//  FMDatabase+SQLCipher.m
//  FMDB
//
//  Created by Micah T. Moore on 9/29/25.
//

#import <Foundation/Foundation.h>
#import "FMDatabase+SQLCipher.h"
#if SQLCIPHER_CRYPTO
#import <SQLCipher/sqlite3.h>
#endif

@implementation FMDatabase (SQLCipher)

@dynamic cipherVersion;
@dynamic cipherFipsStatus;
@dynamic cipherProvider;
@dynamic cipherProviderVersion;

- (NSString *)cipherVersion {
    NSString *ver = nil;
#ifdef SQLITE_HAS_CODEC
    FMResultSet *rs = [self executeQuery:@"PRAGMA cipher_version;"];
    if ([rs next]) {
        ver = rs.resultDictionary[@"cipher_version"];
        [rs close];
    }
#endif
    return ver;
}

- (NSString *)cipherFipsStatus {
    NSString *fipsStatus = nil;
#ifdef SQLITE_HAS_CODEC
    FMResultSet *rs = [self executeQuery:@"PRAGMA cipher_fips_status;"];
    if ([rs next]) {
        fipsStatus = rs.resultDictionary[@"cipher_fips_status"];
        [rs close];
    }
#endif
    return fipsStatus;
}

- (NSString *)cipherProvider {
    NSString *provider = nil;
#ifdef SQLITE_HAS_CODEC
    FMResultSet *rs = [self executeQuery:@"PRAGMA cipher_provider;"];
    if ([rs next]) {
        provider = rs.resultDictionary[@"cipher_provider"];
        [rs close];
    }
#endif
    return provider;
}

- (NSString *)cipherProviderVersion {
    NSString *providerVer = nil;
#ifdef SQLITE_HAS_CODEC
    FMResultSet *rs = [self executeQuery:@"PRAGMA cipher_provider_version;"];
    if ([rs next]) {
        providerVer = rs.resultDictionary[@"cipher_provider_version"];
        [rs close];
    }
#endif
    return providerVer;
}

#pragma mark Key routines

- (BOOL)rekey:(NSString*)key {
    NSData *keyData = [NSData dataWithBytes:(void *)[key UTF8String] length:(NSUInteger)strlen([key UTF8String])];

    return [self rekeyWithData:keyData];
}

- (BOOL)rekeyWithData:(NSData *)keyData {
#ifdef SQLITE_HAS_CODEC
    if (!keyData) {
        return NO;
    }

    int rc = sqlite3_rekey([self sqliteHandle], [keyData bytes], (int)[keyData length]);

    if (rc != SQLITE_OK) {
        NSLog(@"error on rekey: %d", rc);
        NSLog(@"%@", [self lastErrorMessage]);
    }

    return (rc == SQLITE_OK);
#else
#pragma unused(keyData)
    return NO;
#endif
}

- (BOOL)setKey:(NSString*)key {
    NSData *keyData = [NSData dataWithBytes:[key UTF8String] length:(NSUInteger)strlen([key UTF8String])];

    return [self setKeyWithData:keyData];
}

- (BOOL)setKeyWithData:(NSData *)keyData {
#ifdef SQLITE_HAS_CODEC
    if (!keyData) {
        return NO;
    }

    int rc = sqlite3_key([self sqliteHandle], [keyData bytes], (int)[keyData length]);

    return (rc == SQLITE_OK);
#else
#pragma unused(keyData)
    return NO;
#endif
}

- (BOOL)applyLicense:(NSString *)licenseCode {
    BOOL execSuccess = NO;
#ifdef SQLITE_HAS_CODEC
    if (licenseCode != nil && licenseCode.length > 0) {
        NSString *licensePragma = [NSString stringWithFormat:@"PRAGMA cipher_license = '%@';", licenseCode];
        execSuccess = [self executeStatements:licensePragma];
    }
#endif
    return execSuccess;
}

- (BOOL)enableCipherLogging:(CipherLogLevel)logLevel {
    BOOL execSuccess = NO;
#ifdef SQLITE_HAS_CODEC
    execSuccess = [self executeStatements:@"PRAGMA cipher_log = device;"];
    NSString *logLevelString = [self _logLevelString:logLevel];
    NSString *logLevelPragma = [NSString stringWithFormat:@"PRAGMA cipher_log_level = %@;", logLevelString];
    execSuccess &= [self executeStatements:logLevelPragma];
#endif
    return execSuccess;
}

- (BOOL)disableCipherLogging {
#ifdef SQLITE_HAS_CODEC
    return [self executeStatements:@"PRAGMA cipher_log_level = NONE;"];
#endif
    return NO;
}

- (NSString *)_logLevelString:(CipherLogLevel)logLevel {
    switch (logLevel) {
        case CipherLogLevelNone:
            return @"NONE";
        case CipherLogLevelError:
            return @"ERROR";
        case CipherLogLevelWarn:
            return @"WARN";
        case CipherLogLevelInfo:
            return @"INFO";
        case CipherLogLevelDebug:
            return @"DEBUG";
        case CipherLogLevelTrace:
            return @"TRACE";
        default:
            return @"NONE";
    }
}



@end

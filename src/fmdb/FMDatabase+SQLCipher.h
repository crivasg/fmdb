//
//  FMDatabase+SQLCipher.h
//  FMDB
//
//  Created by Micah T. Moore on 9/29/25.
//

#import "FMDatabase.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    CipherLogLevelNone,
    CipherLogLevelError,
    CipherLogLevelWarn,
    CipherLogLevelInfo,
    CipherLogLevelDebug,
    CipherLogLevelTrace
} CipherLogLevel;

@interface FMDatabase (SQLCipher)

/// - Returns: the SQLCipher version
///
/// See https://www.zetetic.net/sqlcipher/sqlcipher-api/#cipher_version
@property (readonly, strong, nullable) NSString *cipherVersion;

/// - Returns: the SQLCipher fips status: 1 for fips mode, 0 for non-fips mode
/// The FIPS status will not be initialized until the database connection has been keyed
///
/// See https://www.zetetic.net/sqlcipher/sqlcipher-api/#cipher_fips_status
@property (readonly, strong, nullable) NSString *cipherFipsStatus;

/// - Returns: the SQLCipher fips status: 1 for fips mode, 0 for non-fips mode
/// The FIPS status will not be initialized until the database connection has been keyed
///
/// See https://www.zetetic.net/sqlcipher/sqlcipher-api/#cipher_fips_status
@property (readonly, strong, nullable) NSString *cipherProvider;

/// - Returns: the version number provided from the compiled crypto provider.
/// This value, if known, is available only after the database has been keyed.
///
/// See https://www.zetetic.net/sqlcipher/sqlcipher-api/#cipher_provider_version
@property (readonly, strong, nullable) NSString *cipherProviderVersion;


///-------------------------
/// @name Encryption methods
///-------------------------

/** Set encryption key.

 @param key The key to be used.

 @return @c YES if success, @c NO on error.

 @see https://www.zetetic.net/sqlcipher/

 @warning You need to have purchased the sqlite encryption extensions for this method to work.
 */

- (BOOL)setKey:(NSString*)key;

/** Reset encryption key

 @param key The key to be used.

 @return @c YES if success, @c NO on error.

 @see https://www.zetetic.net/sqlcipher/

 @warning You need to have purchased the sqlite encryption extensions for this method to work.
 */

- (BOOL)rekey:(NSString*)key;

/** Set encryption key using `keyData`.

 @param keyData The @c NSData  to be used.

 @return @c YES if success, @c NO on error.

 @see https://www.zetetic.net/sqlcipher/

 @warning You need to have purchased the sqlite encryption extensions for this method to work.
 */

- (BOOL)setKeyWithData:(NSData *)keyData;

/** Reset encryption key using `keyData`.

 @param keyData The @c NSData  to be used.

 @return @c YES if success, @c NO on error.

 @see https://www.zetetic.net/sqlcipher/

 @warning You need to have purchased the sqlite encryption extensions for this method to work.
 */

- (BOOL)rekeyWithData:(NSData *)keyData;

/// When using Commercial or Enterprise SQLCipher packages you must call
/// `PRAGMA cipher_license` with a valid license code prior to executing
/// cryptographic operations on an encrypted database.
/// Failure to provide a license code, or use of an expired trial code,
/// will result in an `SQLITE_AUTH (23)` error code reported from the SQLite API
/// License Codes will activate SQLCipher Commercial or Enterprise packages
/// from Zetetic: https://www.zetetic.net/sqlcipher/buy/
/// 15-day free trials are available by request: https://www.zetetic.net/sqlcipher/trial/
///
/// See https://www.zetetic.net/sqlcipher/sqlcipher-api/#cipher_license
/// - Parameter license: base64 SQLCipher license code to activate SQLCipher commercial
/// - Return YES if success NO on error.
- (BOOL)applyLicense:(NSString *)licenseCode;

/// Instructs SQLCipher to log internal debugging and operational information
/// to the sepecified log target (device) using `os_log`
/// The supplied logLevel will determine the granularity of the logs output
/// Available logLevel options are: NONE, ERROR, WARN, INFO, DEBUG, TRACE
/// Note that each level is more verbose than the last,
/// and particularly with DEBUG and TRACE the logging system will generate
/// a significant log volume
///
/// See https://www.zetetic.net/sqlcipher/sqlcipher-api/#cipher_log
/// - Parameter logLevel: CipherLogLevel The granularity to use for the logging system
/// - Return YES if success NO on error.
- (BOOL)enableCipherLogging:(CipherLogLevel)logLevel;

/// Instructs SQLCipher to disable logging internal debugging and operational information
///
/// See https://www.zetetic.net/sqlcipher/sqlcipher-api/#cipher_log
/// - Return YES if success NO on error.
- (BOOL)disableCipherLogging;

@end

NS_ASSUME_NONNULL_END

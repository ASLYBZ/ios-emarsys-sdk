//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSSqliteSchemaHandler.h"
#import "EMSSchemaContract.h"
#import "EMSLogger.h"
#import "EMSCoreTopic.h"

@implementation EMSSqliteSchemaHandler

- (void)onCreateWithDbHelper:(EMSSQLiteHelper *)dbHelper {
    [EMSLogger logWithTopic:EMSCoreTopic.offlineTopic
                    message:@"Creating new database"];
    [self onUpgradeWithDbHelper:dbHelper
                     oldVersion:0
                     newVersion:[self schemaVersion]];
}

- (void)onUpgradeWithDbHelper:(EMSSQLiteHelper *)dbHelper
                   oldVersion:(int)oldVersion
                   newVersion:(int)newVersion {
    [EMSLogger logWithTopic:EMSCoreTopic.offlineTopic
                    message:[NSString stringWithFormat:@"Upgrading existing database from: %@ to: %@",
                                                       @(oldVersion),
                                                       @(newVersion)]];
    for (int i = oldVersion; i < newVersion; ++i) {
        for (NSString *sqlCommand in MIGRATION[(NSUInteger) i]) {
            [dbHelper executeCommand:sqlCommand];
        }
        [dbHelper executeCommand:SCHEMA_UPGRADE_SET_VERSION(i + 1)];
    }
}

- (int)schemaVersion {
    return 1;
}

@end
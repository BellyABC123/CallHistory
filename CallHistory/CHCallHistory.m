//
//  CHCallHistory.m
//
//  Created by Toshinori Watanabe on 11/09/11.
//  Copyright 2011 FLCL.jp. All rights reserved.
//

#import <sqlite3.h>
#import "CHCallHistory.h"
#import "CHHistory.h"


NSString *const CHCallHistoryChangedNotification = @"CHCallHistoryChangedNotification";

NSString *const CHCallHistoryErrorDomain = @"CHCallHistoryErrorDomain";

#define DB_FILE_PATH @"/private/var/wireless/Library/CallHistory/call_history.db"

@interface CHCallHistory ()
@property (nonatomic, retain) NSString *currentDate_;
+ (id)defaultsCallHistory;
- (void)willEnterForeground;
- (void)openDatabaseWithStatement:(NSString *)sqlStatement execute:(void (^)(sqlite3_stmt *statement, NSError *error))execute;
@end



@implementation CHCallHistory

@synthesize currentDate_;


#pragma mark - Instance

+ (id)defaultsCallHistory
{
    static dispatch_once_t pred;
    static CHCallHistory *defaultsCallHistory = nil;
    
    dispatch_once(&pred, ^{ defaultsCallHistory = [[self alloc] init]; });
    return defaultsCallHistory;
}

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];

    self.currentDate_ = nil;
    
    [super dealloc];
}


#pragma mark - Public methods

+ (NSArray *)historiesWithError:(NSError **)error
{
    __block NSArray *histories = nil;
    
    CHCallHistory *callHistory = [CHCallHistory defaultsCallHistory];
    
    [callHistory openDatabaseWithStatement:@"SELECT * FROM call ORDER BY ROWID DESC;"
                                   execute:^(sqlite3_stmt *statement, NSError *executeError) {
                                       if (!executeError) {
                                           NSMutableArray *array = [NSMutableArray array];
                                           
                                           while(sqlite3_step(statement) == SQLITE_ROW) {
                                               
                                               NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
                                               int numberOfColumns = sqlite3_column_count(statement);
                                               
                                               for (int i = 0; i < numberOfColumns; i++) {
                                                   NSString *columnName = [NSString stringWithUTF8String:(char *)sqlite3_column_name(statement, i)];
                                                   NSString *columnText = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, i)];
                                                   
                                                   [dictionary setObject:columnText forKey:columnName];
                                               }
                                               
                                               [array addObject:[CHHistory historyWithRecord:dictionary]];
                                           }
                                           
                                           histories = [NSArray arrayWithArray:array];

                                       } else {
                                           *error = executeError;
                                       }
                                   }];
    
    if (histories && histories.count > 0) {
        CHHistory *history = [histories objectAtIndex:0];
        callHistory.currentDate_ = history.dateString;
    }
    
    return histories;
}

//+ (BOOL)removeHistory:(CHHistory *)history error:(NSError **)error
//{
//    __block BOOL result = NO;
//
//    CHCallHistory *callHistory = [CHCallHistory defaultsCallHistory];
//
//    [callHistory openDatabaseWithStatement:[NSString stringWithFormat:@"DELETE FROM call WHERE ROWID = %d", history.rowID]
//                                   execute:^(sqlite3_stmt *statement, NSError *executeError) {
//                                       if (!executeError) {
//                                           if (sqlite3_step(statement) == SQLITE_DONE) {
//                                               result = YES;
//
//                                           } else {
//                                               *error = [NSError errorWithDomain:CHCallHistoryErrorDomain 
//                                                                   code:CHCallHistoryExecuteFailedError
//                                                               userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Failed to execute statement.", NSLocalizedDescriptionKey, nil]
//                                                         ];
//                                           }
//                                           
//                                       } else {
//                                           *error = executeError;
//                                       }
//                                   }];
//    
//    return result;
//}


#pragma mark - Private methods

- (void)willEnterForeground
{
    // Check date value.

    __block NSString *date = nil;
    
    [self openDatabaseWithStatement:@"SELECT date FROM call ORDER BY date DESC LIMIT 1;"
                            execute:^(sqlite3_stmt *statement, NSError *executeError) {
                                if (!executeError) {
                                    int result = sqlite3_step(statement);
                                    switch (result) {
                                        case SQLITE_ROW: {
                                            date = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)] autorelease];

                                            // break;
                                        }
                                        case SQLITE_DONE: {
                                            if (!currentDate_ || ![currentDate_ isEqualToString:date]) {
                                                self.currentDate_ = date;
                                                
                                                [[NSNotificationCenter defaultCenter] postNotificationName:CHCallHistoryChangedNotification object:nil];
                                            }

                                            break;
                                        }
                                        default:
                                            NSLog(@"Failed to execute sqlite, %d", result);
                                            break;
                                    }

                                } else {
                                    NSLog(@"Failed to execute statement, %@ %@", executeError, [executeError localizedDescription]);
                                }
                            }];
    
}

- (void)openDatabaseWithStatement:(NSString *)sqlStatement execute:(void (^)(sqlite3_stmt *statement, NSError *error))execute
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if([fileManager fileExistsAtPath:DB_FILE_PATH]) {

        if ([fileManager isReadableFileAtPath:DB_FILE_PATH]) {
            
            sqlite3 *database;
            
            if(sqlite3_open([DB_FILE_PATH UTF8String], &database) == SQLITE_OK) {
                sqlite3_stmt *compiledStatement;
                
                int errorCode = sqlite3_prepare_v2(database, [sqlStatement UTF8String], -1, &compiledStatement, NULL);
                
                if(errorCode == SQLITE_OK) {
                    execute(compiledStatement, nil);
                    
                } else {
                    execute(nil, [NSError errorWithDomain:CHCallHistoryErrorDomain 
                                                     code:CHCallHistoryExecuteFailedError
                                                 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Failed to execute statement.", NSLocalizedDescriptionKey, nil]
                                  ]);
                }
                
                sqlite3_finalize(compiledStatement);
                sqlite3_close(database);
                
            } else {
                execute(nil, [NSError errorWithDomain:CHCallHistoryErrorDomain 
                                                 code:CHCallHistoryReadFailedError
                                             userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Failed to open database.", NSLocalizedDescriptionKey, nil]
                              ]);
            }

        } else {
            execute(nil, [NSError errorWithDomain:CHCallHistoryErrorDomain 
                                             code:CHCallHistoryReadFailedError
                                         userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Database file not readable.", NSLocalizedDescriptionKey, nil]
                          ]);
        }

    
    } else {
        execute(nil, [NSError errorWithDomain:CHCallHistoryErrorDomain
                                         code:CHCallHistoryReadFailedError
                                     userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Database file not exists.", NSLocalizedDescriptionKey, nil]
                      ]);
    }
}

@end

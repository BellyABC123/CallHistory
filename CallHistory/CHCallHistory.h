//
//  CHCallHistory.h
//
//  Created by Toshinori Watanabe on 11/09/11.
//  Copyright 2011 FLCL.jp. All rights reserved.
//

@class CHHistory;

@interface CHCallHistory : NSObject

+ (NSArray *)historiesWithError:(NSError **)error;
//+ (BOOL)removeHistory:(CHHistory *)history error:(NSError **)error;

@end


// Notifications
extern NSString *const CHCallHistoryChangedNotification; 

// Errors
extern NSString *const CHCallHistoryErrorDomain;

enum {
    CHCallHistoryUnknownError = -1,
    CHCallHistoryReadFailedError = -3300,
    CHCallHistoryExecuteFailedError = -3301,
};

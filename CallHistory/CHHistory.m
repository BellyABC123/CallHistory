//
//  CHHistory.m
//
//  Created by Toshinori Watanabe on 11/09/11.
//  Copyright 2011 FLCL.jp. All rights reserved.
//

#import "CHHistory.h"


#define INVALID_ROWID -1
#define INVALID_DURATION -1
#define MISSED_DURATION 0
#define FLAGS_OUTGOING @"5"

#define COLOUMN_NAME_ROWID   @"ROWID"
#define COLOUMN_NAME_ADDRESS @"address"
#define COLOUMN_NAME_COUNTRYCODE    @"country_code"
#define COLOUMN_NAME_DATE    @"date"
#define COLOUMN_NAME_DURATION    @"duration"
#define COLOUMN_NAME_FLAGS   @"flags"
#define COLOUMN_NAME_ID  @"id"
#define COLOUMN_NAME_NAME    @"name"


@interface CHHistory()
@property (nonatomic, retain) NSDictionary *record_;
@end



@implementation CHHistory

@synthesize record_;


#pragma mark - Instance

+ (CHHistory *)historyWithRecord:(NSDictionary *)record {
    return [[[CHHistory alloc] initWithRecord:record] autorelease];
}

- (id)initWithRecord:(NSDictionary *)record
{
    self = [super init];
    if (self) {
        self.record_ = record;
    }
    return self;
}

- (void)dealloc
{
    self.record_ = nil;

    [super dealloc];
}


#pragma mark - Columns

- (NSInteger)rowID
{
    NSString *object = [record_ objectForKey:COLOUMN_NAME_ROWID];
    return object ? [object integerValue] : INVALID_ROWID;
}

- (NSString *)address
{
    return [record_ objectForKey:COLOUMN_NAME_ADDRESS];
}

- (NSString *)countryCode
{
    return [record_ objectForKey:COLOUMN_NAME_COUNTRYCODE];
}

- (NSDate *)date
{
    NSString *object = [self dateString];
    return object ? [NSDate dateWithTimeIntervalSince1970:[object intValue]] : nil;
}

- (NSString *)dateString
{
    return [record_ objectForKey:COLOUMN_NAME_DATE];
}

- (NSInteger)duration
{
    NSString *object = [record_ objectForKey:COLOUMN_NAME_DURATION];
    return object ? [object integerValue] : INVALID_DURATION;
}

- (BOOL)isMissed {
    return ([self duration] == MISSED_DURATION);
}

- (BOOL)isOutgoing
{
    NSString *object = [record_ objectForKey:COLOUMN_NAME_FLAGS];
    return (object && [object isEqualToString:FLAGS_OUTGOING]);
}

- (ABRecordID)recordID
{
    NSString *object = [record_ objectForKey:COLOUMN_NAME_ID];
    return object ? [object integerValue] : kABRecordInvalidID;
}

- (NSString *)name
{
    return [record_ objectForKey:COLOUMN_NAME_NAME];
}

@end

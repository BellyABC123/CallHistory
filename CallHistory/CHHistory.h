//
//  CHHistory.h
//
//  Created by Toshinori Watanabe on 11/09/11.
//  Copyright 2011 FLCL.jp. All rights reserved.
//

#import <AddressBook/AddressBook.h>


@interface CHHistory : NSObject

@property (nonatomic, readonly) NSInteger rowID;
@property (nonatomic, readonly) NSString *address;
@property (nonatomic, readonly) NSString *countryCode;
@property (nonatomic, readonly) NSDate *date;
@property (nonatomic, readonly) NSString *dateString;
@property (nonatomic, readonly) NSInteger duration;
@property (nonatomic, readonly) BOOL isMissed;
@property (nonatomic, readonly) BOOL isOutgoing;
@property (nonatomic, readonly) ABRecordID recordID;
@property (nonatomic, readonly) NSString *name;

+ (CHHistory *)historyWithRecord:(NSDictionary *)record;
- (id)initWithRecord:(NSDictionary *)record;

@end

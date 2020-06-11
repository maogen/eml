//
//  EmlItem.h
//  emlReader
//
//  Created by Chauster Kung on 2013/11/12.
//  Copyright (c) 2013年 Chauster Kung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmlItem : NSObject

/**********************Header****************************/

@property (nonatomic, strong) NSString *from;
@property (nonatomic, strong) NSString *to;
@property (nonatomic, strong) NSString *cc;
@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSString *subject;

@property (nonatomic, strong) NSString *content_Type;
@property (nonatomic, strong) NSString *content_Transfer_Encodin;


/**********************Content****************************/

@property (nonatomic, strong) NSMutableArray *content; //Text or HTML

@property (nonatomic, strong) NSMutableArray *attachment_FileName;
@property (nonatomic, strong) NSMutableArray *attachment_FileData; //NSData or NSString

/**********************完整的内容****************************/
@property (nonatomic, strong) NSString *fullContent;// 完整的内容
-(BOOL)haveAttachment;

@end

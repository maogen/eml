//
//  EmlParse.h
//  emlReader
//
//  Created by Chauster Kung on 2013/11/12.
//  Copyright (c) 2013年 Chauster Kung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmlItem.h"

@interface EmlParse : NSObject

// 传入文件路径，解析内容
- (EmlItem*)getItemWithPath:(NSString*)filePath;
// 传入NSData，解析内容
- (EmlItem *)getItem:(NSData *)data;

@end

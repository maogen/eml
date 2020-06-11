//
//  EmlAttachment.h
//  EmlOpenDemo
//
//  Created by 毛宗艮 on 2020/6/4.
//  Copyright © 2020 毛宗艮. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EmlAttachment : NSObject

// 附件名称
@property (nonatomic, strong) NSString *filename;
// 附件内容（base64编码）
@property (nonatomic, strong) NSString *fileContent;

@end

NS_ASSUME_NONNULL_END

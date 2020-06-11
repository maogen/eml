//
//  QuotedPrintableUtil.h
//  EmlOpenDemo
//
//  Created by 毛宗艮 on 2020/5/27.
//  Copyright © 2020 毛宗艮. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EmlAttachment.h"

NS_ASSUME_NONNULL_BEGIN

@interface QuotedPrintableUtil : NSObject

#ifdef DEBUG

#define SLog(format, ...) printf("class: <%p %s:(%d) > method: %s \n%s\n", self, [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, __PRETTY_FUNCTION__, [[NSString stringWithFormat:(format), ##__VA_ARGS__] UTF8String] )

#else

#define SLog(format, ...)

#endif

// 处理编码
+(NSString *) decoderQP:(NSString *)string;
// 解析内容
+(NSString *) analysisContent:(NSString *)content;
// 解析附件
+(NSArray *) analysisAttachment:(NSString *)content;
@end

NS_ASSUME_NONNULL_END

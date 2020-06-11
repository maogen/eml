//
//  QuotedPrintableUtil.m
//  EmlOpenDemo
//
//  Created by 毛宗艮 on 2020/5/27.
//  Copyright © 2020 毛宗艮. All rights reserved.
//

#import "QuotedPrintableUtil.h"

@implementation QuotedPrintableUtil

- (BOOL)hasChinese:(NSString *)str {
    for(int i=0; i< [str length];i++){
        int a = [str characterAtIndex:i];
        if( a > 0x4e00 && a < 0x9fff)
        {
            return YES;
        }
    }
    return NO;
}

/**
 * 获取字符串的gbk编码
 */
+ (NSString *)GBKTransCoding:(NSString *)str {
    //校验
    if (![str isKindOfClass:[NSString class]]) return @"";
    if (!str.length) return @"";
    //GBK编码
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    return [str stringByAddingPercentEscapesUsingEncoding:enc];
    
}

/**
 *  将gbk编码转成汉字。例如"B7A2"->"发"
 *  一般输入的是4个16进制数，因为一个中文占两个字符，也就是16位字节
 */
+ (NSString *)GBKTransDeCode:(NSString *)gbkStr {
    Byte byte[gbkStr.length/2];
    NSScanner *hexScanner;
    NSString *tmp;
    for(NSUInteger i=0;i<gbkStr.length/2;i++){
        tmp = [gbkStr substringWithRange:NSMakeRange(i*2,2)];
        unsigned int iStr = 0;
        hexScanner = [NSScanner scannerWithString:tmp];
        [hexScanner scanHexInt:&iStr];
        byte[i]=iStr;
    }
    NSData *data = [NSData dataWithBytes:byte length:gbkStr.length/2];
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *retStr = [[NSString alloc] initWithData:data encoding:enc];
    return retStr;
}

/**
 * 处理QuotedPrintable编码的字符串
 */
+(NSString *) decoderQP:(NSString *)string{
    if(nil == string || [string isEqualToString:@""]){
        return @"";
    }
    if(![string containsString:@"Content-Transfer-Encoding: quoted-printable"]){
        // 不是quoted-printable编码，直接返回
        return string;
    }
    NSMutableString *result = [NSMutableString string];
    NSUInteger length = [string length];
    for(NSUInteger i = 0; i < length; i++){
        char c = [string characterAtIndex:i];
        if(c == '='){
            if(i < length - 5){
                char b1 = [string characterAtIndex:i+1];
                char b2 = [string characterAtIndex:i+2];
                char b3 = [string characterAtIndex:i+3];
                char b4 = [string characterAtIndex:i+4];
                char b5 = [string characterAtIndex:i+5];
                
                if(b1 == '0' &&
                   b2 == 'A' &&
                   b3 == '=' &&
                   b4 == '\r' &&
                   b5 == '\n'){
                    // 遇到=0A=\r\n
                    i = i + 5;
                    continue;
                }
                if(b1 == '\r' && b2 == '\n'){
                    // 遇到回车
                    [result appendFormat:@"%@", @""];
                    i = i + 2;
                    continue;
                }
                if(b4 == '\r' && b5 == '\n'){
                    // 遇到回车
                    b4 = [string characterAtIndex:i+7];
                    b5 = [string characterAtIndex:i+8];
                    i = i + 3;
                }
                if(b1 == '3' && b2 == 'D'){
                    // 遇到=3D，替换成=号
                    [result appendFormat:@"%@", @"="];
                    i = i + 2;
                    continue;
                }
                if(((b1 >= '0' && b1 <= '9')
                    || (b1 >= 'A' && b1 <= 'F'))
                   &&
                   ((b2 >= '0' && b2 <= '9')
                    || (b2 >= 'A' && b2 <= 'F'))
                   &&
                   ((b4 >= '0' && b4 <= '9')
                    || (b4 >= 'A' && b4 <= 'F'))
                   &&
                   ((b5 >= '0' && b5 <= '9')
                    || (b5 >= 'A' && b5 <= 'F'))
                   ){
                    // 后面四个字符都是16进制字符串
                    NSString *chStr =  [NSString stringWithFormat:@"%c%c%c%c", b1,b2,b4,b5];
                    chStr = [self GBKTransDeCode:chStr];
                    [result appendFormat:@"%@", chStr];
                    i = i + 5;
                }else{
                    // 等于号后面不是四个16进制字符
                    [result appendFormat:@"%c", c ];
                    
                }
            }else{
                [result appendFormat:@"%c", c ];
            }
        }else{
            [result appendFormat:@"%c", c ];
        }
    }
    return result;
}

/**
 * 处理内容，将内容<html></html>的部分提取出来，同时找到<img>部分，替换base64内容
 */
+(NSString *) analysisContent:(NSString *)content{
    if(nil == content || [@"" isEqualToString:content]){
        return @"";
    }
    // 先解析html部分
    NSString *html = [self subString:content From:@"<html" to:@"</html>"];
    html = [NSString stringWithFormat:@"<html %@ </html>", html];
    NSMutableString *result = [NSMutableString stringWithString:html];// 存放结果
    // 处理<img>部分
    NSArray *array = [content componentsSeparatedByString:@"--"];// 将原始字符串分割
    NSMutableArray *typeArray = [NSMutableArray array];// 存放文件的类型
    NSMutableArray *nameArray = [NSMutableArray array];// 存放文件的名称
    NSMutableArray *base64Array = [NSMutableArray array];// 存放文件的内容
    for(NSUInteger i = 0;i < array.count; i++){
        NSString *line = array[i];
        //        NSLog(@"第%d行内容%@ ： ",i,  line);
        if([line containsString:@"Content-Type"]){
            // 找到文件的类型
            NSString *type = [self subString:line From:@"Content-Type:" to:@";"];
            NSLog(@"类型 %@", type);
            
            NSString *imageId = nil;
            // 找到id
            if([line containsString:@"Content-ID"]){
                imageId = [self subString:line From:@"Content-ID: <" to:@">"];
            }
            // 找到到base64
            NSString *base64 = nil;
            if([line containsString:@"base64"]){
                base64 = [self subString:line From:@"base64" to:nil];
                // 处理掉base64中，多余的字符串
                if([base64 containsString:@">"]){
                    NSArray *array  = [base64 componentsSeparatedByString:@">"];
                    if(nil != array && array.count >= 2){
                        base64 = array[1];
                        NSLog(@"==========%@", base64);
                    }
                }
                
            }
            if(nil != imageId && nil != base64){
                // 将图片保存到数组中
                [typeArray addObject:type];
                [nameArray addObject:imageId];
                [base64Array addObject:base64];
            }
        }
    }
    // 处理图片数组，替换掉String
    for (NSUInteger i = 0; i < typeArray.count; i++) {
        NSString *type = typeArray[i];
        NSString *name = nameArray[i];
        NSString *base64 = base64Array[i];
        
        NSString *cid = [NSString stringWithFormat:@"cid:%@", name];
        NSString *content = [NSString stringWithFormat:@"data:%@;base64,%@", type, base64];
        NSRange range = [result rangeOfString:cid];
        if(range.length){
            // 找到图片文件
            [result replaceCharactersInRange:range withString:content];
        }else{
            // 未找到图片文件
        }
        //
    }
    
    return result;
}

// 截取字符串方法封装// 截取字符串方法封装
+ (NSString *)subString:(NSString *) line From:(NSString *)startString to:(NSString *)endString{
    NSRange startRange = [line rangeOfString:startString];
    NSRange range;
    if(startRange.length == 0){
        return @"";
    }
    if(nil == endString){
        range =  NSMakeRange(startRange.location + startRange.length, line.length - startRange.location - startRange.length);
    }else{
        NSRange endRange = [line rangeOfString:endString];
        if(endRange.length == 0){
            return @"";
        }
        range = NSMakeRange(startRange.location + startRange.length, endRange.location - startRange.location - startRange.length);
    }
    if(range.length == 0){
        return line;
    }
    return [line substringWithRange:range];
    
}

// 解析附件
+(NSArray *) analysisAttachment:(NSString *)content {
    NSMutableArray *attachmentArray = [NSMutableArray array];
    if(nil == content || [@"" isEqualToString:content]){
        return attachmentArray;
    }
    if(![content containsString:@"Content-Disposition: attachment"]){
        // 没有附件，直接返回
        return  attachmentArray;
    }
    NSArray *strArray = [content componentsSeparatedByString:@"Content-Disposition: attachment"];
    for(NSUInteger i = 1;i < strArray.count; i++){
        NSString *itemLine = strArray[i];
        if([itemLine containsString:@"filename"]){
            // 附件类，用于存储附件名、内容、附件大小
            EmlAttachment *emlAttachment = [[EmlAttachment alloc] init];
            
            NSArray *subLineArray = [itemLine componentsSeparatedByString:@"\r\n\r\n"];
            if(subLineArray.count >= 3){
                // 数组第一个是文件名
                NSString *fileName = subLineArray[0];
                if([[fileName lowercaseString] containsString:@"?gb2312?"]){
                    // 是gb2312编码
                    NSMutableString *names = [NSMutableString string];
                    
                    NSArray *array = [fileName componentsSeparatedByString:@"?"];
                    for (NSString *item in array) {
                        if([item hasSuffix:@"=="]){
                            NSData *data = [[NSData alloc]initWithBase64EncodedString:item options:NSDataBase64DecodingIgnoreUnknownCharacters];
                            NSStringEncoding gbkEncodeing = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
                            [names appendString:[[NSString alloc]initWithData:data encoding:gbkEncodeing]];
                        }
                    }
                    //                    NSLog(@"文件名：%@", names);
                    // 保存文件名
                    emlAttachment.filename = names;
                }else if([[fileName lowercaseString] containsString:@"?utf-8?"]){
                    // 是utf-8编码
                    fileName = [fileName componentsSeparatedByString:@"?"][3];
                    NSData *data = [[NSData alloc]initWithBase64EncodedString:fileName options:NSDataBase64DecodingIgnoreUnknownCharacters];
                    fileName = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                    //                    NSLog(@"文件名：%@", fileName);
                    // 保存文件名
                    emlAttachment.filename = fileName;
                }else{
                    // 直接获取文件名
                    fileName = [fileName componentsSeparatedByString:@"\""][1];
                    // 保存文件名
                    emlAttachment.filename = fileName;
                }
                
                // 处理附件内容
                NSString *base64 = subLineArray[1];
                base64 = [base64 componentsSeparatedByString:@"--"][0];
                emlAttachment.fileContent = base64;
//                SLog(@"*********\n%@\n*********", base64);
                
                [attachmentArray addObject:emlAttachment];
            }
        }
    }
    
    return attachmentArray;
}
@end

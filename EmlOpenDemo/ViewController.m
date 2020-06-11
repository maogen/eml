//
//  ViewController.m
//  EmlOpenDemo
//
//  Created by 毛宗艮 on 2020/5/13.
//  Copyright © 2020 毛宗艮. All rights reserved.
//

#import "ViewController.h"
#import "EmlParse.h"
#import "EmlDecoder.h"
#import "QuotedPrintableUtil.h"

@interface ViewController () <UIDocumentBrowserViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)btnOpenFile:(id)sender {
    
    [self testDecoderQP];
    //    [self loadEml];
}
//测试QuotedProtable解码
-(void) testDecoderQP{
    NSMutableArray *mArray = [NSMutableArray array];
//    [mArray addObject:@"两个附件.eml"];
//        [mArray addObject:@"图片附件.eml"];
//        [mArray addObject:@"word文档附件.eml"];
        [mArray addObject:@"zip压缩包附件.eml"];
    for (NSString *name in mArray) {
        NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:nil];
        
        EmlParse *parse = [[EmlParse alloc] init];
        EmlItem *item = [parse getItemWithPath:path];
        NSString *content  = item.fullContent;
        NSLog(@"------------------------content---------------------");
        NSArray *attachmentArray = [QuotedPrintableUtil analysisAttachment:content];
        for (EmlAttachment *item in attachmentArray) {
            NSLog(@"附件名称 %@", item.filename);
            SLog(@"附件内容 %@", item.fileContent);
        }
        NSLog(@"------------------------content-end ---------------------");
    }
    
}

// 测试加载eml
-(void) loadEml{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"两个附件.eml" ofType:nil];
    //    NSString *path = [[NSBundle mainBundle] pathForResource:@"zip压缩包附件.eml" ofType:nil
    //                      ];
    //    NSString *path = [[NSBundle mainBundle] pathForResource:@"图片附件.eml" ofType:nil];
    //  使用EmlParse
    EmlParse *parse = [[EmlParse alloc] init];
    EmlItem *item = [parse getItemWithPath:path];
    
    NSLog(@"---------------------%@----------------------",path);
    NSLog(@"------------------------header---------------------");
    NSLog(@"发送人 : %@",item.from);
    NSLog(@"接收人 : %@",item.to);
    NSLog(@"抄送 : %@",item.cc);
    NSLog(@"时间 : %@",item.date);
    NSLog(@"标题 : %@",item.subject);
    
    NSLog(@"内容类型 : %@",item.content_Type);
    NSLog(@"内容编码 : %@",item.content_Transfer_Encodin);
    
    // 处理内容，并且显示
    NSMutableArray *contentArray = item.content;
    if(nil == contentArray){
        NSLog(@"无内容");
    }else{
        NSLog(@"------------------------content---------------------");
        for (int i = 0 ; i < item.content.count ; i++) {
            NSString *line = [item.content objectAtIndex:i];
            //            NSLog(@"%@", line);
            // text/html   text/plain multipart
            if([line containsString:@"text/html"]){
                //                line =  @"=C3=FB=B3=C6<= /span>";
                line = [line stringByReplacingOccurrencesOfString:@"= " withString:@""];
                NSString *result = [QuotedPrintableUtil decoderQP:line];
                // 处理附件
                NSArray *attachmentArray = [QuotedPrintableUtil analysisAttachment:result];
                // 处理内容
                result = [QuotedPrintableUtil analysisContent:result];
                SLog(@"%@", result);
                // 显示内容
                [self.webView loadHTMLString:result baseURL:nil];
            }
        }
        NSLog(@"------------------------content-end ---------------------");
    }
}

@end

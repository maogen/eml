//
//  ViewController.h
//  EmlOpenDemo
//
//  Created by 毛宗艮 on 2020/5/13.
//  Copyright © 2020 毛宗艮. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
#ifdef DEBUG

#define SLog(format, ...) printf("class: <%p %s:(%d) > method: %s \n%s\n", self, [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, __PRETTY_FUNCTION__, [[NSString stringWithFormat:(format), ##__VA_ARGS__] UTF8String] )

#else

#define SLog(format, ...)

#endif

@end


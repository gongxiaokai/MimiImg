//
//  GlobalHeader.h
//  ShSCab
//
//  Created by gongwenkai on 2017/3/29.
//  Copyright © 2017年 gongwenkai. All rights reserved.
//

#ifndef GlobalHeader_h
#define GlobalHeader_h

/**
 单例
 
 */
#define SINGLETON(block) \
static dispatch_once_t pred = 0; \
__strong static id _sharedObject = nil; \
dispatch_once(&pred, ^{ \
_sharedObject = block(); \
}); \
return _sharedObject; \



//frame
#define CURRENTSCREEN_HEIGHT  [UIScreen mainScreen].bounds.size.height
#define CURRENTSCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width


// font

//#define FontHeiti(fontSize) [UIFont fontWithName:@"PingFangSC-Regular" size:(fontSize)]
//
//#define FontBoldHeiti(fontSize)  [UIFont fontWithName:@"PingFangSC-Medium" size:(fontSize)]

// 字体
static inline UIFont *FontHeiti(CGFloat fontSize) {
    if (CURRENTSCREEN_WIDTH > 375) {
        fontSize += 1;
    }else if (CURRENTSCREEN_WIDTH < 375) {
        fontSize -= 2;
    }
    return [UIFont fontWithName:@"PingFangSC-Regular" size:(fontSize)];
}

static inline UIFont *FontBoldHeiti(CGFloat fontSize) {
    if (CURRENTSCREEN_WIDTH > 375) {
        fontSize += 1;
    }else if (CURRENTSCREEN_WIDTH < 375) {
        fontSize -= 2;
    }
    return  [UIFont fontWithName:@"PingFangSC-Medium" size:(fontSize)];
}

// 颜色
static inline UIColor *RGBA(int R, int G, int B, double A) {
    return [UIColor colorWithRed: R/255.0 green: G/255.0 blue: B/255.0 alpha: A];
}

static inline UIColor *HexColorA(int v, double A) {
    return RGBA((double)((v&0xff0000)>>16), (double)((v&0xff00)>>8), (double)(v&0xff), A);
}

static inline UIColor *HexColor(int v) {
    return RGBA((double)((v&0xff0000)>>16), (double)((v&0xff00)>>8), (double)(v&0xff), 1.0f);
}

#define scaleWidth(width) ( floorf(CURRENTSCREEN_WIDTH / 375 * (width)) )
#define scaleHeight(height) ( floorf(CURRENTSCREEN_WIDTH / 375 * (height)) )


#define IPHONEX_ADD ((CURRENTSCREEN_HEIGHT==812.f)?34:0)
#define STATUSBAR_HEIGHT ((CURRENTSCREEN_HEIGHT==812.f)?44:20)
//MARK: 动态获取高度
static inline CGFloat getHeightWithContent(NSString *content,CGFloat width,CGFloat font) {
//    if (CURRENTSCREEN_WIDTH > 375) {
//        font += 1;
//    }
    
    CGRect rect = [content boundingRectWithSize:CGSizeMake(width, 999)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName:FontHeiti(font)}
                                        context:nil];
    return rect.size.height;
}





// cell data protocol
@protocol GCellSetModelProtocol <NSObject>
@optional
@property (nonatomic, copy) void (^actionBlockWithDataModel)(id dataModel);
- (void)renderWithModel:(id)model;
@end




#endif /* GlobalHeader_h */

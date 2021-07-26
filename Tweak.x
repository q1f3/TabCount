#import <substrate.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TabController : NSObject
-(NSUInteger)numberOfTabs;
@end

@interface BrowserRootViewController : UIViewController
-(id)bottomToolbar;
-(id)primaryBar;
@end

@interface BrowserToolbar : UIToolbar
@end

@interface _SFToolbar : UIToolbar
@end

static unsigned long numberOfTabs = 0;
static id BRVShared = nil;
static UILabel* countLabel = nil;

//폰 세로 모드
%hook BrowserToolbar
-(void) setTintColor:(id)arg1 {
    %orig;
    if (countLabel) {
        countLabel.textColor = self.tintColor;
    }
}
%end

//폰 가로 모드 (아이패드)
%hook _SFToolbar
-(void) setTintColor:(id)arg1 {
    %orig;
    if (countLabel) {
        countLabel.textColor = self.tintColor;
    }
}
%end

%hook TabController

-(id)activeTabDocument {
  NSArray* tabs = [self performSelector:@selector(currentTabDocuments)];
  if(!countLabel) {
    countLabel = [[UILabel alloc] init];
    countLabel.text = [NSString stringWithFormat:@"%lu", numberOfTabs];
    countLabel.textAlignment = NSTextAlignmentCenter;
    countLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    countLabel.adjustsFontSizeToFitWidth = YES;
    countLabel.numberOfLines = 1;
    [countLabel setFont:[UIFont systemFontOfSize:15]];
  }
  if(BRVShared)
    [BRVShared performSelector:@selector(updateTabCountView)];
  numberOfTabs = tabs.count;
  return %orig;
}
%end

%hook BrowserRootViewController
-(void)viewDidAppear:(BOOL)arg1 {
  BRVShared = self;
  %orig;
}

%new
-(void)updateTabCountView {
  bool isExistUILabel = false;

  countLabel.text = [NSString stringWithFormat:@"%lu", numberOfTabs];
  [countLabel setNeedsDisplay];

  //폰 세로 모드일때..
  id bar = [self bottomToolbar];
  if(bar) {
    NSArray* barItems = [bar items];
    for (UIBarButtonItem *item in barItems) {
      if([item.accessibilityIdentifier isEqualToString:@"TabsButton"]) {
        UIView *itemView = [item performSelector:@selector(view)];
        for(UIView *view in [itemView subviews]) {
          if ([view isKindOfClass:[UILabel class]] && view.tag == 1337) {
            isExistUILabel = true;
            break;
          }
        }
        if(!isExistUILabel) {
          countLabel.tag = 1337;
          [itemView addSubview:countLabel];
          isExistUILabel = false;
        }
        countLabel.frame = CGRectMake([itemView frame].size.width - 37.5, [itemView frame].size.height - 27, 20, 15);
        break;
      }
    }
  }

  //폰 가로 모드일때.. 또는 아이패드.
 bar = [self primaryBar];
 if(bar) {
   if (![bar respondsToSelector:@selector(popoverPassthroughViews)])
    return;
   NSArray *barItems = [bar performSelector:@selector(popoverPassthroughViews)];
   NSArray *reversedBarItems = [[barItems reverseObjectEnumerator] allObjects];
   for (id item in reversedBarItems) {
     if([item isKindOfClass:[UIToolbar class]]) {
       barItems = [item items];
       for(UIBarButtonItem *btnItem in barItems) {
         if([btnItem.accessibilityIdentifier isEqualToString:@"TabsButton"]) {
           UIView *itemView = [btnItem performSelector:@selector(view)];
           for(UIView *view in [itemView subviews]) {
             if ([view isKindOfClass:[UILabel class]] && view.tag == 4141) {
               isExistUILabel = true;
               break;
             }
           }
           if(!isExistUILabel) {
             countLabel.tag = 4141;
             [itemView addSubview:countLabel];
             isExistUILabel = false;
           }
           countLabel.frame = CGRectMake([itemView frame].size.width - 21, [itemView frame].size.height - 22, 20, 15);
           if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
            countLabel.frame = CGRectMake([itemView frame].size.width - 21, [itemView frame].size.height - 27, 20, 15);
           break;

         }
       }
       break;
     }
   }
 }

}
%end

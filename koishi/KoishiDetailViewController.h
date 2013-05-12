//
//  KoishiDetailViewController.h
//  koishi
//
//  Copyright (c) 2013 aleksandyr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KoishiDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end

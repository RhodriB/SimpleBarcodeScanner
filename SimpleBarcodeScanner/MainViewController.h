//
//  MainViewController.h
//  SimpleBarcodeScanner
//
//  Created by Rhodri Bowden on 04/08/2017.
//  Copyright © 2017 FlinkleLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoOverlayViewController.h"

@interface MainViewController : UIViewController <NSXMLParserDelegate>
{
    IBOutlet UIButton *scanButton;
    IBOutlet UITextField *itemBarcode;
    IBOutlet UIButton *lookupButton;
    IBOutlet UITextView *itemTitle;
    IBOutlet UITextField *itemBrand;
    IBOutlet UITextField *itemASINNo;
    
}

@property (strong, nonatomic) UIButton *scanButton;
@property (strong, nonatomic) UITextField *itemBarcode;
@property (strong, nonatomic) UIButton *lookupButton;
@property (strong, nonatomic) UITextView *itemTitle;
@property (strong, nonatomic) UITextField *itemBrand;
@property (strong, nonatomic) UITextField *itemASINNo;
@property (retain) VideoOverlayViewController *overlayViewController;

- (IBAction)scan:(id)sender;
- (IBAction)searchBarcode:(id)sender;
- (void) manageDetectedString:(NSString *)detectedString;



@end


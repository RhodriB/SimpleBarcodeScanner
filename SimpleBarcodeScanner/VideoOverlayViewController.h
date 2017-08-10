//
//  VideoOverlayViewController.h
//  SimpleBarcodeScanner
//
//  Created by Rhodri Bowden on 07/08/2017.
//  Copyright © 2017 FlinkleLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AVFoundation/AVFoundation.h"


@interface VideoOverlayViewController: UIViewController <AVCaptureMetadataOutputObjectsDelegate> {
    
}

@property (nonatomic, retain) UILabel *scanningLabel;
@property (retain) id delegate;

@end

@protocol VideoOverlayProtocol <NSObject>

- (void) manageDetectedString:(NSString *)detectedString;

@end

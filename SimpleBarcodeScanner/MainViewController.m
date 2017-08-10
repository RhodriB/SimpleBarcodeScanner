//
//  MainViewController.m
//  SimpleBarcodeScanner
//
//  Created by Rhodri Bowden on 04/08/2017.
//  Copyright © 2017 FlinkleLabs. All rights reserved.
//

#import "MainViewController.h"
//#import "AVFoundation/AVCaptureDevice.h"
#import "VideoOverlayViewController.h"

@interface MainViewController ()
{
    NSString *currentBarcode;
    NSString *currentTitle;
    NSString *currentBrand;
    NSString *currentASIN;
}
@end

@implementation MainViewController

@synthesize scanButton, itemBarcode, lookupButton, itemTitle, itemBrand, itemASINNo, overlayViewController;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [scanButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [scanButton.layer setBorderWidth:1];
    [lookupButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [lookupButton.layer setBorderWidth:1];
    
    overlayViewController = [[VideoOverlayViewController alloc] init];
    [overlayViewController setDelegate:self];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)scan:(id)sender {
    
    [itemBarcode resignFirstResponder];
    [self addChildViewController:overlayViewController];
    [self.view addSubview:overlayViewController.view];
    
}

- (IBAction)searchBarcode:(id)sender {
    
    [itemBarcode resignFirstResponder];
    [self processBarcode:itemBarcode.text];

}

- (void)processBarcode:(NSString *)barcode
{
    itemTitle.text = currentTitle;
    itemBrand.text = currentBrand;
    itemASINNo.text = currentASIN;
 
    currentBarcode = barcode;

    if ([self verifyBarcode:barcode])
        [self lookupBarcode:barcode];
    
}

- (BOOL)verifyBarcode:(NSString *)barcode
{
    // perform basic validation on the barcode for example:
    
    NSString *errorMessage = @"";
    
    barcode = [barcode stringByReplacingOccurrencesOfString:@"ISBN" withString:@""];
    barcode = [barcode stringByReplacingOccurrencesOfString:@"isbn" withString:@""];
    barcode = [barcode stringByReplacingOccurrencesOfString:@" " withString:@""];
    barcode = [barcode stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    if (![self isNumeric:barcode])
        errorMessage = @"The barcode is not numeric";
    
    if (barcode.length < 8)
        errorMessage = @"The barcode is too short";
    
    if (barcode.length > 13)
        errorMessage = @"The barcode is too long";
    
    if ([errorMessage isEqualToString:@""])
    {
        currentBarcode = barcode;
        return TRUE;
    }
    else
    {
        UIAlertController *alert = [self createAlertWithMessage:errorMessage];
        [self presentViewController:alert animated:NO completion:nil];
        
        return FALSE;
        
    }
}

- (BOOL) isNumeric:(NSString *) inputString
{
    
    NSScanner *scanner = [NSScanner scannerWithString: inputString];
    if ( [scanner scanFloat:NULL] )
    {
        
        return [scanner isAtEnd];
        
    }
    
    return NO;
    
}

- (UIAlertController *)createAlertWithMessage:(NSString *)message
{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"There was a problem" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [alert dismissViewControllerAnimated:NO completion:nil];
    }];
    [alert addAction:okAction];

    return alert;
    
}

- (void)lookupBarcode:(NSString *)barcode
{

    currentTitle = @"";
    currentBrand = @"";
    currentASIN = @"";
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.upcitemdb.com/prod/trial/lookup?upc=%@", currentBarcode];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionTask *result = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                               completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                                   [self urlHandlerWithData:data];
                                                                   
                                                               }
                                ];
    [result resume];

}

- (void)urlHandlerWithData:(NSData *) data {
    
    NSError *error;
    NSMutableDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    if ([[dictionary objectForKey:@"code"] isEqualToString:@"OK"])
    {
        NSArray *itemArray = [dictionary objectForKey:@"items"];
        if ([itemArray count] > 0)
        {
            NSMutableDictionary *itemDictionary = itemArray[0];
            for (NSString *key2 in [itemDictionary allKeys])
            {
                if ([key2 isEqualToString:@"title"])
                    currentTitle = [itemDictionary objectForKey:key2];
                
                if ([key2 isEqualToString:@"brand"])
                    currentBrand = [itemDictionary objectForKey:key2];
                
                if ([key2 isEqualToString:@"asin"])
                    currentASIN = [itemDictionary objectForKey:key2];
                
            }
            dispatch_async(dispatch_get_main_queue(), ^(void){
                itemBarcode.text = currentBarcode;
                itemTitle.text = currentTitle;
                itemBrand.text = currentBrand;
                itemASINNo.text = currentASIN;
            });
            
        }
    }
    else
    {
        // display the upc error message
        
        UIAlertController *alert = [self createAlertWithMessage:[dictionary objectForKey:@"message"]];
        
        // performed on a background thread, so grab the main thread:

        dispatch_async(dispatch_get_main_queue(), ^(void){
            [self presentViewController:alert animated:NO completion:nil];
        });
        
    }
    
}

- (void) manageDetectedString:(NSString *)detectedString {
    
    if (detectedString)
        currentBarcode = detectedString;
    
    // performed on a background thread, so grab the main thread:
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        
        if (currentBarcode)
            [self processBarcode:detectedString];
        [overlayViewController.view removeFromSuperview];
        [overlayViewController removeFromParentViewController];
        [self setNeedsFocusUpdate];

    });

}




@end

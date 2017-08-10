//
//  VideoOverlayViewController.m
//  SimpleBarcodeScanner
//
//  Created by Rhodri Bowden on 07/08/2017.
//  Copyright © 2017 FlinkleLabs. All rights reserved.
//

#import "VideoOverlayViewController.h"
#import "MainViewController.h"
#import "AVFoundation/AVFoundation.h"

@interface VideoOverlayViewController ()
{
    AVCaptureVideoPreviewLayer *previewLayer;   // to display the camera frames
    AVCaptureSession *captureSession;           // to manage the video i/o
    AVCaptureMetadataOutput *metaDataOutput;    // intercepts metadata objects (such as barcodes) and forwards them

}
@end

@implementation VideoOverlayViewController

@synthesize scanningLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect layerRect = self.view.bounds;
    int w = self.view.layer.bounds.size.width;
    int h = w*26/38;
    [previewLayer setBounds:layerRect];
    [previewLayer setPosition:CGPointMake(CGRectGetMidX(layerRect), CGRectGetMidY(layerRect))];
    
    [self.view.layer addSublayer:previewLayer];
    
    UIImageView *overlayImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ScanArea.png"]];
    [overlayImageView setFrame:CGRectMake(0, 100, w, h)];
    [self.view addSubview:overlayImageView];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton setFrame:CGRectMake(0, self.view.bounds.size.height - 30, w, 30)];
    [cancelButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelButton];
    
    
    captureSession = [[AVCaptureSession alloc] init];
    [self addVideoInput];
    [self addVideoPreviewLayer];
    [self addVideoOutput];
    [captureSession startRunning];
    metaDataOutput.metadataObjectTypes = metaDataOutput.availableMetadataObjectTypes;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [captureSession startRunning];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [captureSession stopRunning];
}

     
-(void)cancelButtonPressed
{
    [self.delegate manageDetectedString:@""];
}

- (void)addVideoPreviewLayer {
    
    previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
}

- (void)addVideoInput {
    
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (videoDevice)
    {
        
        NSError *error;
        AVCaptureDeviceInput *videoIn = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        if (!error) {
            
            if ([captureSession canAddInput:videoIn])
                [captureSession addInput:videoIn];

            else
                NSLog(@"Couldn't add video input");
        }
        else
            NSLog(@"Couldn't create video input");
    }
    else
        NSLog(@"Couldn't create video capture device");
    
}


- (void) addVideoOutput {
    
    metaDataOutput = [[AVCaptureMetadataOutput alloc] init];
    
    // move the area of interest from the centre to approximately where the overlay is:
    [metaDataOutput setRectOfInterest:CGRectMake(0.08, 0, 0.4, 1)];
    
    // create a metadata queue and direct the output to this class:
    dispatch_queue_t metadataQueue =
    dispatch_queue_create("com.flinklelabs.simplebarcodescanner.metadata", 0);
    [metaDataOutput setMetadataObjectsDelegate:self
                                         queue:metadataQueue];
    
    if ([captureSession canAddOutput:metaDataOutput])
        [captureSession addOutput:metaDataOutput];
    
}

// the captureOutput method gets called when metadata objects are found

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    
    CGRect highlightViewRect = CGRectZero;
    
    AVMetadataMachineReadableCodeObject *barCodeObject;
    NSString *detectionString = nil;
    NSArray *barCodeTypes = @[AVMetadataObjectTypeUPCECode,
                              AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code];
    
    // Additional barCodeTypes available: AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode
    
    for (AVMetadataObject *metadata in metadataObjects)
    {
        for (NSString *type in barCodeTypes)
        {
            if ([metadata.type isEqualToString:type])
            {
                // metadata object of interest found so get the string value of the associated object
                
                barCodeObject = (AVMetadataMachineReadableCodeObject *)[previewLayer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *)metadata];
                highlightViewRect = barCodeObject.bounds;
                detectionString = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
                break;
            }
        }
        
        if (detectionString != nil)
        {
            NSLog(@"Barcode: %@", detectionString);
            
            [self.delegate manageDetectedString:detectionString];
            
            break;
        }
        else
            NSLog(@"None");
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    
    [captureSession stopRunning];
    
    previewLayer = nil;
    captureSession = nil;
    scanningLabel = nil;

}
@end

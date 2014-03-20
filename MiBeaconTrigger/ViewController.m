/*
 Copyright (c) 2014 Mathijs Vreeman
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 */

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // configure proximity trigger and start trigger delegate method
    proximityTrigger = [[MiBeaconTrigger alloc] init];
    [proximityTrigger setDelegate:self];
    
    //NSString *uuid = @"B9407F30-F5F8-466E-AFF9-25556B57FE6D"; // standard estimote
    NSString *uuid = @"44E061B1-47E5-4EBC-88DF-3CD10BF97A61";
    NSInteger major = 1;
    NSArray *minors = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:1],[NSNumber numberWithInt:2],[NSNumber numberWithInt:3],nil];
    CLProximity minimumProximity = CLProximityNear; // CLProximityFar, CLProximityNear or CLProximityImmediate
    [proximityTrigger startTriggeringForBeaconsWithUUID:uuid major:major minors:minors minimumProximity:minimumProximity logging:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)proximityTriggeredForBeacon:(CLBeacon *)beacon {
    // trigger specific action for beacon here
    [beaconLabel setText:[NSString stringWithFormat:@"minor: %d", [beacon.minor intValue]]];
}

@end

MiBeaconTrigger
=========================

This class enables you to very easily integrate iBeacons in your projects. Specify UUID, Major, an array of Minors, desired proximity and the delegate will start reporting when an ibeacon with the desired specifications is "triggered". You can enable logging if you want to see what's going on under the hood.

Start triggering:

        // configure proximity trigger and start trigger delegate method
        proximityTrigger = [[MiBeaconTrigger alloc] init];
        [proximityTrigger setDelegate:self];
        
        NSString *uuid = @"B9407F30-F5F8-466E-AFF9-25556B57FE6D"; // standard estimote
        NSInteger major = 1;
        NSArray *minors = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:1],[NSNumber numberWithInt:2],[NSNumber numberWithInt:3],nil];
        CLProximity minimumProximity = CLProximityNear; // CLProximityFar, CLProximityNear or CLProximityImmediate
        BOOL logging = NO;
        [proximityTrigger startTriggeringForBeaconsWithUUID:uuid major:major minors:minors minimumProximity:minimumProximity logging:logging];


Stop triggering:

        [proximityTrigger stopTriggering];

This class filters out beacons with proximity unknown, and also beacons with a bogus RSSI like 0 or > -40 (may happen with iPhone 5S). It will also filter out beacons that are not within the specified proximity two times (seconds) in a row. This might make the beacon triggering slower, but I found this is important for the user experience because it filters out quite some "misfires".

The class uses a delegate. Please refer to the sample project. Don't forget to add iBeaconTriggerDelegate to ViewController.h.

    - (void)proximityTriggeredForBeacon:(CLBeacon *)beacon {
    
        // actions for specific beacons here
    }

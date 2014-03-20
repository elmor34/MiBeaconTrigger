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

#import "MiBeaconTrigger.h"

@implementation MiBeaconTrigger

- (void)startTriggeringForBeaconsWithUUID:(NSString *)uuidString major:(NSInteger)major minors:(NSArray *)minors minimumProximity:(CLProximity)proximity logging:(BOOL)logging {
    latestMinor = -1;
    
    monitorMajor = major;
    monitorMinors = minors;
    minimumProximity = proximity;
    loggingEnabled = logging;
    if (!loggingEnabled) loggingEnabled = NO;
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidString];
    
    // Mutable copy to work with
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    
    for (NSNumber *num in minors) {
        if ([num intValue] > 65536) NSLog(@"Warning: found invalid minor value: %d", [num intValue]);
    }
    
    if (([uuidString length] == 36) && ([[uuidString componentsSeparatedByString:@"-"] count] == 5) && (minors.count > 0) && (major <= 65536) && (proximity && proximity != CLProximityUnknown)) {
        beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"not.so.important"];
        [locationManager startRangingBeaconsInRegion:beaconRegion];
    }
    else {
        NSLog(@"\nInput error. Is the UUID invalid, is the major identifier > 65536, is the number of minors 0, or is the Proximity set to CLProximityUnknown (0)?\n\nUUID: %@\nMajor: %ld\nNumber of minors: %lu\nProximity: %ld", uuidString, (long)major, (unsigned long)[minors count], proximity);
    }
}

- (void)stopTriggering {
    [locationManager stopRangingBeaconsInRegion:beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    NSMutableArray *beaconsCopy = [beacons mutableCopy];
    
    // beacons are sorted ascending on their rssi. Beacons with 0 rssi are included, but we don;t want that. So if the closest beacon has rssi 0 and there is another one, take that one. Also exclude beacons with minors other than the ones we want
    
    // find all beacons not matching criteria to remove them later
    NSMutableArray *beaconsToRemove = [[NSMutableArray alloc] init];
    for (CLBeacon *beacon in beaconsCopy) {
        
        // filter bogus accuracy and RSSI
        if ((beacon.accuracy < 0) || (labs(beacon.rssi) < 40)) {
            [beaconsToRemove addObject:beacon];
        }
    }
    // remove beacons not matching criteria
    for (CLBeacon *beaconToRemove in beaconsToRemove) {
        [beaconsCopy removeObject:beaconToRemove];
    }
    
    if ([beaconsToRemove count] > 0) NSLog(@"removing beacons:%@", beaconsToRemove);
    
    // array might be unsorted now > make beacon with best RSSI closestBeacon
    NSInteger bestRSSI = 999;
    CLBeacon *closestBeacon;
    for (int i = 0; i < [beaconsCopy count]; i++)
    {
        CLBeacon *tempBeacon = [beaconsCopy objectAtIndex:i];
        
        if (labs(tempBeacon.rssi) < bestRSSI)
        {
            closestBeacon = tempBeacon;
            bestRSSI = labs(tempBeacon.rssi);
        }
    }
    
    // filter out misfires (one beacon at far distance that shows up very close for 1 time)
    if ([closestBeacon.minor intValue] != consistencyBeaconMinor)
    {
        consistencyBeaconMinor = [closestBeacon.minor intValue];
        consistency = 0;
    }
    else
    {
        consistency++;
    }
    
    // trigger delegate?
    if ((closestBeacon.proximity > 0) && (closestBeacon.proximity <= minimumProximity) && (consistency > 0) && (([closestBeacon.minor intValue] != latestMinor) || (latestMinor < 0)) && ([monitorMinors containsObject:closestBeacon.minor]))
    {
        [_delegate proximityTriggeredForBeacon:closestBeacon];
        latestMinor = [closestBeacon.minor intValue];
        
        if (loggingEnabled == YES) NSLog(@"///////////////////////// TRIGGERED BEACON WITH MINOR: %ld\n\n", (long)[closestBeacon.minor integerValue]);
    }
    else
    {
        if (loggingEnabled == YES) NSLog(@"Not triggered!\nClosest Beacon Minor: %ld, already triggered:%ld (won't trigger if those are the same)\nMaximum proximity enum: %ld actual: %ld (won't trigger if actual > maximum)\nConsistency:%ld (if all in order will trigger at > 0)\n\n)", (long)[closestBeacon.minor integerValue], (long)latestMinor, (long)minimumProximity, (long)closestBeacon.proximity, (long)consistency);
    }
}

@end

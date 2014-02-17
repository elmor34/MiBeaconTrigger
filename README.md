MiBeaconTrueProximityDemo
=========================

This class filters out beacons with proximity unknown, and also beacons with a bogus RSSI like 0 or > -40 (may happen with iPhone 5S). It will also filter out beacons that are not within the specified proximity two times (seconds) in a row. This might make the beacon triggering slower, but I found this is important for the user experience because it filters out quite some "misfires".

The class uses a delegate. Please refer to the sample project.

    - (void)trueProximityTriggeredForBeacon:(CLBeacon *)beacon {
    
        // actions for specific beacons here
    }
    
You can enable logging if you want to see what's going on.

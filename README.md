MiBeaconTrueProximityDemo
=========================

Trigger new iBeacons that are truly proximate. This filters out beacons with proximity unknown, and also beacons with a bogus RSSI like 0 or > -40 (may happen with iPhone 5S).

The class uses a delegate. Please refer to the sample project.

    - (void)trueProximityTriggeredForBeacon:(CLBeacon *)beacon {
    
        // trigger specific action for beacon here
    }
    
You can enable logging if you want to see what's going on.

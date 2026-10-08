# Donate harness

The donate sheet, passive signing-status row and Ko-fi button over a stand-in Home, on the simulator. Only `Donate.m`,
`Certificate.m`, the page style and Core's glass are compiled.

    ./build.sh
    xcrun simctl install booted build/DonateHarness.app
    xcrun simctl launch booted com.vojta.donateharness sheet   # or: tour, signing

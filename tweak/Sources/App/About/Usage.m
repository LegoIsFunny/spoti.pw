// What the update check used to post to spoti.pw. The body and its payload were removed in the
// Auralis fork; SGUsageBody returns nil, so nothing is sent anywhere.
#import "Core/SGCore.h"
#import "About.h"

// Still used to mark the day a check was made, so repeated launches don't re-check.
static NSString *const kAsked = @"spotipw.asked";

// Not SGEnabled: after a reset that reads every unset switch as off, and this is not one of them.
static BOOL usageOn(void) {
    id stored = [NSUserDefaults.standardUserDefaults objectForKey:SGKeyUsage];
    return stored ? [stored boolValue] : YES;
}

// Asked on every return to the front, so the formatter is made once.
static NSString *today(void) {
    static NSDateFormatter *format;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        format = [NSDateFormatter new];
        format.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        format.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        format.dateFormat = @"yyyy-MM-dd";
    });
    return [format stringFromDate:NSDate.date];
}

BOOL SGUsageOwed(void) {
    return usageOn() && ![[NSUserDefaults.standardUserDefaults stringForKey:kAsked] isEqualToString:today()];
}

// Marked when asked, not when answered: a day the server is down costs that day's count, not a
// request on every launch.
void SGUsageNoteAsked(void) {
    [NSUserDefaults.standardUserDefaults setObject:today() forKey:kAsked];
}

NSData *SGUsageBody(void) {
    return nil;
}
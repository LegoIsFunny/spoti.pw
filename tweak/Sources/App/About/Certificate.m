// The current signing profile's kind and actual expiration date, shown passively in Mod Settings.
#import "Settings/SGModPage.h"
#import "About.h"
#import <math.h>

static const NSTimeInterval kDay = 86400;
static const NSTimeInterval kFreeLongest = 8 * kDay;

static NSDictionary *profile(void) {
    static NSDictionary *read;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        NSString *path = [NSBundle.mainBundle pathForResource:@"embedded" ofType:@"mobileprovision"];
        NSData *data = path ? [NSData dataWithContentsOfFile:path] : nil;
        if (!data.length) return;
        // The plist sits as plain text inside the profile's CMS envelope.
        NSRange all = NSMakeRange(0, data.length);
        NSRange start = [data rangeOfData:[@"<?xml" dataUsingEncoding:NSASCIIStringEncoding] options:0 range:all];
        NSRange end = [data rangeOfData:[@"</plist>" dataUsingEncoding:NSASCIIStringEncoding] options:NSDataSearchBackwards range:all];
        if (start.location == NSNotFound || end.location == NSNotFound || end.location < start.location) return;
        NSData *plist = [data subdataWithRange:NSMakeRange(start.location, NSMaxRange(end) - start.location)];
        id parsed = [NSPropertyListSerialization propertyListWithData:plist options:0 format:NULL error:NULL];
        if ([parsed isKindOfClass:NSDictionary.class]) read = parsed;
    });
    return read;
}

static NSDate *dateIn(NSDictionary *info, NSString *key) {
    id value = info[key];
    return [value isKindOfClass:NSDate.class] ? value : nil;
}

NSDate *SGCertificateExpiry(void) {
    return dateIn(profile(), @"ExpirationDate");
}

NSString *SGCertificateKind(void) {
    NSDictionary *info = profile();
    if (!info) return @"none";
    if ([info[@"ProvisionsAllDevices"] boolValue]) return @"enterprise";
    NSDate *created = dateIn(info, @"CreationDate"), *expires = dateIn(info, @"ExpirationDate");
    if (!created || !expires) return nil;
    return [expires timeIntervalSinceDate:created] <= kFreeLongest ? @"free" : @"paid";
}

static NSString *dateText(NSDate *date) {
    NSDateFormatter *format = [NSDateFormatter new];
    format.dateStyle = NSDateFormatterMediumStyle;
    format.timeStyle = NSDateFormatterNoStyle;
    return [format stringFromDate:date];
}

static NSString *signingKindText(NSString *kind) {
    if ([kind isEqualToString:@"free"]) return @"Free";
    if ([kind isEqualToString:@"paid"]) return @"Paid";
    if ([kind isEqualToString:@"enterprise"]) return @"Enterprise";
    return nil;
}

static NSString *certificateStatus(void) {
    NSString *kind = signingKindText(SGCertificateKind());
    NSDate *expires = SGCertificateExpiry();
    if (!kind) return @"Signing status unavailable";
    if (!expires) return [NSString stringWithFormat:@"%@ · expiry unavailable", kind];

    NSString *date = dateText(expires);
    NSTimeInterval remaining = [expires timeIntervalSinceNow];
    if (remaining <= 0) return [NSString stringWithFormat:@"%@ · expired %@", kind, date];

    NSUInteger days = (NSUInteger)ceil(remaining / kDay);
    NSString *left = [NSString stringWithFormat:@"%lud left", (unsigned long)days];
    return [NSString stringWithFormat:@"%@ · %@ · %@", kind, date, left];
}

SGModRow *SGCertificateRow(void) {
    return SGWithSymbol(SGStatRow(@"Signing", ^NSString *{ return certificateStatus(); }), @"signature");
}

// The saved composition of the redesign's bar, as NSUserDefaults property lists, apart from the native look's.
#import "Navbar.h"
#import "Shared/Navigation/Links.h"

NSString *const SGRNavbarID = @"id";
NSString *const SGRNavbarTitle = @"title";
NSString *const SGRNavbarURI = @"uri";
NSString *const SGRNavbarIcon = @"icon";
NSString *const SGRNavbarHidden = @"hidden";

static NSString *const kNavbarLayout = @"spotifyglass.redesign.navbar.layout";
static NSString *const kNavbarStock = @"spotifyglass.redesign.navbar.stock";

// Only property list types go in, so a corrupt read cannot be anything but an array of dictionaries.
static NSArray *listOfKind(NSString *key, Class kind) {
    NSArray *list = [NSUserDefaults.standardUserDefaults arrayForKey:key];
    for (id item in list) if (![item isKindOfClass:kind]) return @[];
    return list ?: @[];
}

NSArray<NSDictionary *> *SGRNavbarLayout(void) {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        NSArray<NSDictionary *> *layout = listOfKind(kNavbarLayout, NSDictionary.class);
        __block NSMutableArray<NSDictionary *> *updated = nil;
        [layout enumerateObjectsUsingBlock:^(NSDictionary *entry, NSUInteger index, BOOL *stop) {
            id uri = entry[SGRNavbarURI], icon = entry[SGRNavbarIcon];
            if (![uri isKindOfClass:NSString.class] || ![uri isEqualToString:@"spotify:collection:tracks"]
                || ![icon isKindOfClass:NSString.class] || ![icon isEqualToString:@"heart"]) return;
            if (!updated) updated = [layout mutableCopy];
            NSMutableDictionary *corrected = [entry mutableCopy];
            corrected[SGRNavbarIcon] = @"sf:heart.fill";
            updated[index] = corrected;
        }];
        if (updated) [NSUserDefaults.standardUserDefaults setObject:updated forKey:kNavbarLayout];
    });
    return listOfKind(kNavbarLayout, NSDictionary.class);
}

void SGRSetNavbarLayout(NSArray<NSDictionary *> *layout) {
    [NSUserDefaults.standardUserDefaults setObject:layout ?: @[] forKey:kNavbarLayout];
}

NSArray<NSString *> *SGRNavbarStock(void) {
    return listOfKind(kNavbarStock, NSString.class);
}

void SGRSetNavbarStock(NSArray<NSString *> *stock) {
    [NSUserDefaults.standardUserDefaults setObject:stock ?: @[] forKey:kNavbarStock];
}

NSURL *SGRNavbarTabURL(NSString *uri) {
    NSURL *url = SGSpotifyURIFromText(uri);
    if ([url.absoluteString isEqualToString:@"spotify:collection:playlists"]) return [NSURL URLWithString:@"spotify:playlists"];
    return url;
}

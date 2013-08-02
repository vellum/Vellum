//
//  VLMConstants.h
//  Vellum
//
//  Created by David Lu on 6/13/13.
//
//

#pragma mark -
#pragma mark Style and Layout

#define HEADER_CORNER_RADIUS 0.0f
#define STATUSBAR_HEIGHT 20.0f
#define HEADER_HEIGHT 60.0f
#define FOOTER_HEIGHT 60.0f
#define SECTION_HEADER_HEIGHT 80.0f
#define HEADER_TITLE_VERTICAL_OFFSET -7.0f
#define BAR_BUTTON_ITEM_VERTICAL_OFFSET -6.0f
#define NAVIGATION_HEADER_TITLE_SIZE 15.0f
#define ANIMATION_DURATION 0.2f

#define JOT_X_OFFSET 4.0f // compensate for jot stylus
#define JOT_Y_OFFSET 6.0f
#define OLD_DEVICE_SCREEN_MULTIPLIER 1.5f
//#define FAT_HEADER
//#define STYLED_HEADER

#pragma mark -
#pragma mark Colors

#define WINDOW_BGCOLOR [UIColor colorWithPatternImage:[UIImage imageNamed:@"subtlenet.png"]]
#define MAIN_VIEW_BGCOLOR [UIColor clearColor]
#define FEED_VIEW_BGCOLOR [UIColor clearColor]
#define FEED_HEADER_BGCOLOR [UIColor colorWithWhite:0.9f alpha:1.0f]
#define NAVIGATION_HEADER_BACKGROUND_IMAGE [UIImage imageNamed:@"gray_header_background.png"]
#define FOOTER_BGCOLOR [UIColor colorWithWhite:0.9f alpha:1.0f]
#define FEED_TABLEVIEW_BGCOLOR [UIColor colorWithPatternImage:[UIImage imageNamed:@"subtlenet.png"]]
#define FEED_SECTION_HEADER_BGCOLOR [UIColor whiteColor]

#define TEXT_COLOR [UIColor colorWithHue:0.87f saturation:0.0f brightness:0.12f alpha:1.0f]
#define FOOTER_TEXT_COLOR [UIColor colorWithWhite:0.2f alpha:1.0f]
#define DISABLED_TEXT_COLOR [UIColor colorWithWhite:0.1f alpha:0.25f]

#pragma mark -
#pragma mark Typefaces

#define HEADER_TITLE_FONT @"AmericanTypewriter"
#define NAVIGATION_HEADER @"AmericanTypewriter"
#define SECTION_FONT_BOLD @"AmericanTypewriter-Bold"
#define SECTION_FONT_REGULAR @"AmericanTypewriter"
#define FOOTER_FONT @"AmericanTypewriter"
#define TEXTBUTTON_FONT @"HelveticaNeue-Bold"
#define PHOTO_LABEL @"AmericanTypewriter"

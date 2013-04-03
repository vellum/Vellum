//
//  VLMToolViewController.m
//  Test
//
//  Created by David Lu on 4/2/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import "VLMToolViewController.h"
#import "UINavigationBar+Fat.h"

@interface VLMToolViewController ()

@end

@implementation VLMToolViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 480.0);
        self.title = @"Customize";
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"subtlenet.png"]]];

        [self.navigationItem setHidesBackButton:YES];
        UIBarButtonItem *backbutton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
        [self.navigationItem setLeftBarButtonItem:backbutton];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)done:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self];
}

@end

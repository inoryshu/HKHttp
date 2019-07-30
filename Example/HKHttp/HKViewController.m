//
//  HKViewController.m
//  HKHttp
//
//  Created by inoryshu on 07/30/2019.
//  Copyright (c) 2019 inoryshu. All rights reserved.
//

#import "HKViewController.h"
#import "HKHttp.h"

@interface HKViewController ()

@end

@implementation HKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [HKHttp GET]
    .hkBaseUrl(<#NSString *value#>)
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  EmailViewController.h
//  i90X 2
//
//  Created by Jared Grant on 7/1/12.
//  Copyright (c) 2012 Canyons School District. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsNavController.h"

@interface EmailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *defaultEmail;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;

- (IBAction)hideKeyboard:(id)sender;
- (IBAction)saveEmail:(id)sender;
@end

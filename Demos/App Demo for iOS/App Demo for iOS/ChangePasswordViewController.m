//
//  ChangePasswordViewController.m
//  App Demo for iOS
//
//  Created by Rad on 2014-08-11.
//  Copyright (c) 2014 AgileBits. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "OnePasswordExtension.h"

@interface ChangePasswordViewController ()

@property (weak, nonatomic) IBOutlet UIButton *onepasswordButton;
@property (weak, nonatomic) IBOutlet UITextField *oldPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *freshPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;

@end

@implementation ChangePasswordViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self.view setBackgroundColor:[[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"login-background.png"]]];
	[self.onepasswordButton setHidden:![[OnePasswordExtension sharedExtension] isAppExtensionAvailable]];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
	return UIStatusBarStyleLightContent;
}

- (IBAction)changePasswordIn1Password:(id)sender {
	NSString *newPassword = self.freshPasswordTextField.text ? : @"";
	NSString *oldPassword = self.oldPasswordTextField.text ? : @"";
	NSString *confirmationPassword = self.confirmPasswordTextField.text ? : @"";

	// Validate that the new password and the old password are not the same.
	if (oldPassword.length > 0 && [oldPassword isEqualToString:newPassword]) {
		[self showChangePasswordFailedAlertWithMessage:@"The old and the new password must not be the same"];
		return;
	}

	// Validate that the new and confirmation passwords match.
	if (NO == [newPassword isEqualToString:confirmationPassword]) {
		[self showChangePasswordFailedAlertWithMessage:@"The new passwords and the confirmation password must match"];
		return;
	}

	/* 
	 These are the three scenarios that are supported:
	 1. A signle matching Login is found: 1Password will enter edit mode for that Login and will update its password using the value for AppExtensionPasswordKey.
	 2. More than a one matching Logins are found: 1Password will display a list of all matching Logins. The user must choose which one to update. Once in edit mode, the Login will be updated with the new password.
	 3. No matching login is found: 1Password will create a new Login using the optional fields if available to populate its properties.
	*/
	
	NSDictionary *loginDetails = @{
									  AppExtensionTitleKey: @"ACME", // Optional, used for the third schenario only
									  AppExtensionUsernameKey: @"aUsername", // Optional, used for the third schenario only
									  AppExtensionPasswordKey: newPassword,
									  AppExtensionOldPasswordKey: oldPassword,
									  AppExtensionNotesKey: @"Saved with the ACME app", // Optional, used for the third schenario only
									};

	// Password generation options are optional, but are very handy in case you have strict rules about password lengths
	NSDictionary *passwordGenerationOptions = @{
												AppExtensionGeneratedPasswordMinLengthKey: @(6), // The minimum value can be 4 or more
												AppExtensionGeneratedPasswordMaxLengthKey: @(50) // The maximum value can be 50 or less
												};

	[[OnePasswordExtension sharedExtension] changePasswordForLoginForURLString:@"https://www.acme.com" loginDetails:loginDetails passwordGenerationOptions:passwordGenerationOptions forViewController:self sender:sender completion:^(NSDictionary *loginDictionary, NSError *error) {
		if (loginDictionary.count == 0) {
			if (error.code != AppExtensionErrorCodeCancelledByUser) {
				NSLog(@"Error invoking 1Password App Extension for find login: %@", error);
			}
			return;
		}

		self.oldPasswordTextField.text = loginDictionary[AppExtensionOldPasswordKey];
		self.freshPasswordTextField.text = loginDictionary[AppExtensionPasswordKey];
		self.confirmPasswordTextField.text = loginDictionary[AppExtensionPasswordKey];
	}];
}

#pragma mark - Convenience methods

- (void)showChangePasswordFailedAlertWithMessage:(NSString *)message {
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Change Password Error" message:message preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
		self.freshPasswordTextField.text = @"";
		self.confirmPasswordTextField.text = @"";
		[self.freshPasswordTextField becomeFirstResponder];
	}];

	[alert addAction:dismissAction];
	[self presentViewController:alert animated:YES completion:nil];
}

@end

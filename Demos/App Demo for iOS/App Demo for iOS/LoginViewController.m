//
//  SignInViewController.m
//  1Password Extension Demo
//
//  Created by Rad on 2014-07-14.
//  Copyright (c) 2014 AgileBits. All rights reserved.
//

#import "LoginViewController.h"
#import "OnePasswordExtension.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UIButton *onepasswordButton;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *oneTimePasswordTextField;
@end

@implementation LoginViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	[self.view setBackgroundColor:[[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"login-background.png"]]];
	[self.onepasswordButton setHidden:![[OnePasswordExtension sharedExtension] isAppExtensionAvailable]];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
	return UIStatusBarStyleLightContent;
}

#pragma mark - Actions

- (IBAction)findLoginFrom1Password:(id)sender {
	[[OnePasswordExtension sharedExtension] findLoginForURLString:@"https://www.acme.com" forViewController:self sender:sender completion:^(NSDictionary *loginDictionary, NSError *error) {
		if (loginDictionary.count == 0) {
			if (error.code != AppExtensionErrorCodeCancelledByUser) {
				NSLog(@"Error invoking 1Password App Extension for find login: %@", error);
			}
			return;
		}
		
		self.usernameTextField.text = loginDictionary[AppExtensionUsernameKey];
		self.passwordTextField.text = loginDictionary[AppExtensionPasswordKey];

		// Optional
		// Retrive the generated one-time Password from the 1Password Login if available.
		NSString *generatedOneTimePassword = loginDictionary[AppExtensionTOTPKey];
		if (generatedOneTimePassword.length > 0) {
			[self.oneTimePasswordTextField setHidden:NO];
			self.oneTimePasswordTextField.text = generatedOneTimePassword;

			// Important: It is recommended that you submit the OTP/TOTP to your validation server as soon as you receive it, otherwise it may expire.
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				[self performSegueWithIdentifier:@"showThankYouViewController" sender:self];
			});
		}
	}];
}

@end

//
//  AppDelegate.m
//  Daily Dozen
//
//  Created by Chan Kruse on 2015-10-02.
//  Copyright © 2015 NutritionFacts.org. All rights reserved.
//

#import "AppDelegate.h"
#import "DailyReportViewController.h"
#import "ColorConstants.h"

@interface AppDelegate ()

@property (nonatomic, strong) DailyReportViewController *dailyReportViewController;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
	
	NSString *recommendationString = [NSString stringWithFormat:@"<b>Recommendation:</b>"];
	
	NSAttributedString *recommendationText = [[NSAttributedString alloc] initWithData:[recommendationString dataUsingEncoding:NSUTF8StringEncoding]
																			  options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
																						NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)}
																   documentAttributes:nil
																				error:nil];
	
	[[UINavigationBar appearance] setBarTintColor:kColorNavBar];
//	[[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
	[[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
	[[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
	
	DailyReportViewController *vController = [[DailyReportViewController alloc] init];
	self.dailyReportViewController = vController;
	UINavigationController *nController = [[UINavigationController alloc] initWithRootViewController:vController];
	nController.navigationBar.translucent = NO;
	
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.window.rootViewController = nController;
	
	[self.window makeKeyAndVisible];
	return YES;
	
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	[self.dailyReportViewController appForegrounded];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	// Saves changes in the application's managed object context before the application terminates.
}

@end

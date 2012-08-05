/*
 * Copyright 2011,2012 Mohammed Alrokayan
 *
 *  This file is part of MyKeyboard.
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "AdViewController.h"
#import "FBConnect/FBConnect.h"
#import "MOFBHelper.h"

@interface ViewController : UIViewController {
	IBOutlet UIButton *theShift;
	IBOutlet UIButton *deleteAll;
	bool isShiftPressed;
	bool isUndo;
	
	//FACEBOOK
	FBSession* _session;
	FBLoginDialog *_loginDialog;
	UIButton *_postGradesButton;
	UIButton *_logoutButton;
	NSString *_facebookName;
	BOOL _posting;
	
	MOFBHelper *fbHelper;
    //
    
    //TWITTER
    NSString *username;
	NSString *password;
    //
	
	
    IBOutlet UIWebView *webTxtAra;
	
	AdViewController *adMob;
	AdViewController *adMob2;
	AdViewController *adMob3;
}

- (IBAction) userPressedAKey:(id)sender;
- (IBAction) copyAndExit;
- (IBAction) clean;
- (IBAction) pressShift;

- (IBAction) buyNow;

@property (nonatomic,retain) IBOutlet AdViewController *adMob;
@property (nonatomic,retain) IBOutlet AdViewController *adMob2;
@property (nonatomic,retain) IBOutlet AdViewController *adMob3;

//FACEBOOK
@property (nonatomic, retain) FBSession *session;
@property (nonatomic, retain) IBOutlet UIButton *postGradesButton;
@property (nonatomic, retain) IBOutlet UIButton *logoutButton;
@property (nonatomic, retain) FBLoginDialog *loginDialog;
@property (nonatomic, copy) NSString *facebookName;
@property (nonatomic, assign) BOOL posting;

- (IBAction)postGradesTapped:(id)sender;
- (IBAction)logoutButtonTapped:(id)sender;
- (void)postToWall;
- (void)getFacebookName;
//

//Twitter
- (IBAction) postTwitter: (id) sender;
//


@end


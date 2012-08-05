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

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "TwitterRequest.h"
#import "AlertPrompt.h"

@implementation ViewController

@synthesize adMob, adMob2, adMob3;
//FACEBOOK
@synthesize session = _session;
@synthesize postGradesButton = _postGradesButton;
@synthesize logoutButton = _logoutButton;
@synthesize loginDialog = _loginDialog;
@synthesize facebookName = _facebookName;
@synthesize posting = _posting;
//

- (UIWebView*) getWebTxtAra {
    return webTxtAra;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	isShiftPressed = FALSE;
	isUndo = FALSE;
	
	NSString *embedURL =@"\
	<SCRIPT LANGUAGE=\"JavaScript\">\
    \
	function KeyType() {\
  	var subject=document.getElementsByTagName('textarea')[0];\
	if (document.selection) {\
		var range=document.selection.createRange();\
		range.text=arguments[0];\
		return;\
	}\
	else if (subject.selectionStart || subject.selectionStart=='0') {\
		var str=subject.value;\
		var a=subject.selectionStart, b=subject.selectionEnd;\
		subject.value=str.substring(0,a)+arguments[0]+str.substring(b,str.length);\
		return;\
	}\
	subject.value+=arguments[0];\
	}\
    \
    function setCursor(el,st,end) {\
        if(el.setSelectionRange) {\
            el.focus();\
            el.setSelectionRange(st,end);\
        }\
        else {\
            if(el.createTextRange) {\
            range=el.createTextRange();\
            range.collapse(true);\
            range.moveEnd('character',end);\
            range.moveStart('character',st);\
            range.select();\
            }\
        }\
	}\
    </SCRIPT>\
	<DIV ALIGN = CENTER>\
	<style type=\"text/css\"> #taID { height:83px;width:1024px; font-size:x-large; direction:rtl; } </style>\
		<textarea id=\"taID\">";
	
	
	if ([[NSUserDefaults standardUserDefaults] stringForKey:@"lastText"] == nil)
		embedURL = [NSString stringWithFormat:@"%@%@",embedURL,@"انقر هنا للكتابه …</textarea> </DIV>"];
	else
		embedURL = [NSString stringWithFormat:@"%@%@%@",embedURL,[[NSUserDefaults standardUserDefaults] stringForKey:@"lastText"],@"</textarea> </DIV>"];
	
	[webTxtAra loadHTMLString:embedURL baseURL:nil];
	
	for (id subview in webTxtAra.subviews)
		if ([[subview class] isSubclassOfClass: [UIScrollView class]])
			((UIScrollView *)subview).bounces = NO;
	
	
	[NSTimer scheduledTimerWithTimeInterval:12.5 target:self selector:@selector(check10) userInfo:nil repeats:NO];
	[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(check1sec) userInfo:nil repeats:YES];
	
	// Set these values from your application page on http://www.facebook.com/developers
	// Keep in mind that this method is not as secure as using the sessionForApplication:getSessionProxy:delegate method!
	// These values are from a dummy facebook app I made called MyGrades - feel free to play around!
    static NSString* kApiKey = @"YOURS";
    static NSString* kApiSecret = @"YOURS";
	_session = [[FBSession sessionForApplication:kApiKey secret:kApiSecret delegate:self] retain];
    
	// Load a previous session from disk if available.  Note this will call session:didLogin if a valid session exists.
	[_session resume];
	
	fbHelper = [[MOFBHelper alloc] init];
	fbHelper.delegate = self;
    
    //TWITTER
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"tUN"] == nil || [[NSUserDefaults standardUserDefaults] stringForKey:@"tPW"] == nil)
    {
        password = @"";
        username = @"";
    }
    else
    {
        //username = [[NSUserDefaults standardUserDefaults] stringForKey:@"tUN"];
        username = @"dd";
        password = [[NSUserDefaults standardUserDefaults] stringForKey:@"tPW"];
    }
    //
	
}


- (void)check10 {	
	NSString *js_result = [webTxtAra stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('textarea')[0].value;"];
	int txtLength = [js_result length];
	if (txtLength > 50) {
		UIAlertView *someMessage = [[UIAlertView alloc] initWithTitle: @"لقد تجاوزت الـ٥٠ حرف" message: @"النسخه المجانيه لاتسمح لك بنسخ أكثر من ٥٠ حرف …. هل تود شراء النسخه الكامله الآن؟" delegate: self cancelButtonTitle: @"لا" otherButtonTitles: nil];
		[someMessage addButtonWithTitle:@"نعم"];
		[someMessage show];
		[someMessage setTag:10];
		[someMessage release];
	}
	else
		[NSTimer scheduledTimerWithTimeInterval:12.5 target:self selector:@selector(check10) userInfo:nil repeats:NO];
}


- (void)check1sec {
	NSString *js_result = [[self getWebTxtAra] stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('textarea')[0].value;"];
	int txtLength = [js_result length];
	if (txtLength > 50) {
		UIPasteboard *appPasteBoard = [UIPasteboard generalPasteboard];
		[appPasteBoard setString:[js_result substringToIndex: 50]];
	}
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ([alertView tag] == 10) {    // it's the 50 Letters msg
		[NSTimer scheduledTimerWithTimeInterval:12.5 target:self selector:@selector(check10) userInfo:nil repeats:NO];
    }
	if ([alertView tag] == 10 && buttonIndex == 1) {     // and they clicked OK.
			[self buyNow];
	}
	if ([alertView tag] == 0 && buttonIndex == 1) {
		[self buyNow];
	}
}



- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
		return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
	return YES;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	
	//FACEBOOK
    self.postGradesButton = nil;
    self.logoutButton = nil;
    //
	
}



- (void)dealloc {
	[adMob release];
	[adMob2 release];
	[adMob3 release];
	//FACEBOOK
    [_session release];
	_session = nil;
	[_postGradesButton release];
	_postGradesButton = nil;
    [_logoutButton release];
	_logoutButton = nil;
    [_loginDialog release];
	_loginDialog = nil;
    [_facebookName release];
	_facebookName = nil;
    //	
    [super dealloc];
}


- (void)click
{
	//Play click.mp3
	NSString *path = [[NSBundle mainBundle] pathForResource:@"click" ofType:@"caf"];
	AVAudioPlayer* theAudio = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:NULL];
	theAudio.delegate = self;
	theAudio.volume = 0.15;
	[theAudio play];
}

- (IBAction) userPressedAKey:(id)sender
{
	@try
	{
		[self click];
		
		
		UIButton *b = (UIButton*)sender;
		NSString *letter = b.titleLabel.text;
		if (isShiftPressed)
		{
			//NSLog(@"%@%@",@"--------- letter = ",letter);
			if ([letter isEqualToString:@"ه"]) letter = @"ّ";
			if ([letter isEqualToString:@"ع"]) letter = @"ْ";
			if ([letter isEqualToString:@"غ"]) letter = @"ٌ";
			if ([letter isEqualToString:@"ف"]) letter = @"ُ";
			if ([letter isEqualToString:@"ق"]) letter = @"ٍ";
			if ([letter isEqualToString:@"ث"]) letter = @"ِ";
			if ([letter isEqualToString:@"ص"]) letter = @"ً";
			if ([letter isEqualToString:@"ض"]) letter = @"َ";
			if ([letter isEqualToString:@"ـ"]) letter = @"؟";
			if ([letter isEqualToString:@"ا"]) letter = @"آ";
			if ([letter isEqualToString:@"ي"]) letter = @"ى";
			if ([letter isEqualToString:@"و"]) letter = @"ؤ";
			if ([letter isEqualToString:@"ر"]) letter = @"إ";
			if ([letter isEqualToString:@"ز"]) letter = @"أ";
			if ([letter isEqualToString:@"د"]) letter = @"ء";
			if ([letter isEqualToString:@"ذ"]) letter = @"ئ";
            if ([letter isEqualToString:@"ك"]) letter = @"،";
			
			[theShift setBackgroundImage:[UIImage imageNamed:@"Shift_Black.jpg"] forState:UIControlStateNormal];
			isShiftPressed = FALSE;
		}
		
        //Save curser position
		NSString *cPos = [webTxtAra stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('textarea')[0].selectionEnd"];
        
		//Add the letter
        NSString *js_result = [webTxtAra stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('textarea')[0].value;"];
        js_result = [NSString stringWithFormat:@"%@%@",js_result,letter];
        js_result = [js_result stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
		[webTxtAra stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@%@%@",@"KeyType('",letter,@"');"]];
        
        //Reset curser position
        [webTxtAra stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@%@%@%@%@",@"setCursor(document.getElementsByTagName('textarea')[0],",cPos,@"+1,",cPos,@"+1);"]];
        
		if (isUndo)
		{
			[deleteAll setTitle:@"X" forState:UIControlStateNormal];
            deleteAll.frame = CGRectMake(deleteAll.frame.origin.x , deleteAll.frame.origin.y,20 ,20 );
			isUndo = FALSE;
		}
		
        //Save The Text
        js_result = [webTxtAra stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('textarea')[0].value;"];
        js_result = [NSString stringWithFormat:@"%@%@",js_result,letter];
        js_result = [js_result stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
        [[NSUserDefaults standardUserDefaults] setObject:js_result forKey:@"lastText"];
		
		
	}
	@catch (id theException) {
		NSLog(@"======== ERROR =========");
		NSLog(@"%@", theException);
        
        //Save The Text
        NSString *js_result = [webTxtAra stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('textarea')[0].value;"];
        js_result = [js_result stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
        [[NSUserDefaults standardUserDefaults] setObject:js_result forKey:@"lastText"];

		
		UIAlertView *someMessage = [[UIAlertView alloc] initWithTitle: @"عذرا على هذا الخلل" message: @"إذا أستمرت المشكلة يمكنك إغلاق ثم فتح البرنامج مره أخرى" delegate: self cancelButtonTitle: @"حسناً" otherButtonTitles: nil];
		[someMessage show];
		[someMessage release];	
	}
}


-(IBAction)copyAndExit
{
	[self click];
    
    NSString *js_result = [[self getWebTxtAra] stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('textarea')[0].value;"];
	UIPasteboard *appPasteBoard = [UIPasteboard generalPasteboard];
    
	if ([js_result length] > 50)
	{
		[appPasteBoard setString:[js_result substringToIndex: 50]];
		
		UIAlertView *someMessage = [[UIAlertView alloc] initWithTitle: @"تم النسخ ولكن …" message: @"النسخه المجانيه لاتسمح لك بنسخ أكثر من ٥٠ حرف …. هل تود شراء النسخه الكامله الآن؟" delegate: self cancelButtonTitle: @"لا" otherButtonTitles: nil];
		[someMessage addButtonWithTitle:@"نعم"];
		[someMessage setTag:0];
		[someMessage show];
		[someMessage release];
		
	}
	else
		[appPasteBoard setString:js_result];
	
	
}

-(IBAction)clean
{
	[self click];
	
	if(isUndo)
	{
        [webTxtAra stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@%@%@",@"document.getElementsByTagName('textarea')[0].value='",[[NSUserDefaults standardUserDefaults] stringForKey:@"lastText"],@"';"]];

		[deleteAll setTitle:@"X" forState:UIControlStateNormal];
        deleteAll.frame = CGRectMake(deleteAll.frame.origin.x , deleteAll.frame.origin.y,20 ,20 );
		isUndo = FALSE;
	}
	else
	{
        //Save The Text
        NSString *js_result = [[self getWebTxtAra] stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('textarea')[0].value;"];
        js_result = [js_result stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
        [[NSUserDefaults standardUserDefaults] setObject:js_result forKey:@"lastText"];

        //Delete the Text
        [webTxtAra stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('textarea')[0].value='';"];
		
		[deleteAll setTitle:@"تراجع" forState:UIControlStateNormal];
        deleteAll.frame = CGRectMake(deleteAll.frame.origin.x , deleteAll.frame.origin.y,45 ,20 );
		isUndo = TRUE;
	}
}




-(IBAction)pressShift
{
	[self click];
	
	if (isShiftPressed)
	{
		[theShift setBackgroundImage:[UIImage imageNamed:@"Shift_Black.jpg"] forState:UIControlStateNormal];
		isShiftPressed = FALSE;
	}
	else
	{
		[theShift setBackgroundImage:[UIImage imageNamed:@"Shift_Blue.jpg"] forState:UIControlStateNormal];
		isShiftPressed = TRUE;
	}
	
}


-(IBAction)buyNow
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://itunes.apple.com/app/id377637892"]];
		
}

-(IBAction)openInYouTube
{
    NSString *js_result = [[self getWebTxtAra] stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('textarea')[0].value;"];
    
    js_result = [NSString stringWithFormat:@"http://m.youtube.com/results?search_query=%@",js_result];
    js_result = [js_result stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: js_result]];
    
}

-(IBAction)openInEmail
{
    NSString *js_result = [[self getWebTxtAra] stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('textarea')[0].value;"];
    
    js_result = [NSString stringWithFormat:@"mailto:?subject=%@&body=%@", @"للأهميه", js_result];
    js_result = [js_result stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: js_result]];
    
}

-(IBAction)openInGoogle
{
    NSString *js_result = [[self getWebTxtAra] stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('textarea')[0].value;"];
    
    js_result = [NSString stringWithFormat:@"http://google.com/search?q=%@", js_result];
    js_result = [js_result stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: js_result]];
    
}

-(IBAction)openInBing
{
    NSString *js_result = [[self getWebTxtAra] stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('textarea')[0].value;"];
    
    js_result = [NSString stringWithFormat:@"http://www.bing.com/search?q=%@", js_result];
    js_result = [js_result stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: js_result]];
    
}


- (IBAction) postTwitter: (id) sender{
	
    //TWITTER
	AlertPrompt *prompt = [AlertPrompt alloc];
	prompt = [prompt initWithTitle:@"تسجيل الدخول إلى Twitter\n\n\n" message:@"" delegate:self cancelButtonTitle:@"إلغاء" okButtonTitle:@"إرسال النص"];
	[prompt setTag:99];
	[prompt show];
	[prompt release];
    //
	
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex != [alertView cancelButtonIndex] && [alertView tag] == 99)
	{
		username = [(AlertPrompt *)alertView enteredText1];
		password = [(AlertPrompt *)alertView enteredText2];
		
		TwitterRequest * t = [[TwitterRequest alloc] init];
		t.username = username;
		t.password = password;
		
		[[NSUserDefaults standardUserDefaults] setObject:username forKey:@"tUN"];
		[[NSUserDefaults standardUserDefaults] setObject:password forKey:@"tPW"];
		
		NSString *tweetmesage = [[self getWebTxtAra] stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('textarea')[0].value;"];
        //NSString *tweetmesage = @"السلام";
		
		[t statuses_update:tweetmesage delegate:self requestSelector:@selector(status_updateCallback:)];
	}
}
//END TWITTER



//FACEBOOK
- (IBAction)postGradesTapped:(id)sender {
	
	_posting = YES;
	// If we're not logged in, log in first...
	if (![_session isConnected]) {
		self.loginDialog = nil;
		_loginDialog = [[FBLoginDialog alloc] init];	
		[_loginDialog show];	
	}
	// If we have a session and a name, post to the wall!
	else if (_facebookName != nil) {
		[self postToWall];
	}
	// Otherwise, we don't have a name yet, just wait for that to come through.
}

- (IBAction)logoutButtonTapped:(id)sender {
	[_session logout];
    UIAlertView *someMessage = [[UIAlertView alloc] initWithTitle: @"تم تسجيل الخروج" message: @"" delegate: self cancelButtonTitle: @"حسناً" otherButtonTitles: nil];
	[someMessage show];
	[someMessage release];
	
}


#pragma mark FBSessionDelegate methods

- (void)session:(FBSession*)session didLogin:(FBUID)uid {
	[self getFacebookName];
}

- (void)session:(FBSession*)session willLogout:(FBUID)uid {
	_logoutButton.hidden = YES;
	_facebookName = nil;
}

#pragma mark Get Facebook Name Helper

- (void)getFacebookName {
	NSString* fql = [NSString stringWithFormat:
					 @"select uid,name from user where uid == %lld", _session.uid];
	NSDictionary* params = [NSDictionary dictionaryWithObject:fql forKey:@"query"];
	[[FBRequest requestWithDelegate:self] call:@"facebook.fql.query" params:params];
}

#pragma mark FBRequestDelegate methods

- (void)request:(FBRequest*)request didLoad:(id)result {
	if ([request.method isEqualToString:@"facebook.fql.query"]) {
		NSArray* users = result;
		NSDictionary* user = [users objectAtIndex:0];
		NSString* name = [user objectForKey:@"name"];
		self.facebookName = name;		
		_logoutButton.hidden = NO;
		[_logoutButton setTitle:[NSString stringWithFormat:@"Facebook: Logout as %@", name] forState:UIControlStateNormal];
		if (_posting) {
			[self postToWall];
			_posting = NO;
		}
	}
}

#pragma mark Post to Wall Helper

- (void)postToWall {
	
	NSString *js_result = [[self getWebTxtAra] stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('textarea')[0].value;"];
	fbHelper.status = js_result;
}






- (void)statusDidUpdate:(MOFBHelper*)helper {
	UIAlertView *someMessage = [[UIAlertView alloc] initWithTitle: @"تم الإرسال إلى الـFacebook" message: @"" delegate: self cancelButtonTitle: @"حسناً" otherButtonTitles: nil];
	[someMessage show];
	[someMessage release];
}

-(void)status:(MOFBHelper*)helper DidFailWithError:(NSError*)error {
	UIAlertView *someMessage = [[UIAlertView alloc] initWithTitle: @"يوجد خطأ في الإتصال مع الـFacebook" message: [error description] delegate: self cancelButtonTitle: @"حسناً" otherButtonTitles: nil];
	[someMessage show];
	[someMessage release];
}

//END FACEBOOK METHONDS


- (IBAction)FACEBOOK_AND_TWITTER:(id)sender {
    [self postGradesTapped:sender];
    [self postTwitter:sender];
}


@end

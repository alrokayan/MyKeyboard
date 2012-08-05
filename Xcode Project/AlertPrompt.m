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

#import "AlertPrompt.h"


@implementation AlertPrompt
@synthesize textField1,textField2;
@synthesize enteredText1,enteredText2;
- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okayButtonTitle
{

	if (self = [super initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:okayButtonTitle, nil])
	{
        /*
		UITextField *theTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)]; 
		[theTextField setBackgroundColor:[UIColor whiteColor]]; 
		[self addSubview:theTextField];
		self.textField = theTextField;
		[theTextField release];
		CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, 130.0); 
		[self setTransform:translate];*/
        
        UITextField *TextField1 = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 24.0)]; 
		[TextField1 setBackgroundColor:[UIColor whiteColor]];
        [TextField1 setPlaceholder:@"أسم المستخدم"];
        if ([[NSUserDefaults standardUserDefaults] stringForKey:@"tUN"] != nil)
            [TextField1 setText:[[NSUserDefaults standardUserDefaults] stringForKey:@"tUN"]];
		[self addSubview:TextField1];
        
        
        UITextField *TextField2 = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 72.0, 260.0, 24.0)]; 
		[TextField2 setBackgroundColor:[UIColor whiteColor]];
        [TextField2 setPlaceholder:@"كلمة المرور"];
        if ([[NSUserDefaults standardUserDefaults] stringForKey:@"tPW"] != nil)
            [TextField2 setText:[[NSUserDefaults standardUserDefaults] stringForKey:@"tPW"]];
        [TextField2 setSecureTextEntry:YES];
		[self addSubview:TextField2];

        
		self.textField1 = TextField1;
        self.textField2 = TextField2;
		[TextField1 release];
        [TextField2 release];
        
		CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, 130.0); 
		[self setTransform:translate];

	}
	return self;
}
- (void)show
{
	[textField1 becomeFirstResponder];
	[super show];
}
- (NSString *)enteredText1
{
	return textField1.text;
}

- (NSString *)enteredText2
{
	return textField2.text;
}
- (void)dealloc
{
	[textField1 release];
    [textField2 release];
	[super dealloc];
}
@end

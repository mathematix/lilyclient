#import "LoginViewController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "RegexKitLite.h"
#import "LilybbsAppDelegate.h"

#define kLeftMargin				20.0
#define kTopMargin				20.0
#define kRightMargin			20.0
#define kTweenMargin			10.0
#define kTextFieldWidth   260.0
#define kTextFieldHeight		30.0
#define kViewTag			1		// for tagging our embedded controls for removal at cell recycle time
//用作保存用户名密码，后续要进行加密
#define kFilename        @"data.plist"

static NSString *kSectionTitleKey = @"sectionTitleKey";
static NSString *kRemKey = @"remKey";
static NSString *kUserKey = @"userKey";
static NSString *kPassKey = @"passKey";
static NSString *kLabelKey = @"labelKey";

@implementation LoginViewController
@synthesize dataSourceArray;
@synthesize userfield;
@synthesize pwfield;
@synthesize remswitch;
@synthesize request;

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
  [userfield release];
  [pwfield release];
  [remswitch release];
  [dataSourceArray release];
 // [request release];
  [activityIndicator release];
  [super dealloc];
}


- (void)viewWillAppear:(BOOL)animated{
  //如果是保存密码的话，这边加载
  [self loadPass];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
  self.title = NSLocalizedString(@"登录百合", @"");
  //数据，用来构建tableview
	self.dataSourceArray = [NSArray arrayWithObjects:
                          [NSDictionary dictionaryWithObjectsAndKeys:
                           @"用户名 密码", kSectionTitleKey,
                           self.userfield, kUserKey,
                           self.pwfield, kPassKey,
                           nil],
                          [NSDictionary dictionaryWithObjectsAndKeys:
                           @"其他", kSectionTitleKey,
                           @"记住密码", kLabelKey,
                           self.remswitch, kRemKey,
                           nil], nil];

  //创建navigation bar
  UINavigationBar* tableViewNavigationBar = [[UINavigationBar alloc] initWithFrame: CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
  
  UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"取消"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(cancelAction:)];
  self.navigationItem.leftBarButtonItem = cancelButton;
  [cancelButton release];
  
  UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]
                                 initWithTitle:@"登录" 
                                 style:UIBarButtonItemStyleDone
                                 target:self
                                 action:@selector(loginAction:)];
  self.navigationItem.rightBarButtonItem = saveButton;
  [saveButton release];
  [tableViewNavigationBar sizeToFit]; 

  [self.navigationBar pushNavigationItem:self.navigationItem animated:FALSE];
}


#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [self.dataSourceArray count];
}

- (NSString *)tableView:(UITableView *)atableView titleForHeaderInSection:(NSInteger)section
{
	return [[self.dataSourceArray objectAtIndex: section] valueForKey:kSectionTitleKey];
}

- (NSInteger)tableView:(UITableView *)atableView numberOfRowsInSection:(NSInteger)section
{
  if (section==0) {
    return 2;
  }
  else
    return 1;
}

// to determine specific row height for each cell, override this.
// In this example, each row is determined by its subviews that are embedded.
//
- (CGFloat)tableView:(UITableView *)atableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 50.0;
}

// to determine which UITableViewCell to be used on a given row.
//

- (UITableViewCell *)tableView:(UITableView *)atableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = nil;
	NSUInteger row = [indexPath row];
  NSUInteger section = [indexPath section];
	if (section == 0)
	{
		static NSString *kCellTextField_ID = @"CellTextField_ID";
		cell = [atableView dequeueReusableCellWithIdentifier:kCellTextField_ID];
		if (cell == nil)
		{
			// a new cell needs to be created
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                     reuseIdentifier:kCellTextField_ID] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		else
		{
			// a cell is being recycled, remove the old edit field (if it contains one of our tagged edit fields)
			UIView *viewToCheck = nil;
			viewToCheck = [cell.contentView viewWithTag:kViewTag];
			if (viewToCheck)
				[viewToCheck removeFromSuperview];
		}
		
    NSMutableArray *keys = [[[NSMutableArray alloc] init] autorelease]; 
    [keys addObject:kUserKey];
    [keys addObject:kPassKey];
    
		UIControl *uiControl = [[self.dataSourceArray objectAtIndex: indexPath.section] valueForKey:[keys objectAtIndex:row] ];
		[cell.contentView addSubview:uiControl];
	}
	else if(section==1)
	{
		static NSString *kDisplayCell_ID = @"DisplayCellID";
		cell = [self.tableView dequeueReusableCellWithIdentifier:kDisplayCell_ID];
    if (cell == nil)
    {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kDisplayCell_ID] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		else
		{
			// the cell is being recycled, remove old embedded controls
			UIView *viewToRemove = nil;
			viewToRemove = [cell.contentView viewWithTag:kViewTag];
			if (viewToRemove)
				[viewToRemove removeFromSuperview];
		}
		
		cell.textLabel.text = [[self.dataSourceArray objectAtIndex: indexPath.section] valueForKey:kLabelKey];
		
		UIControl *control = [[self.dataSourceArray objectAtIndex: indexPath.section] valueForKey:kRemKey];
		[cell.contentView addSubview:control];
	}
	
  return cell;
}



#pragma mark -
#pragma mark Text Fields

- (UITextField *)userfield
{
	if (userfield == nil)
	{
		CGRect frame = CGRectMake(kLeftMargin, 10.0, kTextFieldWidth, kTextFieldHeight);
		userfield = [[UITextField alloc] initWithFrame:frame];
		
		userfield.borderStyle = UITextBorderStyleNone;
		userfield.textColor = [UIColor blackColor];
		userfield.font = [UIFont systemFontOfSize:20.0];
		userfield.placeholder = @"username";
		userfield.backgroundColor = [UIColor whiteColor];
		userfield.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
		userfield.keyboardType = UIKeyboardTypeDefault;	// use the default type input method (entire keyboard)
		userfield.returnKeyType = UIReturnKeyDone;
		
	//	userfield.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
		
		userfield.tag = kViewTag;		// tag this control so we can remove it later for recycled cells
		
		userfield.delegate = self;	// let us be the delegate so we know when the keyboard's "Done" button is pressed
		
    [userfield addTarget:self action:@selector(savePass:) forControlEvents:UIControlEventEditingChanged];
		// Add an accessibility label that describes what the text field is for.
		[userfield setAccessibilityLabel:NSLocalizedString(@"NormalTextField", @"")];
	}	
	return userfield;
}

- (UITextField *)pwfield
{
	if (pwfield == nil)
	{
		CGRect frame = CGRectMake(kLeftMargin, 10.0, kTextFieldWidth, kTextFieldHeight);
		pwfield = [[UITextField alloc] initWithFrame:frame];
		
		pwfield.borderStyle = UITextBorderStyleNone;
		pwfield.textColor = [UIColor blackColor];
		pwfield.font = [UIFont systemFontOfSize:20.0];
		pwfield.placeholder = @"password";
		pwfield.backgroundColor = [UIColor whiteColor];
		pwfield.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
		pwfield.secureTextEntry = true;
		pwfield.keyboardType = UIKeyboardTypeDefault;
		pwfield.returnKeyType = UIReturnKeyDone;
		    [pwfield addTarget:self action:@selector(savePass:) forControlEvents:UIControlEventEditingChanged];
		pwfield.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
		
		pwfield.tag = kViewTag;		// tag this control so we can remove it later for recycled cells
		
		pwfield.delegate = self;	// let us be the delegate so we know when the keyboard's "Done" button is pressed
		
		// Add an accessibility label that describes what the text field is for.
		[pwfield setAccessibilityLabel:NSLocalizedString(@"RoundedTextField", @"")];
	}
	return pwfield;
}

- (UISwitch *)remswitch
{
  if (remswitch == nil) 
  {
    CGRect frame = CGRectMake(198.0, 12.0, 94.0, 27.0);
    remswitch = [[UISwitch alloc] initWithFrame:frame];
    [remswitch addTarget:self action:@selector(switchSaveAction:) forControlEvents:UIControlEventValueChanged];
    
    // in case the parent view draws with a custom color or gradient, use a transparent color
    remswitch.backgroundColor = [UIColor clearColor];
		
		[remswitch setAccessibilityLabel:NSLocalizedString(@"StandardSwitch", @"")];
		
		remswitch.tag = kViewTag;	// tag this view for later so we can remove it from recycled table cells
  }
  return remswitch;
}


// login related
#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	// the user pressed the "Done" button, so dismiss the keyboard
	[textField resignFirstResponder];
	return YES;
}

- (void) dismiss {
	[[self parentViewController] dismissModalViewControllerAnimated:YES];
}

-(IBAction)cancelAction:(id)sender{
  [self dismiss];
}

- (IBAction)loginAction:(id)sender
{
  NSURL *url;
  
  url = [NSURL URLWithString:@"http://bbs.nju.edu.cn/vd15734/bbslogin?type=2"];
  NSString* uid = [userfield text];
  NSString* pass = [pwfield text];
  
  activityIndicator = 
  [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
  UIBarButtonItem * loadingButton = 
  [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
  
  // Set to Left or Right
  [self.navigationItem setRightBarButtonItem:loadingButton];
  [loadingButton release];
  [activityIndicator startAnimating];
  
  request = [ASIFormDataRequest requestWithURL:url];
  [request setPostValue:uid forKey:@"id"];
  [request setPostValue:pass forKey:@"pw"];
  [request setDidFinishSelector:@selector(loginSucceed:)];
  [request setDidFailSelector:@selector(loginFailed:)];
  [request setDelegate:self];
  [request setUseSessionPersistence:NO]; //Shouldn't be needed as this is the default
  [request setShouldRedirect:true];
  [request startAsynchronous];

}

- (void)loginSucceed:(ASIFormDataRequest *) formRequest
{ 
  
  NSString * myResponseString = [formRequest responseString];
    
  NSString *regEx = @"setCookie\\(\\'(.*)\\'\\)";
  NSString *match = [myResponseString stringByMatching:regEx capture:1L];
  
  if ([match isEqualToString:@""]==NO) {
    int i = [match intValue]+2;  
    NSInteger start = [[NSString stringWithFormat:@"%d", i] length];
    NSInteger end = [match rangeOfString:@"+"].location;
    NSString *uid = [match substringWithRange:NSMakeRange(start+1, end-start-1)];
    NSInteger key = [[match substringFromIndex:end+1] intValue] - 2;
    
    NSMutableString* cookie_value = [[NSMutableString alloc]initWithCapacity:10];
    [cookie_value appendString:@"_U_NUM="];
    [cookie_value appendString:[NSString stringWithFormat:@"%d&", i]];
    [cookie_value appendString:@"_U_UID="];
    [cookie_value appendString:[NSString stringWithFormat:@"%@&", uid]];
    [cookie_value appendString:@"_U_KEY="];
    [cookie_value appendString:[NSString stringWithFormat:@"%d", key]];
     
    LilybbsAppDelegate* lilydelegate = (LilybbsAppDelegate *)[[UIApplication sharedApplication]delegate];
    lilydelegate.cookie_value = cookie_value;
    lilydelegate.isLogin = true;
    [cookie_value release];
    
 //   [self.navigationItem setRightBarButtonItem:nil];
    [activityIndicator stopAnimating];
    activityIndicator = nil;

    [self dismiss];

  }
}

- (void)loginFailed:(ASIFormDataRequest *) formRequest
{ 
  NSLog(@"LOginfailed");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:
                          @"Hey, do you see the disclosure button?" 
                                                    message:@"fail to login"
                                                   delegate:nil 
                                          cancelButtonTitle:@"Won't happen again" 
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];  
  
  [activityIndicator stopAnimating];
  [activityIndicator release];
  
  UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]
                                 initWithTitle:@"登录" 
                                 style:UIBarButtonItemStyleDone
                                 target:self
                                 action:@selector(loginAction:)];
  self.navigationItem.rightBarButtonItem = saveButton;
  [saveButton release];
  [self.navigationBar pushNavigationItem:self.navigationItem animated:NO];
}




//保存和载入密码相关
- (NSString *)dataFilePath {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                       NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  return [documentsDirectory stringByAppendingPathComponent:kFilename];
}

- (void)savePass:(id)sender{
  if (userfield.text!=nil&&pwfield.text!=nil&&![userfield.text isEqualToString:@""]&&![pwfield.text  isEqualToString:@""]&&self.remswitch.on==true) {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObject:userfield.text];
    [array addObject:pwfield.text];
    [array writeToFile:[self dataFilePath] atomically:YES];
    [array release];
  }
  else {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObject:@""];
    [array addObject:@""];
    [array writeToFile:[self dataFilePath] atomically:YES];
    [array release];
  }
}

- (void)loadPass{
  NSString *filePath = [self dataFilePath];
  if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
    NSArray *array = [[NSArray alloc] initWithContentsOfFile:filePath];
    userfield.text = [array objectAtIndex:0];
    pwfield.text = [array objectAtIndex:1];
    if (![userfield.text isEqualToString:@""]) {
      [self.remswitch setOn:true];
    }
    [array release];}
}

- (void)switchSaveAction:(id)sender
{
  if (userfield.text!=nil&&pwfield.text!=nil&&![userfield.text isEqualToString:@""]&&![pwfield.text  isEqualToString:@""]&&self.remswitch.on==true) {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObject:userfield.text];
    [array addObject:pwfield.text];
    [array writeToFile:[self dataFilePath] atomically:YES];
    [array release];
  }
  else {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObject:@""];
    [array addObject:@""];
    [array writeToFile:[self dataFilePath] atomically:YES];
    [array release];
  }
}

@end

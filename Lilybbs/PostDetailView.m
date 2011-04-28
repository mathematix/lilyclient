//
//  POstDetailView.m
//  Lilybbs
//
//  Created by panda on 11-4-1.
//  Copyright 2011年 __badpanda__. All rights reserved.


#import "PostDetailView.h"
#import "TFHpple.h"
#import "RegexKitLite.h"
#import "PostController.h"
#import "PostDetailController.h"
#import "ASIHTTPRequest.h"

//这个类写的乱七八糟的，稍候再修改
@implementation PostDetailView
@synthesize urlString, reply_links, http_request;
@synthesize isLoadingFinished,post_index, isCheckingFinished,check_request;

-(id)initWithFrame:(CGRect)frame{
  if([super initWithFrame:frame]){
    self=[super initWithFrame:frame];
    self.delegate=self;
  }
  return self;
}

-(void)produceHTMLForPage:(NSArray*)result{
  
  NSMutableString* string =[[NSMutableString alloc]initWithCapacity:100];	//init a mutable string, initial capacity is not a problem, it is flexible
  [string appendString:
   @"<html>"
   "<head>"
   "<meta name=\"viewport\" content=\"width=320\"/>"
   "<script>"
   "function replyClicked(text){"
   "var clicked=true;"
   "window.location=\"/reply/\"+text;"
   "}"
   "</script>"
   "</head>"
   "<body style='font-size:12px;'>"
   ];
  
  reply_links = [[NSMutableArray alloc]init];
  
  for (NSInteger i = 0; i < [result count]; i++) {
    
    NSString* each_content = [[result objectAtIndex:(NSUInteger)i] objectAtIndex:0];
    NSString* reply_link = [[result objectAtIndex:(NSUInteger)i] objectAtIndex:1];
    
    NSDictionary* dic = [self extractPostContent:each_content];
    [string appendString:[NSString stringWithFormat:@"<div>%@</div>",[dic valueForKey:@"title"]]];
    [string appendString:[NSString stringWithFormat:@"<div>作者：%@</div>",[dic valueForKey:@"user"]]];
    [string appendString:[NSString stringWithFormat:@"<div>信区：%@</div>",[dic valueForKey:@"board"]]];
    [string appendString:[NSString stringWithFormat:@"<div>时间：%@</div>",[dic valueForKey:@"time"]]];
    [string appendString:[NSString stringWithFormat:@"<div>%@</div>",[dic valueForKey:@"content"]]];
    [string appendString:[NSString stringWithFormat:@"<div><a javascript:void(0)\" onMouseDown=\"replyClicked('%d')\">回复</a></div>",i]];
    [reply_links addObject:reply_link];
    [string appendString:@"<hr>"];
    
  }
  
  [string appendString:@"</body></html>"];
  //load the HTML String on UIWebView
  [self loadHTMLString:string baseURL:nil];
  [string release];
}

//linking the javascript to call the iPhone control
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)arequest navigationType:(UIWebViewNavigationType)navigationType {	  
    
  if ( [[arequest.mainDocumentURL.relativePath substringToIndex:6] isEqualToString:@"/reply"] ) 
  {
    LilybbsAppDelegate* lilydelegate = (LilybbsAppDelegate *)[[UIApplication sharedApplication]delegate];
    if(lilydelegate.isLogin == true){
      post_index = [[arequest.mainDocumentURL.relativePath substringFromIndex:7] intValue];
      [self checkLogin];
    }
    else{
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" 
                                                      message:@"匆匆过客不能发表文章！"
                                                     delegate:nil 
                                            cancelButtonTitle:@"取消" 
                                            otherButtonTitles:nil];
      [alert show];
      [alert release]; 
    }
    return false;
  }
  return true;
}

//to get the next responder controller
- (UINavigationController*)viewController {
  for (UIView* next = [self superview]; next; next = next.superview) {
    UIResponder* nextResponder = [next nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
      return (UINavigationController*)nextResponder;
    }
  }
  return nil;
}

-(NSString*)produceImage:(NSString*)image{
  NSMutableString *returnString=[[[NSMutableString alloc]initWithCapacity:100]autorelease];
  [returnString appendString:@"<center><img src=\""];
  [returnString appendString:image];
  [returnString appendString:@"\" alt=\""];
  [returnString appendString:@"\" width=\"300\"></center>"];
  return returnString;
}


-(void)drawRect:(CGRect)rect{		//method that's called to draw the view
  
  NSMutableString* waiting_string =[[NSMutableString alloc]initWithCapacity:10];	//init a mutable string, initial capacity is not a problem, it is flexible
  [waiting_string appendString:
   @"<html>"
   "<head>"
   "<meta name=\"viewport\" content=\"width=320\"/>"
   "<script>"
   "function imageClicked(){"
   "var clicked=true;"
   "window.location=\"/click/\"+clicked;"
   "}"
   "</script>"
   "</head>"
   "<body>"
   "<div>Loading...</div>"
   "</body>"
   "</html>"
   ];
  [self loadHTMLString:waiting_string baseURL:nil];		//load the HTML String on UIWebView
  
  [self grabURLInBackground];
} 

//不规范的百合让人很头疼。。。。解析的时候要注意很多问题
- (NSDictionary *)extractPostContent:(NSString*)content{
  NSMutableDictionary* list = [[[NSMutableDictionary alloc]init] autorelease];
  
  //  NSString *regEx = @"setCookie\\(\\'(.*)\\'\\)";
  NSString * regEx = @"发信人: (.*), 信区";
  NSString *match = [content stringByMatching:regEx capture:1L];
  if (match==nil) {
    match=@"";
  }
  [list setValue:match forKey:@"user"];
  
  regEx = @"信区: (.*)(\\n|\\r)";
  match = [content stringByMatching:regEx capture:1L];
  if (match==nil) {
    match=@"";
  }
  [list setValue:match forKey:@"board"];
  
  regEx = @"标  题: (.*)(\\n|\\r)";
  match = [content stringByMatching:regEx capture:1L];
  if (match==nil) {
    match=@"";
  }
  [list setValue:match forKey:@"title"];
  
  regEx = @"发信站: (.*)(\\n|\\r)";
  match = [content stringByMatching:regEx capture:1L];
  if (match==nil) {
    match=@"";
  }
  [list setValue:match forKey:@"site"];
  
  regEx = @"\\((.*)\\)";
  match = [[list valueForKey:@"site"] stringByMatching:regEx capture:1L];
  if (match==nil) {
    match=@"";
  }
  [list setValue:match forKey:@"time"];
  
  NSInteger start;
  if (match==@"") {
    start = 0;
  }else{
    start = [content rangeOfString:[list valueForKey:@"site"]].location + [content rangeOfString:[list valueForKey:@"site"]].length+1;
  }
  
  NSInteger end;
  /*Todo: need a better way to find out the end of the post*/
  if ([content rangeOfString:@"--\n"].location<2000000) {
    end = [content rangeOfString:@"--\n"].location-1;
  }else if  ([content rangeOfString:@"※ 修改"].location<2000000)
  {
    end = [content rangeOfString:@"※ 修改"].location-1;
  }else
  {
    end = [content rangeOfString:content].length;
  }
  
  NSString *post_content = [content substringWithRange:NSMakeRange(start, end-start)];
  
  NSArray  *matchArray   = NULL;
  
  //此处为对post_content的处理，因为该值为rawtext，需要将其转换成html，例如回车换成<br>，将表情换成图片，这个后续来做。此外可以设置一个选项，是否显示图片，或者根据读取图片大小来选择是否加载。
  
  /*Todo: need a better way to find out the end of the post*/
  NSString* regexString = @"(http(.*)(jpg|JPG|PNG|png|GIF|gif))";
  
  matchArray = [post_content componentsMatchedByRegex:regexString capture:1L];
  for (NSString* matchString in matchArray) {
    post_content = [post_content stringByReplacingOccurrencesOfString:matchString withString:[self produceImage:matchString]];
  }
  //转换结束
  [list setValue:post_content forKey:@"content"];
  return list;
}


-(void)dealloc{			
  [urlString release];
  [super dealloc];
}


#pragma mark - grab url
- (void)grabURLInBackground
{
  isLoadingFinished=false;
  
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://bbs.nju.edu.cn/%@",self.urlString]];
  
  http_request = [ASIHTTPRequest requestWithURL:url];
  [http_request setDelegate:self];
  [http_request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)arequest
{
  TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:[arequest responseData]];  
  
  //elements存放所有post的内容，head_elements存放所有回复链接，为什么没有放一起呢。。。因为一开始没想到。此外hpple经常解析出错，这个也没办法。。。有空了换正则表达式吧
  NSArray* elements = [xpathParser search:@"//table//textarea"];
  NSArray* head_elements = [xpathParser search:@"//table//tr/td/a[2]"];
  
  NSMutableArray *contents = [[[NSMutableArray alloc] init] autorelease]; 
  for (NSInteger i=0; i<[elements count]; i++) {
    NSMutableArray* object = [[[NSMutableArray alloc] init] autorelease]; 
    [object addObject:[[elements objectAtIndex:i] content]];
    [object addObject:[[head_elements objectAtIndex:i] objectForKey:@"href"]];
    [contents addObject:object];
  }
  [self produceHTMLForPage:contents];
  isLoadingFinished=true;
}

- (void)requestFailed:(ASIHTTPRequest *)arequest
{
  NSError *error = [arequest error];
  //如果超时了，就提示载入失败，要区别于code等于4(就是该request被cancel掉)
  if ([error code]==2) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" 
                                                    message:@"载入失败！请重试！"
                                                   delegate:nil 
                                          cancelButtonTitle:@"确定" 
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];  
  }
  isLoadingFinished=true;  
}


//check login
-(void)checkLogin{
  isCheckingFinished =false;
  LilybbsAppDelegate* lilydelegate = (LilybbsAppDelegate *)[[UIApplication sharedApplication]delegate];
  //这里用一个必须要登录才能访问的bbsinfo页面来做判断，流量很小，只返回800byte
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://bbs.nju.edu.cn/bbsinfo?%@",lilydelegate.cookie_value]];
  
  check_request = [ASIHTTPRequest requestWithURL:url];
  [check_request setDelegate:self];
  [check_request setDidFinishSelector:@selector(checkLoginSucceed:)];
  [check_request setDidFailSelector:@selector(checkLoginFailed:)];
  [check_request startAsynchronous];
}

-(void)checkLoginSucceed:(ASIHTTPRequest *) formRequest{
  //如果返回的html中包含"错误"，则说明没有登录
  if ([[formRequest responseString] rangeOfString:@"错误! 您尚未登录!"].location != NSNotFound){
    LilybbsAppDelegate* lilydelegate = (LilybbsAppDelegate *)[[UIApplication sharedApplication]delegate];
    lilydelegate.isLogin = false;
    lilydelegate.cookie_value = @"";
    lilydelegate.cookie_dic = nil;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" 
                                                    message:@"登录过期，请重新登录！"
                                                   delegate:nil 
                                          cancelButtonTitle:@"取消" 
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];  
  }else{
    PostController* postcontroller = [[PostController alloc] initWithNibName:@"PostView" bundle:nil];
    postcontroller.urlString = [reply_links objectAtIndex:post_index];
    postcontroller.title = @"发表文章";
    [[self viewController] pushViewController:postcontroller animated:YES];
  }
  isCheckingFinished =true;
}

-(void)checkLoginFailed:(ASIHTTPRequest *) formRequest{
  if ([[formRequest error]code]==2) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" 
                                                    message:@"网络暂时忙，请重试"
                                                   delegate:nil 
                                          cancelButtonTitle:@"确定" 
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
  }
  isCheckingFinished =true;
}

@end
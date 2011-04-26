//
//  mainView.m
//  Reader
//
//  Created by David Samuel on 6/4/10.
//  Copyright 2010 Institut Teknologi Bandung. All rights reserved.
//

#import "PostDetailView.h"
#import "TFHpple.h"
#import "RegexKitLite.h"
#import "PostController.h"
#import "PostDetailController.h"

@implementation PostDetailView
@synthesize urlString, reply_links;


-(id)initWithFrame:(CGRect)frame{	//initialization of this object will call this method
	if([super initWithFrame:frame]){
    self=[super initWithFrame:frame];
		//initialization for this UIWebView delegate (javascript function)
		self.delegate=self;
	}
	return self;
}


-(NSArray*)getdata:(NSString*)url_string{
  
  NSURL *url;
  NSMutableURLRequest *urlRequest;
  NSMutableData *postBody = [NSMutableData data];
  url = [NSURL URLWithString:[NSString stringWithFormat:@"http://bbs.nju.edu.cn/%@",url_string]];
  
  urlRequest = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
  
  [urlRequest setHTTPBody:postBody];
  
 // NSData *returnData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:nil];
  
  NSData* siteData = [[NSData alloc] initWithContentsOfURL:url];
  
  if(siteData)
  {
    
 //   NSString *result = [[NSString alloc] initWithData:returnData encoding:-2147483623];
    
 //   NSLog(@"result=======>%@===========>",result);
    
    
 //   NSData *data = [result dataUsingEncoding:NSUTF8StringEncoding]; 
    
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:siteData];  
    
    NSArray* elements = [xpathParser search:@"//table//textarea"];
    NSArray* head_elements = [xpathParser search:@"//table//tr/td/a[2]"];
    
    NSMutableArray *contents = [[[NSMutableArray alloc] init] autorelease]; 
    for (NSInteger i=0; i<[elements count]; i++) {
      NSMutableArray* object = [[[NSMutableArray alloc] init] autorelease]; 
      [object addObject:[[elements objectAtIndex:i] content]];
      [object addObject:[[head_elements objectAtIndex:i] objectForKey:@"href"]];
    //  NSLog([[head_elements objectAtIndex:i] objectForKey:@"href"]);
      [contents addObject:object];
   //  TFHppleElement *element = [elements objectAtIndex:i];
      
   //   NSString *h1Tag = [element];  
    //  NSLog(@"\n result = %@\n",h1Tag);
    }
    return contents;
  }
  return nil;
}

-(void) myTaskMethod
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];  
  [self produceHTMLForPage:urlString];
  [pool release];
}

-(void)produceHTMLForPage:(NSString*)url_string{
  
  NSArray* result_data = [self getdata:url_string];
  
  NSMutableString* string =[[NSMutableString alloc]initWithCapacity:10];	//init a mutable string, initial capacity is not a problem, it is flexible
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
  
  for (NSInteger i = 0; i < [result_data count]; i++) {
    
    NSString* each_content = [[result_data objectAtIndex:(NSUInteger)i] objectAtIndex:0];
    NSString* reply_link = [[result_data objectAtIndex:(NSUInteger)i] objectAtIndex:1];
    
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
//	[string appendString:[NSString stringWithFormat:@"<br><br><center>%@<center>",[[arrayPages objectAtIndex:pageNumber-1]description]]];
	[string appendString:@"</body>"
	 "</html>"
	 ];		//creating the HTMLString
	[self loadHTMLString:string baseURL:nil];		//load the HTML String on UIWebView
	[string release];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {	//linking the javascript to call the iPhone control

	if ( [[request.mainDocumentURL.relativePath substringToIndex:6] isEqualToString:@"/reply"] ) {	
    PostController* postcontroller = [[PostController alloc] initWithNibName:@"PostView" bundle:nil];
    NSInteger index = [[request.mainDocumentURL.relativePath substringFromIndex:7] intValue];
    postcontroller.urlString = [reply_links objectAtIndex:index];
    postcontroller.title = @"发表文章";
   [[self viewController] pushViewController:postcontroller animated:YES];
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
		[returnString appendString:@"<center><IMG SRC=\""];
		[returnString appendString:image];
		[returnString appendString:@"\" ALT=\""];
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

  
  [NSThread detachNewThreadSelector:@selector(myTaskMethod) toTarget:self withObject:nil];

} 


- (NSDictionary *)extractPostContent:(NSString*)content{
  NSMutableDictionary* list = [[[NSMutableDictionary alloc]init] autorelease];
  
//  NSString *regEx = @"setCookie\\(\\'(.*)\\'\\)";
  NSString * regEx = @"发信人: (.*), 信区";
  NSString *match = [content stringByMatching:regEx capture:1L];
  [list setValue:match forKey:@"user"];
  
  regEx = @"信区: (.*)(\\n|\\r)";
  match = [content stringByMatching:regEx capture:1L];
  [list setValue:match forKey:@"board"];
  
  regEx = @"标  题: (.*)(\\n|\\r)";
  match = [content stringByMatching:regEx capture:1L];
  [list setValue:match forKey:@"title"];

  regEx = @"发信站: (.*)(\\n|\\r)";
  match = [content stringByMatching:regEx capture:1L];
  [list setValue:match forKey:@"site"];
  
  regEx = @"\\((.*)\\)";
  match = [[list valueForKey:@"site"] stringByMatching:regEx capture:1L];
  [list setValue:match forKey:@"time"];
     
  NSInteger start = [content rangeOfString:[list valueForKey:@"site"]].location + [content rangeOfString:[list valueForKey:@"site"]].length+1;

  NSInteger end;
  /*Todo: need a better way to find out the end of the post*/
  if ([content rangeOfString:@"--\n"].location<2000000) {
    end = [content rangeOfString:@"--\n"].location-1;
  }else
  {
    end = [content rangeOfString:@"※ 修改"].location-1;
  }

  NSString *post_content = [content substringWithRange:NSMakeRange(start, end-start)];
  
  NSArray  *matchArray   = NULL;
  
  /*Todo: need a better way to find out the end of the post*/
  NSString* regexString = @"(http(.*))";
  
  matchArray = [post_content componentsMatchedByRegex:regexString capture:1L];
  for (NSString* matchString in matchArray) {
    post_content = [post_content stringByReplacingOccurrencesOfString:matchString withString:[self produceImage:matchString]];
  }
  [list setValue:post_content forKey:@"content"];
 // NSLog([list valueForKey:@"content"]);
  return list;
}


-(void)dealloc{			
  [urlString release];
	[super dealloc];
}





@end

//
//  CHWebBrowserViewController.m
//  Chivy
//
//  Created by Denis Zamataev on 10/31/13.
//  Copyright (c) 2013 Denis Zamataev. All rights reserved.
//

#import "CHWebBrowserViewController.h"

enum actionSheetButtonIndex {
	kSafariButtonIndex,
	kChromeButtonIndex,
    kShareButtonIndex
};

@implementation CHWebBrowserViewControllerAttributes

+ (CHWebBrowserViewControllerAttributes*)defaultAttributes {
    CHWebBrowserViewControllerAttributes *defaultAttributes = [[CHWebBrowserViewControllerAttributes alloc] init];
    defaultAttributes.titleScrollingSpeed = 20.0f;
    defaultAttributes.statusBarHeight = UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]) ? [UIApplication sharedApplication].statusBarFrame.size.height : [UIApplication sharedApplication].statusBarFrame.size.width;
    defaultAttributes.suProgressBarTag = 51381;
    defaultAttributes.animationDurationPerOnePixel = 0.0068181818f;
    defaultAttributes.titleTextAlignment = NSTextAlignmentCenter;
    defaultAttributes.isProgressBarEnabled = NO;
    defaultAttributes.isHidingBarsOnScrollingEnabled = YES;
    defaultAttributes.shouldAutorotate = YES;
    defaultAttributes.supportedInterfaceOrientations = UIInterfaceOrientationMaskAllButUpsideDown;
    defaultAttributes.preferredStatusBarStyle = UIStatusBarStyleDefault;
    return defaultAttributes;
}

@end

@interface CHWebBrowserViewController ()

@end

@implementation CHWebBrowserViewController

#pragma mark - Opening helpers

+ (void)openWebBrowserController:(CHWebBrowserViewController*)vc modallyWithUrl:(NSURL*)url animated:(BOOL)animated showDismissButton:(BOOL)showDismissButton completion:(void (^)(void))completion {
    UINavigationController *navVc = [[UINavigationController alloc] initWithRootViewController:vc];
    vc.homeUrl = url;
    vc.shouldShowDismissButton = showDismissButton;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIViewController *rootViewController = window.rootViewController;
    [rootViewController presentViewController:navVc animated:animated completion:completion];
}

+ (void)openWebBrowserController:(CHWebBrowserViewController*)vc modallyWithUrl:(NSURL*)url animated:(BOOL)animated completion:(void (^)(void))completion {
    [CHWebBrowserViewController openWebBrowserController:vc modallyWithUrl:url animated:animated showDismissButton:shadow completion:completion];
}

+ (void)openWebBrowserController:(CHWebBrowserViewController*)vc modallyWithUrl:(NSURL*)url animated:(BOOL)animated {
    [CHWebBrowserViewController openWebBrowserController:vc modallyWithUrl:url animated:animated completion:nil];
}

+ (void)openWebBrowserControllerModallyWithHomeUrl:(NSURL*)url animated:(BOOL)animated completion:(void (^)(void))completion {
    CHWebBrowserViewController *webBrowserController = [[CHWebBrowserViewController alloc] initWithNibName:[CHWebBrowserViewController defaultNibFileName]
                                                                                                    bundle:nil];
    [CHWebBrowserViewController openWebBrowserController:webBrowserController modallyWithUrl:url animated:animated completion:completion];
}

+ (void)openWebBrowserControllerModallyWithHomeUrl:(NSURL*)url animated:(BOOL)animated {
    [CHWebBrowserViewController openWebBrowserControllerModallyWithHomeUrl:url animated:animated completion:nil];
}

#pragma mark - Initialization

+ (id)webBrowserControllerWithDefaultNibAndHomeUrl:(NSURL*)url
{
    CHWebBrowserViewController *webBrowserController = [[CHWebBrowserViewController alloc] initWithNibName:[CHWebBrowserViewController defaultNibFileName]
                                                                                                    bundle:nil];
    webBrowserController.homeUrl = url;
    return webBrowserController;
}

+ (id)webBrowserControllerWithDefaultNib
{
    return [CHWebBrowserViewController webBrowserControllerWithDefaultNibAndHomeUrl:nil];
}

+ (NSString*)defaultNibFileName {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return @"CHWebBrowserViewController_iPad";
    }
    else {
        return @"CHWebBrowserViewController_iPhone";
    }
}

- (id)init {
    NSAssert(FALSE, @"Init not implemented, use initWithNibName instead");
    return nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.viewsAffectedByAlphaChanging = [NSMutableArray new];
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return self;
}

#pragma mark - Properties

- (void)setValuesInAffectedViewsSetterBlock:(ValuesInAffectedViewsSetterBlock)valuesInAffectedViewsSetterBlock
{
    _valuesInAffectedViewsSetterBlock = valuesInAffectedViewsSetterBlock;
}

- (ValuesInAffectedViewsSetterBlock)valuesInAffectedViewsSetterBlock {
    if (!_valuesInAffectedViewsSetterBlock) {
        _valuesInAffectedViewsSetterBlock = ^(UIView *topBar,
                                              float topBarYPosition,
                                              UIView *bottomBar,
                                              float bottomBarYPosition,
                                              UIScrollView *scrollView,
                                              UIEdgeInsets contentInset,
                                              UIEdgeInsets scrollingIndicatorInsets,
                                              NSArray *viewsAffectedByAlphaChanging,
                                              float alpha) {
            
            topBar.frame = CGRectMake(topBar.frame.origin.x,
                                      topBarYPosition,
                                      topBar.frame.size.width,
                                      topBar.frame.size.height);
            bottomBar.frame = CGRectMake(bottomBar.frame.origin.x,
                                         bottomBarYPosition,
                                         bottomBar.frame.size.width,
                                         bottomBar.frame.size.height);
            
            scrollView.scrollIndicatorInsets = scrollingIndicatorInsets;
            scrollView.contentInset = contentInset;
            
            for (id view in viewsAffectedByAlphaChanging) {
                [view setAlpha:alpha];
            }
        };
        
    }
    return _valuesInAffectedViewsSetterBlock;
}

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
}

- (NSString*)title {
    return self.titleLabel.text;
}

- (void)setCustomBackBarButtonItem:(DKBackBarButtonItem *)customBackBarButtonItem {
    _customBackBarButtonItem = customBackBarButtonItem;
    if (self.customBackBarButtonItemTitle && [_customBackBarButtonItem respondsToSelector:@selector(setTitle:)]) {
        [_customBackBarButtonItem setTitle:self.customBackBarButtonItemTitle];
    }
}

- (DKBackBarButtonItem*)customBackBarButtonItem {
    if (!_customBackBarButtonItem) {
        _customBackBarButtonItem = [[DKBackBarButtonItem alloc] init];
        if (self.customBackBarButtonItemTitle)
            _customBackBarButtonItem.title = self.customBackBarButtonItemTitle;
        
        _customBackBarButtonItem.action = @selector(navigationControllerPopViewControllerAnimated);
        _customBackBarButtonItem.target = self;
    }
    return _customBackBarButtonItem;
}

- (void)setCustomBackBarButtonItemTitle:(NSString *)customBackBarButtonItemTitle {
    _customBackBarButtonItemTitle = customBackBarButtonItemTitle;
    self.customBackBarButtonItem.title = _customBackBarButtonItemTitle;
    self.navigationController.navigationBar.backItem.title = _customBackBarButtonItemTitle;
    self.navigationItem.backBarButtonItem.title = _customBackBarButtonItemTitle;
}

- (NSString*)customBackBarButtonItemTitle {
    return _customBackBarButtonItemTitle;
}

- (void)setCAttributes:(CHWebBrowserViewControllerAttributes *)attributes {
    _cAttributes = attributes;
}

- (CHWebBrowserViewControllerAttributes*)cAttributes {
    if (!_cAttributes) {
        _cAttributes = [CHWebBrowserViewControllerAttributes defaultAttributes];
    }
    return _cAttributes;
}

- (void)setShouldShowDismissButton:(BOOL)shouldShowDismissButton
{
    _shouldShowDismissButton = shouldShowDismissButton;
    if (_shouldShowDismissButton && self.navigationItem.leftBarButtonItem != self.dismissBarButtonItem) {
        self.navigationItem.leftBarButtonItem = self.dismissBarButtonItem;
    }
    else if (!_shouldShowDismissButton && self.navigationItem.leftBarButtonItem == self.dismissBarButtonItem) {
        self.navigationItem.leftBarButtonItem = nil;
    }
}

- (BOOL)shouldShowDismissButton {
    return _shouldShowDismissButton;
}

- (UINavigationBar*)topBar {
    return self.navigationController.navigationBar;
}

- (UIView*)suProgressBar {
    return [self.navigationController.navigationBar viewWithTag:self.cAttributes.suProgressBarTag];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.cAttributes.preferredStatusBarStyle;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [self.localNavigationBar removeFromSuperview];
    
    self.titleLabel.scrollSpeed = self.cAttributes.titleScrollingSpeed;
    self.titleLabel.textAlignment = self.cAttributes.titleTextAlignment;
    
    [self.viewsAffectedByAlphaChanging addObjectsFromArray:CHWebBrowserViewsAffectedByAlphaChangingByDefault];
    
    self.webView.scrollView.delegate = self;
    
    self.navigationItem.titleView = self.localTitleView;
    self.navigationItem.rightBarButtonItem = self.readBarButtonItem;
    
    if (self.cAttributes.isProgressBarEnabled && !self.suProgressBar)
        [self SuProgressForWebView:self.webView];
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [_webView stopLoading];
    UIAlertView *memoryWarningAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Memory warning",
                                                                                           @"Alert view title. Memory warning alert in web browser.")
                                                                 message:NSLocalizedString(@"The page will stop loading.",
                                                                                           @"Alert view message. Memory warning alert in web browser.")
                                                                delegate:nil
                                                       cancelButtonTitle:NSLocalizedString(@"Cancel",
                                                                                           @"Alert view cancel button title. Memory warning alert in web browser.")
                                                       otherButtonTitles:nil];
    [memoryWarningAlert show];
}

-(void)viewWillAppear:(BOOL)animated {
    // we need nav bar to be shown
    self.wasNavigationBarHiddenByControllerOnEnter = self.navigationController.navigationBarHidden;
    if (self.wasNavigationBarHiddenByControllerOnEnter)
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    self.wasNavigationBarHiddenAsViewOnEnter = self.navigationController.navigationBar.hidden;
    if (self.wasNavigationBarHiddenAsViewOnEnter)
        self.navigationController.navigationBar.hidden = NO;
    
    [self resetInsets];
    
    if (self.shouldShowDismissButton) {
        // will be shown only in modal mode by default
        self.navigationItem.leftBarButtonItem = self.dismissBarButtonItem;
    }
    else if (self.cAttributes.isHidingBarsOnScrollingEnabled) {
        // nav bar back bar button should be customized if we need to hide it on scrolling
        self.navigationItem.hidesBackButton = YES;
        self.navigationItem.leftBarButtonItem = self.customBackBarButtonItem;
    }
    
    
//    if (self.customBackBarButtonItemTitle) {
//        self.navigationController.navigationBar.backItem.title = self.customBackBarButtonItemTitle;
//        self.navigationItem.backBarButtonItem.title = self.customBackBarButtonItemTitle;
//        self.customBackBarButtonItem.title = self.customBackBarButtonItemTitle;
//    }
    
    [self.suProgressBar setHidden:NO]; // cannot dismiss it, workaround
    
    [TKAURLProtocol registerProtocol];
	// Two variants for https connection
	// 1. Call setTrustSelfSignedCertificates:YES to allow access to hosts with untrusted certificates
	[TKAURLProtocol setTrustSelfSignedCertificates:YES];
	// 2. Call TKAURLProtocol addTrustedHost: with name of host to be trusted.
	//[TKAURLProtocol addTrustedHost:@"google.com"];
    
    if (self.homeUrl) {
        [self loadUrl:self.homeUrl];
    }
}

-(void) viewWillDisappear:(BOOL)animated {
    // restore nav bar visibility to entry state
    [self.navigationController setNavigationBarHidden:self.wasNavigationBarHiddenByControllerOnEnter animated:YES];
    
    self.navigationController.navigationBar.hidden = self.wasNavigationBarHiddenAsViewOnEnter;
    
    [self.webView stopLoading];
    
    if (!self.shouldShowDismissButton && self.navigationItem.leftBarButtonItem == self.dismissBarButtonItem)
        self.navigationItem.leftBarButtonItem = nil;
    
    [self.suProgressBar setHidden:YES]; // cannot dismiss it, workaround
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if (self.mainRequest)
	{
		[TKAURLProtocol removeDownloadDelegateForRequest:self.mainRequest];
		[TKAURLProtocol removeObserverDelegateForRequest:self.mainRequest];
		[TKAURLProtocol removeLoginDelegateForRequest:self.mainRequest];
		[TKAURLProtocol removeSenderObjectForRequest:self.mainRequest];
	}
	[TKAURLProtocol setTrustSelfSignedCertificates:NO];
    [TKAURLProtocol unregisterProtocol];
    
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
    }
    
    [super viewWillDisappear:animated];
}

- (void)dealloc {
    CHWebBrowserLog(@"");
}

#pragma mark - View State Interactions

- (void)toggleBackForwardButtons {
    self.navigateBackButton.enabled = self.webView.canGoBack;
    self.navigateForwardButton.enabled = self.webView.canGoForward;
}

- (void)resetInsets
{
    UINavigationBar *topBar = self.topBar;
    CHWebBrowserLog(@"TOP BAR SIZE %f ORIGIN Y %f VIEW FRAME %@", topBar.frame.size.height, topBar.frame.origin.y, NSStringFromCGRect(self.view.frame));
    self.webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, CHWebBrowserNavBarHeight, 0);
    self.webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, CHWebBrowserNavBarHeight, 0);
}

#pragma mark - Public Actions

- (void)loadUrlString:(NSString*)urlString
{
    if (urlString) {
        [self loadUrl:[NSURL URLWithString:urlString]];
    }
}

- (void)loadUrl:(NSURL*)url
{
    if (url)
	{
		NSMutableURLRequest *request = [[NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0] mutableCopy];
		[self.webView loadRequest:request];
	}
}

- (void)navigationControllerPopViewControllerAnimated
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - IBActions

- (IBAction)buttonActionTouchUp:(id)sender {
    [self showActionSheet];
}

- (IBAction)dismissModally:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)readingModeToggle:(id)sender {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"MakeReadableJS" ofType:@"txt"];
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSString *s = [self.webView stringByEvaluatingJavaScriptFromString:content];
    CHWebBrowserLog(@"readable script %@\n outputs: %@", content, s);
}

#pragma mark - Action Sheet

- (void)showActionSheet {
    NSString *urlString = @"";
    NSURL* url = [self.webView.request URL];
    urlString = [url absoluteString];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.title = urlString;
    actionSheet.delegate = self;
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Open in Safari", @"CHWebBrowserController action sheet button title which leads to opening current url in Safari web browser application")];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"googlechrome://"]]) {
        // Chrome is installed, add the option to open in chrome.
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Open in Chrome", @"CHWebBrowserController action sheet button title which leads to opening current url in google chrome web browser application")];
    }
    
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Share", @"CHWebBrowserController action sheet button title which leads to standart sharing")];
    
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    
    [actionSheet showFromToolbar:self.bottomToolbar];
    
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [actionSheet cancelButtonIndex]) return;
    
    NSURL *theURL = [self.webView.request URL];
    if (theURL == nil || [theURL isEqual:[NSURL URLWithString:@""]]) {
        theURL = self.homeUrl;
    }
    
    switch (buttonIndex) {
        case kSafariButtonIndex:
        {
            [[UIApplication sharedApplication] openURL:theURL];
        }
            break;
            
        case kChromeButtonIndex:
        {
            NSString *scheme = theURL.scheme;
            
            // Replace the URL Scheme with the Chrome equivalent.
            NSString *chromeScheme = nil;
            if ([scheme isEqualToString:@"http"]) {
                chromeScheme = @"googlechrome";
            } else if ([scheme isEqualToString:@"https"]) {
                chromeScheme = @"googlechromes";
            }
            
            // Proceed only if a valid Google Chrome URI Scheme is available.
            if (chromeScheme) {
                NSString *absoluteString = [theURL absoluteString];
                NSRange rangeForScheme = [absoluteString rangeOfString:@":"];
                NSString *urlNoScheme = [absoluteString substringFromIndex:rangeForScheme.location];
                NSString *chromeURLString = [chromeScheme stringByAppendingString:urlNoScheme];
                NSURL *chromeURL = [NSURL URLWithString:chromeURLString];
                
                // Open the URL with Chrome.
                [[UIApplication sharedApplication] openURL:chromeURL];
            }

        }
            break;
            
        case kShareButtonIndex:
        {
            UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[theURL]
                                                                                     applicationActivities:nil];
            [self presentViewController:activityVC animated:YES completion:nil];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - TKAURLProtocol
/*
 This delegate method is called when TKAURLProtocol connection
 receives didReceiveAuthenticationChallenge event
 Return Yes to popup the internal login dialog
 If returnned result is NO there are 3 possible variants:

 1. If TKAURLProtocol.Username and TKAURLProtocol.Password are not empty
       TKAURLProtocol will use them to authenticate
 2. If TKAURLProtocol.Username and TKAURLProtocol.Password are empty
       connection will try to authenticate using default credentials
 3. If cancel is set to YES the authentication will be cancelled
    and calling application will receive an error
 */
- (BOOL) ShouldPresentLoginDialog: (TKAURLProtocol*) urlProtocol CancelAuthentication: (BOOL*) cancel{
    CHWebBrowserLog();
	//*************************************** Present LoginDialog example
	*cancel = NO;
	return YES;
	//*************************************** Login without showing LoginDialog example
	//*cancel = NO;
	//urlProtocol.Username = @"username";
	//urlProtocol.Password = @"password";
	//return NO;
	//*************************************** Continue without authentication example
	//*cancel = NO;
	//urlProtocol.Username = @"";
	//urlProtocol.Password = @"";
	//return NO;
	//*************************************** Cancel Authentication example
	// *cancel = YES;
	// return NO;
	
}
/*
 This delegate method is called when TKAURLProtocol connection
 receives didReceiveAuthenticationChallenge event
 and a client certificate is required to access the protected space.
 Delegate shound return nil if there is no available certificate
 or NSURLCredential created from the available certificate
 */
- (NSURLCredential*) getCertificateCredential: (TKAURLProtocol*) urlProtocol ForChallenge: (NSURLAuthenticationChallenge *)challenge {
    CHWebBrowserLog();
	return nil;
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([[request.URL absoluteString] hasPrefix:@"sms:"]) {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
	
	else
	{
		if ([[request.URL absoluteString] hasPrefix:@"http://www.youtube.com/v/"] ||
			[[request.URL absoluteString] hasPrefix:@"http://itunes.apple.com/"] ||
			[[request.URL absoluteString] hasPrefix:@"http://phobos.apple.com/"]) {
			[[UIApplication sharedApplication] openURL:request.URL];
			return NO;
		}
    }
    
	// Configure TKAURLProtocol - authentication engine for UIWebView
	if ([request.mainDocumentURL isEqual:request.URL])
	{
        if (self.mainRequest)
        {
            [TKAURLProtocol removeDownloadDelegateForRequest:self.mainRequest];
            [TKAURLProtocol removeObserverDelegateForRequest:self.mainRequest];
            [TKAURLProtocol removeLoginDelegateForRequest:self.mainRequest];
            [TKAURLProtocol removeSenderObjectForRequest:self.mainRequest];
            self.mainRequest = nil;
        }
        self.mainRequest = request;
        [TKAURLProtocol addDownloadDelegate:self ForRequest:request];
        [TKAURLProtocol addObserverDelegate:self ForRequest:request];
        [TKAURLProtocol addLoginDelegate:self ForRequest:request];
        [TKAURLProtocol addSenderObject:webView ForRequest:request];
	}
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self resetAffectedViewsAnimated:YES];
    [self toggleBackForwardButtons];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *pageTitle = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.titleLabel.text = pageTitle;
    [self toggleBackForwardButtons];
    self.webView.hidden = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    // To avoid getting an error alert when you click on a link
    // before a request has finished loading.
    if ([error code] == NSURLErrorCancelled) {
        CHWebBrowserLog(@"cancelled loading");
        return;
    }
    
    [self resetAffectedViewsAnimated:YES];
	
    // Show error alert
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Could not load page", nil)
                                                    message:error.localizedDescription
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
	[alert show];
}


#pragma mark - ScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _isScrollViewScrolling = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(!decelerate) {
        _isScrollViewScrolling = NO;
        if (self.cAttributes.isHidingBarsOnScrollingEnabled && !_isMovingViews && !_isAnimatingViews && !_isAnimatingResettingViews)
            [self animateAffectedViewsAccordingToScrollingEndedInScrollView:scrollView];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _isScrollViewScrolling = NO;
    if (self.cAttributes.isHidingBarsOnScrollingEnabled && !_isMovingViews && !_isAnimatingViews && !_isAnimatingResettingViews)
        [self animateAffectedViewsAccordingToScrollingEndedInScrollView:scrollView];
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    _isScrollViewScrolling = NO;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    _isScrollViewScrolling = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CHWebBrowserLog(@"\n contentOffset.y %f \n delta %f \n contentInset %@ \n scrollIndicatorsInset %@ \n topBarPositionY %f",scrollView.contentOffset.y, _lastContentOffset.y - scrollView.contentOffset.y, NSStringFromUIEdgeInsets(scrollView.contentInset), NSStringFromUIEdgeInsets(scrollView.scrollIndicatorInsets), self.topBar.frame.origin.y);
    
    if (self.cAttributes.isHidingBarsOnScrollingEnabled && !_isMovingViews && !_isAnimatingViews && !_isAnimatingResettingViews && scrollView.isDragging) {
        CGFloat delta =  scrollView.contentOffset.y - _lastContentOffset.y;
        BOOL scrollingDown = delta > 0;
        BOOL scrollingBeyondTopBound = (scrollView.contentOffset.y < - scrollView.contentInset.top);
        BOOL scrollingBeyondBottomBound = (scrollView.contentOffset.y + scrollView.frame.size.height - scrollView.contentInset.bottom) > scrollView.contentSize.height;
        BOOL shouldNotMoveViews = (scrollingBeyondTopBound && scrollingDown) || scrollingBeyondBottomBound;
        if (!shouldNotMoveViews) {
            [self moveAffectedViewsAccordingToDraggingInScrollView:scrollView];
        }
    }
    _lastContentOffset = scrollView.contentOffset;
}

#pragma mark - Scrolling reaction of the affected views

- (void)moveAffectedViewsAccordingToDraggingInScrollView:(UIScrollView*)scrollView
{
    _isMovingViews = YES;
    
    CGFloat delta =  scrollView.contentOffset.y - _lastContentOffset.y;
    
    UINavigationBar *topBar = self.topBar;
    
    float topBarYPosition = [CHWebBrowserViewController clampFloat:topBar.frame.origin.y - delta
                                                       withMinimum:-CHWebBrowserNavBarHeight + CHWebBrowserStatusBarHeight
                                                        andMaximum:CHWebBrowserStatusBarHeight];
    float bottomBarYPosition = [CHWebBrowserViewController clampFloat:_bottomToolbar.frame.origin.y + delta
                                                         withMinimum:_webView.frame.size.height - CHWebBrowserNavBarHeight
                                                           andMaximum:_webView.frame.size.height];
    
    float topInset = [CHWebBrowserViewController clampFloat:scrollView.contentInset.top - delta
                                                withMinimum:CHWebBrowserStatusBarHeight
                                                 andMaximum:CHWebBrowserNavBarHeight + CHWebBrowserStatusBarHeight];
    float bottomInset = [CHWebBrowserViewController clampFloat:scrollView.contentInset.bottom - delta
                                                   withMinimum:0
                                                    andMaximum:CHWebBrowserNavBarHeight];
    UIEdgeInsets contentInset = UIEdgeInsetsMake(topInset, 0, bottomInset, 0);
    UIEdgeInsets scrollingIndicatorInsets = UIEdgeInsetsMake(topInset, 0, bottomInset, 0);
    
    float alpha = [CHWebBrowserViewController clampFloat:CHWebBrowserNavBarHeight * _titleLabel.alpha - delta
                                             withMinimum:0
                                              andMaximum:CHWebBrowserNavBarHeight] / CHWebBrowserNavBarHeight;
    
    self.valuesInAffectedViewsSetterBlock(topBar,
                                          topBarYPosition,
                                          _bottomToolbar,
                                          bottomBarYPosition,
                                          scrollView,
                                          contentInset,
                                          scrollingIndicatorInsets,
                                          _viewsAffectedByAlphaChanging,
                                          alpha);
    _isMovingViews = NO;
}

- (void)animateAffectedViewsAccordingToScrollingEndedInScrollView:(UIScrollView*)scrollView
{
    _isAnimatingViews = YES;
    
    UINavigationBar *topBar = self.topBar;
    
    float topBarYPosition, topBarDistanceLeft;
    [CHWebBrowserViewController maximizeValue:topBar.frame.origin.y
                                 betweenValue:-CHWebBrowserNavBarHeight + CHWebBrowserStatusBarHeight
                                     andValue:CHWebBrowserStatusBarHeight
                             traveledDistance:&topBarDistanceLeft
                              andIsHalfPassed:nil
                               andTargetLimit:&topBarYPosition];
    
    float bottomBarYPosition = [CHWebBrowserViewController maximizeValue:self.bottomToolbar.frame.origin.y
                                                            betweenValue:self.webView.frame.size.height - CHWebBrowserNavBarHeight
                                                                andValue:self.webView.frame.size.height];
    
    float topInsetTargetValue = [CHWebBrowserViewController maximizeValue:scrollView.contentInset.top
                                                             betweenValue:CHWebBrowserStatusBarHeight
                                                                 andValue:CHWebBrowserNavBarHeight + CHWebBrowserStatusBarHeight];
    
    float bottomInsetTargetValue = [CHWebBrowserViewController maximizeValue:scrollView.contentInset.bottom
                                                                betweenValue:0
                                                                    andValue:CHWebBrowserNavBarHeight];
    
    UIEdgeInsets contentInset = UIEdgeInsetsMake(topInsetTargetValue,0,bottomInsetTargetValue,0);
    UIEdgeInsets scrollingIndicatorInsets = contentInset;
    
    float alpha = [CHWebBrowserViewController maximizeValue:self.titleLabel.alpha
                                               betweenValue:0
                                                   andValue:1.0f];
    
    [UIView animateWithDuration:topBarDistanceLeft * self.cAttributes.animationDurationPerOnePixel
                          delay:0.0f
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.valuesInAffectedViewsSetterBlock(topBar,
                                                               topBarYPosition,
                                                               self.bottomToolbar,
                                                               bottomBarYPosition,
                                                               scrollView,
                                                               contentInset,
                                                               scrollingIndicatorInsets,
                                                               self.viewsAffectedByAlphaChanging,
                                                               alpha);
                         
                     }
                     completion:^(BOOL finished) {
                         _isAnimatingViews = NO;
                     }];
}


- (void)resetAffectedViewsAnimated:(BOOL)animated
{
    UINavigationBar *topBar = self.topBar;
    
    CGFloat topBarLowerLimit = -CHWebBrowserNavBarHeight + CHWebBrowserStatusBarHeight;
    CGFloat topBarHigherLimit = CHWebBrowserStatusBarHeight;
    float topBarDistanceLeft = fabsf(topBarHigherLimit - topBarLowerLimit);
    float topBarYPosition = topBarHigherLimit;
    float bottomBarYPosition = self.webView.frame.size.height - CHWebBrowserNavBarHeight;
    float topInsetTargetValue = CHWebBrowserNavBarHeight + CHWebBrowserStatusBarHeight;
    float bottomInsetTargetValue = CHWebBrowserNavBarHeight;
    UIEdgeInsets contentInset = UIEdgeInsetsMake(topInsetTargetValue,0,bottomInsetTargetValue,0);
    UIEdgeInsets scrollingIndicatorInsets = contentInset;
    float alpha = 1.0f;
    
    void (^setValuesInViews)() = ^void() {
        self.valuesInAffectedViewsSetterBlock(topBar,
                                              topBarYPosition,
                                              self.bottomToolbar,
                                              bottomBarYPosition,
                                              self.webView.scrollView,
                                              contentInset,
                                              scrollingIndicatorInsets,
                                              self.viewsAffectedByAlphaChanging,
                                              alpha);
    };
    
    if (animated) {
        _isAnimatingResettingViews = YES;
        [UIView animateWithDuration:topBarDistanceLeft * self.cAttributes.animationDurationPerOnePixel
                              delay:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             setValuesInViews();
                         }
                         completion:^(BOOL finished) {
                             _isAnimatingResettingViews = NO;
                         }];
    }
    else {
        _isMovingViews = YES;
        setValuesInViews();
        _isMovingViews = NO;
    }
}

#pragma mark - Dealing with Interface Orientation Rotation

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.topBar sizeToFit];
    [self.bottomToolbar sizeToFit];
    [self resetAffectedViewsAnimated:NO];

    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (BOOL)shouldAutorotate {
    return self.cAttributes.shouldAutorotate;
}

- (NSUInteger)supportedInterfaceOrientations {
    return self.cAttributes.supportedInterfaceOrientations;
}

#pragma mark - UIBarPositioningDelegate

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

#pragma mark - Static Helpers
/*
clamps the value to lie betweem minimum and maximum;
if minimum is smaller than maximum - they will be swapped;
*/
+ (float)clampFloat:(float)value withMinimum:(float)min andMaximum:(float)max {
    CGFloat realMin = min < max ? min : max;
    CGFloat realMax = max >= min ? max : min;
    return MAX(realMin, MIN(realMax, value));
}

/*
 Helps assuming the value between it's minimum and maximum, the direction the value is near to, if it passed the half and distance passed. Sets value by reference if it was given.
 */
+ (void)maximizeValue:(float)value betweenValue:(float)f1 andValue:(float)f2 traveledDistance:(float *)distance andIsHalfPassed:(BOOL *)halfPassed andTargetLimit:(float *)targetLimit
{
    CGFloat lowerLimit = MIN(f1, f2);
    CGFloat higherLimit = MAX(f1, f2);
    float distance_ = fabsf(higherLimit - lowerLimit);
    BOOL halfPassed_ = value > (lowerLimit + distance_/2);
    float targetLimit_ = halfPassed_ ? higherLimit : lowerLimit;
    if (distance != nil) *distance = distance_;
    if (halfPassed != nil) *halfPassed = halfPassed_;
    if (targetLimit != nil) *targetLimit = targetLimit_;
}

+ (float)maximizeValue:(float)value betweenValue:(float)f1 andValue:(float)f2
{
    float targetValue;
    [CHWebBrowserViewController maximizeValue:value betweenValue:f1 andValue:f2 traveledDistance:nil andIsHalfPassed:nil andTargetLimit:&targetValue];
    return targetValue;
}

+ (NSString *) getDocumentsDirectoryPath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [paths objectAtIndex:0];
	return documentsDir;
}

+ (NSString *) getLibraryDirectoryPath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [paths objectAtIndex:0];
	return documentsDir;
}

+ (void)clearCredentialsAndCookiesAndCache
{
    [CHWebBrowserViewController clearCredentials];
    [CHWebBrowserViewController clearCookies];
    [CHWebBrowserViewController clearCache];
}

+ (void)clearCredentials
{
    NSDictionary *credentialsDict = [[NSURLCredentialStorage sharedCredentialStorage] allCredentials];
    
    if ([credentialsDict count] > 0) {
        // the credentialsDict has NSURLProtectionSpace objs as keys and dicts of userName => NSURLCredential
        NSEnumerator *protectionSpaceEnumerator = [credentialsDict keyEnumerator];
        id urlProtectionSpace;
        
        // iterate over all NSURLProtectionSpaces
        while (urlProtectionSpace = [protectionSpaceEnumerator nextObject]) {
            NSEnumerator *userNameEnumerator = [[credentialsDict objectForKey:urlProtectionSpace] keyEnumerator];
            id userName;
            
            // iterate over all usernames for this protectionspace, which are the keys for the actual NSURLCredentials
            while (userName = [userNameEnumerator nextObject]) {
                NSURLCredential *cred = [[credentialsDict objectForKey:urlProtectionSpace] objectForKey:userName];
                CHWebBrowserLog(@"removing credential for user %@",[cred user]);
                [[NSURLCredentialStorage sharedCredentialStorage] removeCredential:cred forProtectionSpace:urlProtectionSpace];
            }
        }
    }
}

+ (void)clearCache
{
    NSURLCache *sharedCache = [NSURLCache sharedURLCache];
    [sharedCache removeAllCachedResponses];
}

+ (void)clearCookies
{
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [cookieStorage cookies];
    for (NSHTTPCookie *cookie in cookies) {
        CHWebBrowserLog(@"deleting cookie %@", cookie);
        [cookieStorage deleteCookie:cookie];
    }
}

@end

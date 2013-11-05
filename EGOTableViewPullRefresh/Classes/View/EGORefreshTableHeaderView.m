//
//  EGORefreshTableHeaderView.m
//  Demo
//
//  Created by Devin Doty on 10/14/09October14.
//  Copyright 2009 enormego. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "EGORefreshTableHeaderView.h"
#import "UIColor+Benihime.h"

#define TEXT_COLOR kViewBgColor
//#define TEXT_COLOR	 [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define FLIP_ANIMATION_DURATION 0.18f


@interface EGORefreshTableHeaderView (Private)
- (void)setState:(EGOPullRefreshState)aState;
@end

@implementation EGORefreshTableHeaderView

@synthesize delegate=_delegate;

@synthesize pullString =    _pullString;
@synthesize releaseString = _releaseString;
@synthesize loadingString = _loadingString;
@synthesize loadImageView = _loadImageView;

- (id)initWithFrame:(CGRect)frame
{
    if((self = [super initWithFrame:frame])) {
		
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pull-to-refresh-bg-v2"]];

		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 30.0f, self.frame.size.width, 20.0f)];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = [UIFont systemFontOfSize:12.0f];
		label.textColor = kViewBgColor;
		//label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
		//label.shadowOffset = CGSizeMake(0.0f, 1.0f);
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = UITextAlignmentCenter;
		[self addSubview:label];
		_lastUpdatedLabel=label;
		[label release];
		
		label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 40.0f, self.frame.size.width, 20.0f)];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = FONT_HELVETICA_NEUE_BOLD(@"14.0f");
		label.textColor = kViewBgColor;
		//label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
		//label.shadowOffset = CGSizeMake(0.0f, 1.0f);
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = UITextAlignmentCenter;
		[self addSubview:label];
		_statusLabel=label;
		[label release];
		
		CALayer *layer = [CALayer layer];
		layer.frame = CGRectMake(25.0f, frame.size.height - 45.0f, 30.0f, 35.0f);
		layer.contentsGravity = kCAGravityResizeAspect;
		layer.contents = (id)[UIImage imageNamed:@"pull-to-refresh-down-arrow.png"].CGImage;
		
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
			layer.contentsScale = [[UIScreen mainScreen] scale];
		}
#endif
		
		[[self layer] addSublayer:layer];
		_arrowImage=layer;
		
		UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		view.frame = CGRectMake(25.0f, frame.size.height - 38.0f, 20.0f, 20.0f);
        view.hidden = YES;
		[self addSubview:view];
		_activityView = view;
		[view release];
        
        _pullString = @"Pull down to refresh";
        _releaseString = @"Release to refresh";
        _loadingString = STR_LOADING;
        
        _loadImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, frame.size.height - 50.0f, 30, 37)];
        _loadImageView.image = [UIImage imageNamed:@"loader-sprite.png"];
        [self addSubview:_loadImageView];
		
		[self setState:EGOOPullRefreshNormal];
		
    }
	
    return self;
	
}

#pragma mark -
#pragma mark Setters

- (void)refreshLastUpdatedDate {
	
	if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceLastUpdated:)]) {
		
		NSDate *date = [_delegate egoRefreshTableHeaderDataSourceLastUpdated:self];
		
		[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehaviorDefault];
		NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
		[dateFormatter setDateStyle:NSDateFormatterShortStyle];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];

		_lastUpdatedLabel.text = [NSString stringWithFormat:@"Last Updated: %@", [dateFormatter stringFromDate:date]];
		[[NSUserDefaults standardUserDefaults] setObject:_lastUpdatedLabel.text forKey:@"EGORefreshTableView_LastRefresh"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
	} else {
		
		_lastUpdatedLabel.text = nil;
		
	}

}

- (void)setState:(EGOPullRefreshState)aState{
	
    CGSize size;
    CGFloat subViewsWidth;
    CGRect newFrame;
    
	switch (aState) {
		case EGOOPullRefreshPulling:
			
			_statusLabel.text = NSLocalizedString(_releaseString, @"Release to refresh status");
            
            //reposition
            size = [_statusLabel.text sizeWithFont:_statusLabel.font forWidth:(self.bounds.size.width-50) lineBreakMode:NSLineBreakByTruncatingTail];
            subViewsWidth = size.width+_arrowImage.bounds.size.width+10;
            
            newFrame = _statusLabel.frame;
            newFrame.size = size;
            newFrame.origin.x = self.bounds.size.width/2 - subViewsWidth/2 + _arrowImage.bounds.size.width+10 - 15;
            _statusLabel.frame = newFrame;
            
            newFrame = _arrowImage.frame;
            newFrame.origin.x = self.bounds.size.width/2 - subViewsWidth/2 - 15;
            _arrowImage.frame = newFrame;
            
            //animation
			[CATransaction begin];
			[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
            _loadImageView.hidden = YES;
            _arrowImage.hidden = NO;
			_arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
			[CATransaction commit];
			
			break;
		case EGOOPullRefreshNormal:
			
			if (_state == EGOOPullRefreshPulling) {
				[CATransaction begin];
				[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
				_arrowImage.transform = CATransform3DIdentity;
				[CATransaction commit];
			}
            
            [_loadImageView.layer removeAllAnimations];
			
			_statusLabel.text = NSLocalizedString(_pullString, @"Pull down to refresh status");
            
            //reposition
            size = [_statusLabel.text sizeWithFont:_statusLabel.font forWidth:(self.bounds.size.width-50) lineBreakMode:NSLineBreakByTruncatingTail];
            subViewsWidth = size.width+_arrowImage.bounds.size.width+10;
            
            newFrame = _statusLabel.frame;
            newFrame.size = size;
            newFrame.origin.x = self.bounds.size.width/2 - subViewsWidth/2 + _arrowImage.bounds.size.width+10 - 15;
            _statusLabel.frame = newFrame;
            
            newFrame = _arrowImage.frame;
            newFrame.origin.x = self.bounds.size.width/2 - subViewsWidth/2 - 15;
            _arrowImage.frame = newFrame;
            
            //animation
			//[_activityView stopAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            _loadImageView.hidden = YES;
			_arrowImage.hidden = NO;
			_arrowImage.transform = CATransform3DIdentity;
			[CATransaction commit];
			
			[self refreshLastUpdatedDate];
			
			break;
		case EGOOPullRefreshLoading:
			
			_statusLabel.text = NSLocalizedString(_loadingString, @"Loading Status");
            
            // reposition
            size = [_statusLabel.text sizeWithFont:_statusLabel.font forWidth:(self.bounds.size.width-50) lineBreakMode:NSLineBreakByTruncatingTail];
            subViewsWidth = size.width+_loadImageView.bounds.size.width+10;
            
            newFrame = _statusLabel.frame;
            newFrame.size = size;
            newFrame.origin.x = self.bounds.size.width/2 - subViewsWidth/2 + _arrowImage.bounds.size.width+10 - 15;
            _statusLabel.frame = newFrame;
            
            newFrame = _loadImageView.frame;
            newFrame.origin.x = self.bounds.size.width/2 - subViewsWidth/2 - 15;
            _loadImageView.frame = newFrame;
            
            //animation
			//[_activityView startAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanFalse forKey:kCATransactionDisableActions];
            _arrowImage.hidden = YES;
            _loadImageView.hidden = NO;
            
            CABasicAnimation *fullRotation;
            fullRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
            fullRotation.fromValue = [NSNumber numberWithFloat:0];
            fullRotation.toValue = [NSNumber numberWithFloat:((360*M_PI)/180)];
            fullRotation.duration = 0.4;
            fullRotation.repeatCount = INTMAX_MAX;
            [_loadImageView.layer addAnimation:fullRotation forKey:@"360"];
            
			[CATransaction commit];
			
			break;
		default:
			break;
	}
	
	_state = aState;
}

#pragma mark -
#pragma mark - Rotation methods

- (void)resumeRotation
{
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanFalse forKey:kCATransactionDisableActions];

    CABasicAnimation *fullRotation;
    fullRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    fullRotation.fromValue = [NSNumber numberWithFloat:0];
    fullRotation.toValue = [NSNumber numberWithFloat:((360*M_PI)/180)];
    fullRotation.duration = 0.4;
    fullRotation.repeatCount = INTMAX_MAX;
    [_loadImageView.layer addAnimation:fullRotation forKey:@"360"];
    
    [CATransaction commit];
}

#pragma mark -
#pragma mark ScrollView Methods

- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView {
	
	if (_state == EGOOPullRefreshLoading) {
		
		CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
		offset = MIN(offset, 60);
		scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
		
	} else if (scrollView.isDragging) {
		
		BOOL _loading = NO;
		if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
			_loading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
		}
		
		if (_state == EGOOPullRefreshPulling && scrollView.contentOffset.y > -65.0f && scrollView.contentOffset.y < 0.0f && !_loading) {
			[self setState:EGOOPullRefreshNormal];
		} else if (_state == EGOOPullRefreshNormal && scrollView.contentOffset.y < -65.0f && !_loading) {
			[self setState:EGOOPullRefreshPulling];
		}
		
		if (scrollView.contentInset.top != 0) {
			scrollView.contentInset = UIEdgeInsetsZero;
		}
		
	}
	
}

- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView {
	
	BOOL _loading = NO;
	if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
		_loading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
	}
	
	if (scrollView.contentOffset.y <= - 65.0f && !_loading) {
		
		[self setState:EGOOPullRefreshLoading];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		scrollView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
		[UIView commitAnimations];
        
        [PHUtilities appDelegate].shouldRefreshScreen = YES;
		
        if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDidTriggerRefresh:)]) {
			[_delegate egoRefreshTableHeaderDidTriggerRefresh:self];
		}
	}
}

- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView
{    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.3];
    [scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
//    [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, 0) animated:YES];
    [UIView commitAnimations];
    
    [PHUtilities appDelegate].shouldRefreshScreen = NO;
    [self setState:EGOOPullRefreshNormal];
}

- (void)forceLoadScrollView:(UIScrollView *)scrollView
{
    scrollView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
    [scrollView setContentOffset:CGPointMake(0, -65.0f) animated:NO];
    [scrollView scrollRectToVisible:CGRectMake(0, -65, 2, 2) animated:YES];
    
    [PHUtilities appDelegate].shouldRefreshScreen = YES;
    
    [self egoRefreshScrollViewDidEndDragging:scrollView];
    if ([scrollView.delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [scrollView.delegate scrollViewDidEndDecelerating:scrollView];
    }
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	
	_delegate=nil;
	_activityView = nil;
	_statusLabel = nil;
	_arrowImage = nil;
	_lastUpdatedLabel = nil;
    [super dealloc];
}


@end

//
//  ScrollViewContainer.m
//  i90X 2
//
//  Created by Jared Grant on 6/19/12.
//  Copyright (c) 2012 Canyons School District. All rights reserved.
//

#import "ScrollViewContainer.h"

@implementation ScrollViewContainer
@synthesize scrollView = _scrollView;

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent*)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == self) {
        return _scrollView;
    }
    return view;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

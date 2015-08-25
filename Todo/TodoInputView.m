//
//  TodoInputView.m
//  Todo
//
//  Created by Yu Cong on 14-11-7.
//  Copyright (c) 2014年 ltebean. All rights reserved.
//

#define duration 0.5

#define sideViewDamping 0.75
#define sideViewVelocity 0

#define centerViewDamping 0.75
#define centerViewVelocity 0

#import "TodoInputView.h"
#import "Settings.h"
#import "TodoService.h"
#import "CommonUtils.h"

@interface TodoInputView()<UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UIView *containerView;

@property(nonatomic,strong) UIView* sideHelperView;
@property(nonatomic,strong) UIView* centerHelperView;
@property(nonatomic,strong) CADisplayLink *displayLink;
@property (weak, nonatomic) IBOutlet UILabel *importantLabel;
@property (weak, nonatomic) IBOutlet UILabel *urgentLabel;
@property BOOL important;
@property BOOL urgent;

@property int counter;
@property CGFloat height;
@end

@implementation TodoInputView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [[NSBundle mainBundle] loadNibNamed:@"TodoInputView" owner:self options:nil];
        self.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.containerView.frame = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
        [self addSubview: self.containerView];
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.containerView.layer.borderWidth=1;
    self.containerView.layer.borderColor=[[UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1] CGColor];

    self.counter = 0;
    self.height = CGRectGetHeight(self.bounds);

    self.containerView.transform = CGAffineTransformMakeTranslation(0, -self.height);
    
    self.sideHelperView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.sideHelperView.backgroundColor=[UIColor blackColor];
    [self addSubview:self.sideHelperView];
    
    
    self.centerHelperView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bounds)/2, 0, 0, 0)];
    self.centerHelperView.backgroundColor=[UIColor blackColor];
    [self addSubview:self.centerHelperView];
    
    self.backgroundColor=[UIColor clearColor];
    
    self.importantLabel.layer.borderWidth=1;
    self.importantLabel.layer.borderColor=[[Settings themeColor]CGColor];


    UITapGestureRecognizer* gesture1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(importantLabelTapped:)];
    [self.importantLabel addGestureRecognizer:gesture1];

    
    self.urgentLabel.layer.borderWidth=1;
    self.urgentLabel.layer.borderColor=[[Settings themeColor]CGColor];
    self.urgentLabel.textColor=[Settings themeColor];

    UITapGestureRecognizer* gesture2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(urgentLabelTapped:)];
    [self.urgentLabel addGestureRecognizer:gesture2];
    
    self.inputField.delegate = self;
    
    self.important=NO;
    self.urgent=NO;
    
    self.backgroundColor = [UIColor clearColor];
    
    [self hideOptions];
    [self setLabelUnSeleted:self.urgentLabel];
    [self setLabelUnSeleted:self.importantLabel];

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString* content = textField.text;
    if (content && ![content isEqualToString:@""]) {
        [self addTodo:content];
    }
    [self hide];
    return YES;
}

- (void)addTodo:(NSString *)content
{
    NSString* type;
    if (self.important && self.urgent) {
        type=@"a";
    } else if (self.important && !self.urgent) {
        type=@"b";
    } else if (!self.important && self.urgent) {
        type=@"c";
    } else {
        type=@"d";
    }
    TodoService* todoService= [TodoService serviceWithType:type];
    NSDictionary* todo =@{@"id":[CommonUtils uuid],@"content":content};
    [todoService add:todo];
    [self.delegate todoInputView:self didAddTodo:todo withType:type];

}

- (void)importantLabelTapped:(UITapGestureRecognizer *) gesture
{
    if (self.important) {
        self.important=NO;
        [self setLabelUnSeleted:self.importantLabel];
    } else {
        self.important=YES;
        [self setLabelSeleted:self.importantLabel];
    }
}

- (void)setLabelSeleted:(UILabel *)label
{
    label.textColor=[UIColor whiteColor];
    label.backgroundColor=[Settings themeColor];
}

- (void)setLabelUnSeleted:(UILabel *)label
{
    label.textColor= [Settings themeColor];
    label.backgroundColor=[UIColor whiteColor];
}

- (void)urgentLabelTapped:(UITapGestureRecognizer *)gesture
{
    if (self.urgent) {
        self.urgent = NO;
        [self setLabelUnSeleted:self.urgentLabel];
    } else {
        self.urgent = YES;
        [self setLabelSeleted:self.urgentLabel];
    }
}


- (void)clearInput
{
    self.inputField.text=nil;
    
    self.important = NO;
    [self setLabelUnSeleted:self.importantLabel];

    self.urgent = NO;
    [self setLabelUnSeleted:self.urgentLabel];

}

- (void)animateOptionsIn
{
    [UIView animateWithDuration:duration delay:0.1 usingSpringWithDamping:0.75 initialSpringVelocity:0 options:0 animations:^{
        self.importantLabel.transform = CGAffineTransformIdentity;
        self.urgentLabel.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)animateOptionsOut
{
    [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:0 options:0 animations:^{
        self.importantLabel.transform = CGAffineTransformMakeScale(0, 0);
        self.urgentLabel.transform = CGAffineTransformMakeScale(0, 0);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hideOptions
{
    self.importantLabel.transform = CGAffineTransformMakeScale(0, 0);
    self.urgentLabel.transform = CGAffineTransformMakeScale(0, 0);
}

- (void)hide
{
    if (self.counter != 0) {
        return;
    }
    [self.inputField resignFirstResponder];
    [self animateOptionsOut];
    self.shown=NO;
    [self start];
    [self animateSideHelperViewToPoint:CGPointMake(self.sideHelperView.center.x, 0)];
    [self animateCenterHelperViewToPoint: CGPointMake(self.centerHelperView.center.x, 0)];
    [self animateContentViewToHeight:-self.height];
    
}

- (void)showInView:(UIView *)view
{
    if (self.counter!=0) {
        return;
    }
    self.shown=YES;
    [view addSubview:self];
    [self start];
    [self animateOptionsIn];

    CGFloat height = CGRectGetHeight(self.bounds);
    
    [self animateSideHelperViewToPoint:CGPointMake(self.sideHelperView.center.x, height)];
    [self animateCenterHelperViewToPoint: CGPointMake(self.centerHelperView.center.x, height)];
    [self animateContentViewToHeight:0];
    [self.inputField becomeFirstResponder];
}

- (void)showInView:(UIView *)view withType:(NSString *)type;
{
    if ([type isEqualToString:@"a"]) {
        self.important = YES;
        self.urgent = YES;
        [self setLabelSeleted:self.importantLabel];
        [self setLabelSeleted:self.urgentLabel];
    } else if ([type isEqualToString:@"b"]) {
        self.important = YES;
        [self setLabelSeleted:self.importantLabel];
    } else if ([type isEqualToString:@"c"]) {
        self.urgent = YES;
        [self setLabelSeleted:self.urgentLabel];
    } else if ([type isEqualToString:@"d"]) {
        
    }
    [self showInView:view];
}

- (void)animateSideHelperViewToPoint:(CGPoint)point
{
    [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:sideViewDamping initialSpringVelocity:sideViewVelocity options:0 animations:^{
        self.sideHelperView.center = point;
    } completion:^(BOOL finished) {
        [self complete];
    }];
}


- (void)animateCenterHelperViewToPoint:(CGPoint)point
{
    [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:centerViewDamping initialSpringVelocity:centerViewVelocity options:0 animations:^{
        self.centerHelperView.center = point;
        
    } completion:^(BOOL finished) {
        [self complete];
    }];
}

- (void)animateContentViewToHeight:(CGFloat)height
{
    [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:centerViewDamping initialSpringVelocity:centerViewVelocity options:0 animations:^{
        self.containerView.transform = CGAffineTransformMakeTranslation(0, height);
    } completion:^(BOOL finished) {
    }];
}




- (void)tick:(CADisplayLink *)displayLink
{
    //NSLog(@"%@", NSStringFromCGPoint(self.centerHelperView.center));
    [self  setNeedsDisplay];
}

- (void)start
{
    if (self.displayLink == nil) {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
        [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop]
                               forMode:NSDefaultRunLoopMode];
        self.counter=2;
    }
}

- (void)complete
{
    self.counter--;
    if (self.counter==0) {
        [self.displayLink invalidate];
        self.displayLink = nil;
        if (!self.shown) {
            [self clearInput];
            [self removeFromSuperview];
            [self.delegate todoInputViewDidHide];
        } else {
            [self.delegate todoInputViewDidShow];
        }
    }
}

- (void)drawRect:(CGRect)rect
{
    if (self.counter==0) {
        return;
    }
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = CGRectGetWidth(screenRect);
    
    CALayer* sideLayer=self.sideHelperView.layer.presentationLayer;
    CGPoint sidePoint=sideLayer.frame.origin;
    
    CALayer* centerLayer =self.centerHelperView.layer.presentationLayer;
    CGPoint centerPoint=centerLayer.frame.origin;
    
    UIBezierPath* path = [UIBezierPath bezierPath];
    
    [[UIColor whiteColor] setFill];
    
    [path moveToPoint:sidePoint];
    [path addQuadCurveToPoint:CGPointMake(screenWidth, sidePoint.y) controlPoint:centerPoint];
    [path addLineToPoint:CGPointMake(screenWidth,0)];
    [path addLineToPoint:CGPointMake(0, 0)];
    [path closePath];
    [path fill];
}


@end

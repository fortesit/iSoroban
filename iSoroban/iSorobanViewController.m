//
//  iSorobanViewController.m
//  iSoroban
//
//  Created by Sit King Lok on H25/12/20.
//  Copyright (c) 平成25年 Sit King Lok. All rights reserved.
//

#import "iSorobanViewController.h"

#define X_DIST 111  // Horizontal distance between 2 beads
#define Y_DIST 83   // Vertical distance between 2 beads
#define X_CORD(i) (124.5 + X_DIST * (i - 1)) // x-cordinate, e.g. bead 1 is @124.5, bead 2 is @235.5, ...
#define Y_CORD(i) (262.5 + Y_DIST * (i - 1)) // y-cordinate, e.g. bead 1 is @262.5 on excited state(upper position)
#define TOP_Y_CORD 80.5 // y-cordinate of bead 0, bead 5, ..., bead 35, hard-coded

@interface iSorobanViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIButton *themeButton;
@property (strong, nonatomic, retain) IBOutletCollection(UIImageView) NSArray *beadsCollection;
//@property (strong, nonatomic) IBOutlet UILabel *sumLabel;
@property (nonatomic) int sum;

@end

int counters[9];
NSInteger currentThemeIndex;

@implementation iSorobanViewController

//@synthesize sumLabel;
@synthesize imageView;
@synthesize themeButton;
@synthesize beadsCollection;

- (void)viewDidLoad
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self initWithTheme:0];
//    [self updateSumLabel];
    
    self.view.multipleTouchEnabled = YES;
    
    for (UIView *view in self.beadsCollection) {
        [view setUserInteractionEnabled:YES];
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateSumLabel{
    NSLog(@"%@", [NSString stringWithFormat:@"Sum: %d", self.sum]);
//    [self.sumLabel setText: [NSString stringWithFormat: @"Sum: %d", self.sum]];
}

- (IBAction)selectTheme:(UIButton *)sender
{
    UIActionSheet * themeActionSheet = [[UIActionSheet alloc] initWithTitle: nil
                                                              delegate: self
                                                     cancelButtonTitle: nil
                                                destructiveButtonTitle: nil
                                                     otherButtonTitles: @"Basic", @"Panda", @"Roman" ,@"iOS6", nil];
    
    [themeActionSheet showFromRect: sender.frame inView: sender.superview animated: YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    currentThemeIndex = buttonIndex;
    [self initWithTheme:buttonIndex];
}

- (void)initWithTheme:(NSInteger)themeIndex
{
    if(themeIndex == 0){
        //NSLog(@"Index 0");
        //NSLog(@"Index 1");
        for(UIImageView *perView in self.beadsCollection) {
            
            UIImage *newImage = [UIImage imageNamed:@"Bead1.png"];
            //NSLog(@"%s", perView.image);
            [perView setImage: newImage];
            newImage = [UIImage imageNamed:@"Plate1.png"];
            [self.imageView setImage: newImage ];
        }
    }
    else if(themeIndex == 1){
        //NSLog(@"Index 1");
        for(UIImageView *perView in self.beadsCollection) {
            UIImage *newImage = [UIImage imageNamed:@"Bead2.png"];
            //NSLog(@"%s", perView.image);
            [perView setImage: newImage];
            newImage = [UIImage imageNamed:@"Plate2.png"];
            [self.imageView setImage: newImage ];
        }
    }
    else if(themeIndex == 2){
        //NSLog(@"Index 2");
        for(UIImageView *perView in self.beadsCollection) {
            UIImage *newImage = [UIImage imageNamed:@"Bead3.png"];
            //NSLog(@"%s", perView.image);
            [perView setImage: newImage];
            newImage = [UIImage imageNamed:@"Plate3.png"];
            [self.imageView setImage: newImage ];
        }
    }
    else if(themeIndex == 3){
        //NSLog(@"Index 3");
        for(UIImageView *perView in self.beadsCollection) {
            UIImage *newImage = [UIImage imageNamed:@"Bead4.png"];
            //NSLog(@"%s", perView.image);
            [perView setImage: newImage];
            newImage = [UIImage imageNamed:@"Plate4.png"];
            [self.imageView setImage: newImage ];
        }
    }

}

- (void)moveViewWithAnimation:(UIView *)viewToMove toLocation:(CGPoint)location
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    [UIView beginAnimations:@"MoveView" context:ctx];
    [UIView setAnimationDuration:0.1];
    viewToMove.center = location;
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(sumLabel)];
    
    [UIView commitAnimations];
    [self playSoundEffect:self.getSoundFileName with:@"mp3" ];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches){
        UIView *touchingView = [touch view];
        if ([touchingView isKindOfClass:[UIImageView class]]){
            CGPoint location;
            location.x = touchingView.center.x;
            if ([touch locationInView:self.view].y < touchingView.center.y - Y_DIST / 2){
                [self moveUpBead:touchingView];
            }
            
            if ([touch locationInView:self.view].y > touchingView.center.y + Y_DIST / 2){
                [self moveDownBead:touchingView];
            }
        }
        //[self updateSumLabel];
    }
}

#define COUNTERNO(f) ((int)((f - 124.5) / X_DIST + 1))

- (void)moveUpBead:(UIView *)bead
{
    CGPoint location;
    BOOL movable = YES;
    if (bead.center.y == Y_CORD(1) || bead.center.y == TOP_Y_CORD)
        return ;
    for (UIView *otherBead in self.beadsCollection){
        if (otherBead.center.x == bead.center.x && otherBead.center.y == bead.center.y - Y_DIST){
            [self moveUpBead:otherBead];
            if (otherBead.center.y == bead.center.y - Y_DIST)
                movable = NO;
            break;
        }
    }
    if (movable){
        if (bead.center.y == TOP_Y_CORD + Y_DIST){
//            NSLog(@"-5, %d", COUNTERNO(bead.center.x));
            self.sum -= 5 * pow(10.0, 8 - COUNTERNO(bead.center.x));
//            NSLog(@"%d", self.sum);
        } else {
//            NSLog(@"+1, %d", COUNTERNO(bead.center.x));
            self.sum += 1 * pow(10.0, 8 - COUNTERNO(bead.center.x));
//            NSLog(@"%d", self.sum);
        }
        [self updateSumLabel];
        location.x = bead.center.x;
        location.y = bead.center.y - Y_DIST;
//        NSLog(NSStringFromCGPoint(location));
        [self moveViewWithAnimation:bead toLocation:location];
    }
}

- (void)moveDownBead:(UIView *)bead
{
    CGPoint location;
    BOOL movable = YES;
    if (bead.center.y == Y_CORD(5) || bead.center.y == TOP_Y_CORD + Y_DIST) {
        return;
    }
    for (UIView *otherBead in self.beadsCollection){
        if (otherBead.center.x == bead.center.x && otherBead.center.y == bead.center.y + Y_DIST){
            [self moveDownBead:otherBead];
            if (otherBead.center.y == bead.center.y + Y_DIST) {
                movable = NO;
            }
            break;
        }
    }
    if (movable){
        if (bead.center.y == TOP_Y_CORD){
//            NSLog(@"x = %f", bead.center.x);
//            NSLog(@"+5, %d", COUNTERNO(bead.center.x));
            self.sum += 5 * pow(10.0, 8 - COUNTERNO(bead.center.x));
//            NSLog(@"%d", self.sum);
        } else {
//            NSLog(@"-1, %d", COUNTERNO(bead.center.x));
            self.sum -= 1 * pow(10.0, 8 - COUNTERNO(bead.center.x));
//            NSLog(@"%d", self.sum);
        }
        [self updateSumLabel];
        location.x = bead.center.x;
        location.y = bead.center.y + Y_DIST;
        
        [self moveViewWithAnimation:bead toLocation:location];
    }
}

-(void)initBead
{    
    for (UIView *bead in self.beadsCollection) {
        if (bead.center.y == TOP_Y_CORD || bead.center.y == TOP_Y_CORD + Y_DIST) {
            if (bead.center.y == TOP_Y_CORD + Y_DIST) {
                [self moveUpBead: bead];
            }
        } else {
            [self moveDownBead: bead];
        }
    }
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake) {
        [self playSoundEffect:self.getSoundFileName with:@"mp3" ];
        [self initBead];
    }
}

- (NSString *)getSoundFileName
{
    switch (currentThemeIndex) {
        case 0:
            return @"basic";
            break;
        case 1:
            return @"panda";
            break;
        case 2:
            return @"roman";
            break;
    }
    return nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self becomeFirstResponder];
}

-(void)playSoundEffect:(NSString *)fileName with:(NSString *)fileExtenstion
{
    NSString *path  = [[NSBundle mainBundle] pathForResource:fileName ofType:fileExtenstion];
    NSURL *pathURL = [NSURL fileURLWithPath : path];
    
    SystemSoundID audioEffect;
    AudioServicesCreateSystemSoundID((CFURLRef) CFBridgingRetain(pathURL), &audioEffect);
    AudioServicesPlaySystemSound(audioEffect);
    
    // call the following function when the sound is no longer used
    // (must be done AFTER the sound is done playing)
    AudioServicesDisposeSystemSoundID(audioEffect);
}

@end

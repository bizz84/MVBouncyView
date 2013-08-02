/*
 Copyright (c) 2013 Andrea Bizzotto bizz84@gmail.com
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */


#import "ViewController.h"
#import "UIView+Bouncing.h"

@interface ViewController ()

@property UITapGestureRecognizer *grayTapRecognizer;
@property UITapGestureRecognizer *whiteTapRecognizer;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.grayTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGreyTap:)];
    [self.topView addGestureRecognizer:self.grayTapRecognizer];

    self.whiteTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleWhiteTap:)];
    [self.bottomView addGestureRecognizer:self.whiteTapRecognizer];
    
    self.topView.bounceAmplitude = 1.5f;
    self.topView.bounceAttenuation = 1.05f;
    self.topView.bounceDuration = 0.5f;

    self.bottomView.bounceAmplitude = 1.25f;
    self.bottomView.bounceAttenuation = 1.05f;
    self.bottomView.bounceDuration = 0.3f;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleGreyTap:(UITapGestureRecognizer *)sender {
    
    [self.topView bounce];
}

- (void)handleWhiteTap:(UITapGestureRecognizer *)sender {
    
    [self.bottomView bounce];
}

- (IBAction)resetButtonPressed:(UIButton *)sender {
   
    [self.topView cancelBounce];
    [self.bottomView cancelBounce];
}


@end

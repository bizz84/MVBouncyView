/*
Copyright (c) 2013 Andrea Bizzotto bizz84@gmail.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "UIView+Bouncing.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

// Enable touch interaction while button is being animated:
// http://stackoverflow.com/questions/8346100/uibutton-cant-be-touched-while-animated-with-uiview-animatewithduration

// Category properties
// http://kaspermunck.github.io/2012/11/adding-properties-to-objective-c-categories/
NSString const *kBouncingKey = @"com.BouncingView.Bouncing";
NSString const *kBounceAmplitudeKey = @"com.BouncingView.BounceAmplitude";
NSString const *kBounceAttenuationKey = @"com.BouncingView.BounceAttenuation";
NSString const *kBounceDurationKey = @"com.BouncingView.BounceDuration";

NSString const *kBounceOriginalFrameKey = @"com.BouncingView.BounceOriginalFrame";

#define kDefaultBounceDuration 0.3f
#define kDefaultBounceAmplitude 1.25f
#define kDefaultBounceAttenuation 1.05f

typedef enum {
    BounceDirectionHorz,
    BounceDirectionVert,
} BounceDirection;

@interface UIView(Bouncing_Private)

@property CGRect originalFrame;

@end

@implementation UIView(Bouncy)


- (void)cancelBounce {
    
    if (self.bouncing) {
        [self.layer removeAllAnimations];
        // If originalFrame was ever set, reset 
        if (self.originalFrame.size.width != 0.0f && self.originalFrame.size.height != 0.0f)
            self.frame = self.originalFrame;
        self.bouncing = NO;
    }
}

- (void)bounce:(void(^)(BOOL finished))doneBlock {
    
    // Lazy initialize properties
    if (self.bounceAmplitude <= 0.0f) {
        self.bounceAmplitude = kDefaultBounceAmplitude;
    }
    NSAssert(self.bounceAmplitude >= 1.0f, @"bounceAmplitude must be >= 1.0");

    if (self.bounceAttenuation <= 0.0f) {
        self.bounceAttenuation = kDefaultBounceAttenuation;
    }
    NSAssert(self.bounceAttenuation >= 1.0f, @"bounceAmplitude must be >= 1.0");
    
    if (self.bounceDuration <= 0.0f) {
        self.bounceDuration = kDefaultBounceDuration;
    }

    // TODO: Add KVO for setFrame
    if (self.originalFrame.size.width == 0.0f && self.originalFrame.size.height == 0.0f) {
        self.originalFrame = self.frame;
    }
    [self.layer removeAllAnimations];
    self.bouncing = YES;
    [self recursiveBounce:BounceDirectionHorz amplitude:self.bounceAmplitude referenceFrame:self.frame done:doneBlock];
}

- (void)recursiveBounce:(BounceDirection)direction amplitude:(float)amplitude referenceFrame:(CGRect)refFrame done:(void(^)(BOOL finished))doneBlock {

    CGSize size = refFrame.size;
    CGPoint center = CGPointMake(refFrame.origin.x + size.width / 2.0f, refFrame.origin.y + size.height / 2.0f);
    
    CGSize span = direction == BounceDirectionHorz
        ? CGSizeMake(size.width * amplitude, size.height / amplitude)
        : CGSizeMake(size.width / amplitude, size.height * amplitude);
    
    CGRect next = CGRectMake(center.x - span.width / 2.0f, center.y - span.height / 2.0f, span.width, span.height);
    
    [UIView animateWithDuration:self.bounceDuration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.frame = next;
        
    } completion:^(BOOL finished) {
        
        if (finished) {

            if (amplitude > 1.0f) {
                float targetAmplitude = amplitude / self.bounceAttenuation;
                float nextAmplitude = targetAmplitude > 1.0f ? targetAmplitude : 1.0f;
                BounceDirection nextDirection = direction == BounceDirectionHorz ? BounceDirectionVert : BounceDirectionHorz;
                [self recursiveBounce:nextDirection amplitude:nextAmplitude referenceFrame:refFrame done:doneBlock];
            }
            else {
                self.bouncing = NO;
                if (doneBlock != nil) {
                    doneBlock(YES);
                }
            }
        }
    }];
}

#pragma mark - Getters, setters

// Bouncing
- (void)setBouncing:(BOOL)bouncing {
    objc_setAssociatedObject(self, &kBouncingKey, @(bouncing), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)bouncing {
    
    return [objc_getAssociatedObject(self, &kBouncingKey) boolValue];
}

// Amplitude
- (void)setBounceAmplitude:(float)bounceAmplitude {
    
    objc_setAssociatedObject(self, &kBounceAmplitudeKey, @(bounceAmplitude), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (float)bounceAmplitude {
    
    return [objc_getAssociatedObject(self, &kBounceAmplitudeKey) floatValue];
}

// Attenuation
- (void)setBounceAttenuation:(float)bounceAttenuation {
    
    objc_setAssociatedObject(self, &kBounceAttenuationKey, @(bounceAttenuation), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (float)bounceAttenuation {
    
    return [objc_getAssociatedObject(self, &kBounceAttenuationKey) floatValue];
}

// Duration
- (void)setBounceDuration:(float)bounceDuration {
    
    objc_setAssociatedObject(self, &kBounceDurationKey, @(bounceDuration), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (float)bounceDuration {
    
    return [objc_getAssociatedObject(self, &kBounceDurationKey) floatValue];
}

// Frame
- (void)setOriginalFrame:(CGRect)originalFrame {
    
    // Need to encode as NSDictionary to pass as id
    NSDictionary *value = @{
                            @"origin.x" : @(originalFrame.origin.x),
                            @"origin.y" : @(originalFrame.origin.y),
                            @"size.width" : @(originalFrame.size.width),
                            @"size.height" : @(originalFrame.size.height)
                            };
                            
    objc_setAssociatedObject(self, &kBounceOriginalFrameKey, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGRect)originalFrame {
    
    NSDictionary *value = objc_getAssociatedObject(self, &kBounceOriginalFrameKey);
    if (value == nil) {
        return CGRectMake(0.0, 0.0, 0.0, 0.0);
    }
    return CGRectMake(
                      [[value objectForKey:@"origin.x"] floatValue],
                      [[value objectForKey:@"origin.y"] floatValue],
                      [[value objectForKey:@"size.width"] floatValue],
                      [[value objectForKey:@"size.height"] floatValue]);
}

@end

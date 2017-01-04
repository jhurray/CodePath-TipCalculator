//
//  ViewController.m
//  TipCalculator
//
//  Created by  Jeffrey Hurray on 1/3/17.
//  Copyright © 2017 Jeffrey Hurray. All rights reserved.
//

#import "TCTipViewController.h"
#import "UITextField+TCAdditions.h"

@interface TCTipViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;

@end

static NSString * const kTCLastDateSavedKey = @"kTCLastDateSavedKey";
static NSString * const kTCLastAmountSavedKey = @"kTCLastAmountSavedKey";
static NSString * const kTCLastTipPercentageSavedKey = @"kTCLastTipPercentageSavedKey";

#define kSaveDuration (60 * 10) // 15 minutes

@implementation TCTipViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Tip Calculator";
    
    [self.textField becomeFirstResponder];
    self.textField.delegate = self;
    [self.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.textField tc_setPlaceholderColor:[UIColor whiteColor]];
    
    [self.segmentedControl addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self loadLastAmountSavedIfNecessary];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.isViewLoaded) {
        [self loadLastAmountSavedIfNecessary];
    }
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self saveCurrentValues];
}


- (void)loadLastAmountSavedIfNecessary
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDate *lastSavedDate = [defaults objectForKey:kTCLastDateSavedKey];
    if (lastSavedDate != nil && lastSavedDate.timeIntervalSinceNow < kSaveDuration) {
        NSString *lastAmountSaved = [defaults stringForKey:kTCLastAmountSavedKey];
        if (lastAmountSaved != nil) {
            self.textField.text = lastAmountSaved;
            [self updateUI];
        }
    }
}


- (void)saveCurrentValues
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:(self.textField.text ?: @"") forKey:kTCLastAmountSavedKey];
    [defaults setObject:self.currentTipValue forKey:kTCLastTipPercentageSavedKey];
    [defaults setObject:[NSDate date] forKey:kTCLastDateSavedKey];
}


- (void)updateUI
{
    self.tipLabel.text = [NSString stringWithFormat:@"%0.2f", self.tipAmount];
    self.totalLabel.text = [NSString stringWithFormat:@"%0.2f", self.totalAmount];
}


- (double)costInput
{
    if (self.textField.text.length > 0) {
        return self.textField.text.doubleValue;
    }
    else {
        return 0.0;
    }
}


- (NSNumber *)currentTipValue
{
    static NSArray<NSNumber *> *tipValues;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tipValues = @[
                      @0.15,
                      @0.18,
                      @0.2,
                      ];
    });
    
    NSInteger currentIndex = self.segmentedControl.selectedSegmentIndex;
    return tipValues[currentIndex];
}


- (double)tipAmount
{
    return self.costInput * self.currentTipValue.doubleValue;
}


- (double)totalAmount
{
    return self.costInput + self.tipAmount;
}


- (void)segmentedControlValueChanged:(UISegmentedControl *)control
{
    [self updateUI];
    [self animateLabels];
}


- (void)animateLabels
{
    [self animateLabel:self.tipLabel withDelay:0];
    [self animateLabel:self.totalLabel withDelay:0.1];
}


- (void)animateLabel:(UILabel *)label withDelay:(NSTimeInterval)delay
{
    NSTimeInterval duration = 0.15;
    CGAffineTransform transform = CGAffineTransformMakeTranslation(-24, 0);
    [UIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionCurveEaseOut animations:^{
        label.transform = transform;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            label.transform = CGAffineTransformIdentity;
        } completion:NULL];
    }];
}


- (void)textFieldDidChange:(UITextField *)textField
{
    [self updateUI];
}


- (IBAction)clearButtonSelected:(id)sender
{
    self.textField.text = nil;
    [self updateUI];
    [self animateLabels];
}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return NO;
}

@end

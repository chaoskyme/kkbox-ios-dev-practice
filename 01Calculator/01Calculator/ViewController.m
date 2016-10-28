//
//  ViewController.m
//  01Calculator
//
//  Created by Chaosky on 2016/10/28.
//  Copyright © 2016年 ChaosZero. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UILabel *operatorLabel;

- (IBAction)clear:(UIButton *)sender;
- (IBAction)appendText:(UIButton *)sender;
- (IBAction)setOperator:(UIButton *)sender;
- (IBAction)doCalculation:(UIButton *)sender;
- (IBAction)togglePositiveNegative:(UIButton *)sender;
- (IBAction)memoryClear:(UIButton *)sender;
- (IBAction)memoryPlus:(UIButton *)sender;
- (IBAction)memoryMinus:(UIButton *)sender;
- (IBAction)memoryRecall:(UIButton *)sender;

@property (nonatomic, strong) NSDecimalNumber *leftOperand;
@property (nonatomic, strong) NSDecimalNumber *rightOperand;
@property (nonatomic, strong) NSDecimalNumber *memory;
@property (nonatomic, assign) SEL operatorSelector;
@property (nonatomic, assign) BOOL resetTextLabelOnNextAppending;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.textLabel.text = self.rightOperand ? self.rightOperand.stringValue : @"0";
    self.operatorLabel.text = @"";
    
    [self listSubviewsOfView:self.view];
    
}

- (void)listSubviewsOfView:(UIView *)view {
    
    // Get the subviews of the view
    NSArray *subviews = [view subviews];
    
    // Return if there are no subviews
    if ([subviews count] == 0) return; // COUNT CHECK LINE
    
    for (UIView *subview in subviews) {
        
        if ([subview isKindOfClass:[UIButton class]]) {
            subview.layer.borderWidth = 1;
            subview.layer.borderColor = [UIColor whiteColor].CGColor;
        }
        else {
            // List the subviews of subview
            [self listSubviewsOfView:subview];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clear:(UIButton *)sender {
    self.textLabel.text = @"0";
    self.operatorLabel.text = @"";
    
    self.leftOperand = nil;
    self.rightOperand = nil;
	
}

- (IBAction)appendText:(UIButton *)sender {
    if (self.resetTextLabelOnNextAppending) {
        self.textLabel.text = @"0";
        self.resetTextLabelOnNextAppending = NO;
    }
    NSString * text = sender.titleLabel.text;
    
    if ([text isEqualToString:@"."]) {
        if ([self.textLabel.text rangeOfString:@"."].location == NSNotFound) {
            self.textLabel.text = [self.textLabel.text stringByAppendingString:text];
        }
        return;
    }
    
    if ([self.textLabel.text isEqualToString:@"0"]) {
        if ([text isEqualToString:@"0"]) {
            return;
        }
        self.textLabel.text = text;
    }
    else {
        self.textLabel.text = [self.textLabel.text stringByAppendingString:text];
    }
}

- (void)_doCalculation
{
    if (self.operatorSelector == NULL || !self.rightOperand) {
        return;
    }
    if (self.operatorSelector == @selector(decimalNumberByDividingBy:) && [self.rightOperand floatValue] == 0.0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to devide 0!" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    NSDecimalNumber *result = [self.leftOperand performSelector:self.operatorSelector withObject:self.rightOperand];
    self.leftOperand = result;
    self.textLabel.text = [result stringValue];
    self.rightOperand = nil;
    self.resetTextLabelOnNextAppending = YES;
}

- (IBAction)setOperator:(UIButton *)sender {
    if (!self.leftOperand) {
        self.leftOperand = [NSDecimalNumber decimalNumberWithString:self.textLabel.text];
        self.rightOperand = nil;
    }
    else if (!self.resetTextLabelOnNextAppending) {
        self.rightOperand = [NSDecimalNumber decimalNumberWithString:self.textLabel.text];
        [self _doCalculation];
    }
    
    NSString *str = sender.titleLabel.text;
    NSDictionary *keySelectorMap = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"decimalNumberByAdding:", @"+",
                                    @"decimalNumberBySubtracting:", @"-",
                                    @"decimalNumberByMultiplyingBy:", @"*",
                                    @"decimalNumberByDividingBy:", @"/", nil];
    self.operatorSelector = NSSelectorFromString([keySelectorMap objectForKey:str]);
    self.operatorLabel.text = str;
    self.resetTextLabelOnNextAppending = YES;
}

- (IBAction)doCalculation:(UIButton *)sender {
    if (self.operatorSelector == NULL || !self.leftOperand) {
        return;
    }
    self.rightOperand = [NSDecimalNumber decimalNumberWithString:self.textLabel.text];
    [self _doCalculation];
    self.operatorLabel.text = @"";
    self.operatorSelector = NULL;
}

- (IBAction)togglePositiveNegative:(UIButton *)sender {
    if (self.resetTextLabelOnNextAppending) {
        self.leftOperand = nil;
        self.resetTextLabelOnNextAppending = NO;
    }
    self.operatorSelector = NULL;
    self.operatorLabel.text = @"";
    NSString *s = self.textLabel.text;
    self.textLabel.text = [s hasPrefix:@"-"] ? [s substringFromIndex:1] : [@"-" stringByAppendingString:s];
}

- (IBAction)memoryClear:(UIButton *)sender {
	self.memory = [NSDecimalNumber decimalNumberWithString:@"0"];
}

- (IBAction)memoryPlus:(UIButton *)sender {
    if (!self.memory) {
        self.memory = [NSDecimalNumber decimalNumberWithString:@"0"];
    }
    self.memory = [self.memory decimalNumberByAdding:[NSDecimalNumber decimalNumberWithString:self.textLabel.text]];
    self.resetTextLabelOnNextAppending = YES;
}

- (IBAction)memoryMinus:(UIButton *)sender {
    if (!self.memory) {
        self.memory = [NSDecimalNumber decimalNumberWithString:@"0"];
    }
    self.memory = [self.memory decimalNumberBySubtracting:[NSDecimalNumber decimalNumberWithString:self.textLabel.text]];
    self.resetTextLabelOnNextAppending = YES;
}

- (IBAction)memoryRecall:(UIButton *)sender {
    if (!self.memory) {
        self.memory = [NSDecimalNumber decimalNumberWithString:@"0"];
    }
    self.textLabel.text = [self.memory stringValue];
    if (!self.operatorSelector) {
        self.leftOperand = [self.memory copy];
    }
    self.resetTextLabelOnNextAppending = YES;
}

@end

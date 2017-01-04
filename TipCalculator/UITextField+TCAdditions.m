//
//  UITextField+Additions.m
//  TipCalculator
//
//  Created by  Jeffrey Hurray on 1/3/17.
//  Copyright © 2017 Jeffrey Hurray. All rights reserved.
//

#import "UITextField+TCAdditions.h"

@implementation UITextField (TCAdditions)

- (void)tc_setPlaceholderColor:(UIColor *)color
{
    if (color != nil) {
        NSDictionary *attributes = @{
                                     NSForegroundColorAttributeName: color,
                                     };
        self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:attributes];
    }
}

@end

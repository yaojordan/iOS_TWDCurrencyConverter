//
//  ViewController.h
//  CurrencyConverter
//
//  Created by 姚宇鴻 on 2017/2/19.
//  Copyright © 2017年 JordanYao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <NSXMLParserDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
{
    NSString *tagName;
    NSMutableArray *list2;//之後再增加list1
    NSString *numberFromTheKeyboard;
    NSNumber *myDoubleNumber;//把string轉成double用, 讓匯率數字可以傳給label
    
    /*__weak IBOutlet UILabel *calResult;
    __weak IBOutlet UILabel *currentRate;
    __weak IBOutlet UITextField *inputText;
    __weak IBOutlet UILabel *currentDollar;*///選擇的幣值
}

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic) IBOutlet UIToolbar *pickerToolbar;
- (IBAction)callPicker:(UIButton *)sender;
- (IBAction)done:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *inputText;
@property (weak, nonatomic) IBOutlet UILabel *calResult;
@property (strong, nonatomic) IBOutlet UILabel *currentRate;
@property (weak, nonatomic) IBOutlet UILabel *currentDollar;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityindicatorView;
@property (weak, nonatomic) IBOutlet UILabel *currentDate;
@property (weak, nonatomic) IBOutlet UIImageView *flagImage;

@end


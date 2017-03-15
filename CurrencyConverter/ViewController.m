//
//  ViewController.m
//  CurrencyConverter
//
//  Created by 姚宇鴻 on 2017/2/19.
//  Copyright © 2017年 JordanYao. All rights reserved.
//

#import "ViewController.h"
#import "Reachability.h"

@interface ViewController ()
{
    double rateArr[30];
    NSString *date;//更新日期
    int selrow;//選擇的幣值
    int count;
    double result;//換算結果
    double inputvalue;//輸入的金額
    NSString *str;
}
@end

@implementation ViewController
@synthesize calResult, currentRate, inputText, currentDollar, activityindicatorView, currentDate, flagImage;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initPicker];
    self.pickerView.hidden = YES;
    self.pickerToolbar.hidden = YES;
    
    self.inputText.keyboardType = UIKeyboardTypeDecimalPad;//呼叫帶小數點的鍵盤
    //鍵盤上加toolbar
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.items = @[[[UIBarButtonItem alloc]initWithBarButtonSystemItem:
                             UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self
                                                         action:@selector(doneWithNumberPad)]];
    [numberToolbar sizeToFit];
    inputText.inputAccessoryView = numberToolbar;
}
-(void)viewDidAppear:(BOOL)animated{
   
    //檢測網路狀態
    Reachability *reach = [Reachability reachabilityWithHostName:@"http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.xchange%20where%20pair%20in%20(%22USDTWD%22,%22HKDTWD%22,%22GBPTWD%22,%22AUDTWD%22,%22CADTWD%22,%22SGDTWD%22,%22CHFTWD%22,%22JPYTWD%22,%22ZARTWD%22,%22SEKTWD%22,%22NZDTWD%22,%22THBTWD%22,%22PHPTWD%22,%22IDRTWD%22,%22EURTWD%22,%22KRWTWD%22,%22VNDTWD%22,%22MYRTWD%22,%22CNYTWD%22)&env=store://datatables.org/alltableswithkeys"];
    NetworkStatus netsta = [reach currentReachabilityStatus];
    if(netsta == NotReachable)
    {
        [self JumpAlert];
    }
    else
    {
        [self getXMLandParse];
    }
    [activityindicatorView stopAnimating];//神奇轉轉轉結束
    //初始顯示美金, 美金匯率
    flagImage.image = [UIImage imageNamed:@"usa.png"];
    currentDollar.text = @"美金(USD) : 台幣(TWD)";
    selrow = 1;
    currentRate.text = [NSString stringWithFormat:@"1 : %.3f", rateArr[0]];
    calResult.text = [NSString stringWithFormat:@"= %.2f 台幣(TWD)", result];
    currentDate.text = [NSString stringWithFormat:@"%@", date];
}

-(void)doneWithNumberPad{
    numberFromTheKeyboard = inputText.text;
    [inputText resignFirstResponder];
    [self calculate];
}


-(IBAction)callPicker:(UIButton *)sender{
    //[self ViewAnimation:self.pickerView willHidden:NO];
    self.pickerToolbar.hidden = NO;
    self.pickerView.hidden = NO;
}
//picker toolbar done
- (IBAction)done:(id)sender {
    //[self ViewAnimation:self.pickerView willHidden:YES];
    self.pickerView.hidden = YES;
    self.pickerToolbar.hidden = YES;
}



-(void)getXMLandParse
{
    //GET xml from Yahoo finance
    NSURL *url = [NSURL URLWithString:@"http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.xchange%20where%20pair%20in%20(%22USDTWD%22,%22HKDTWD%22,%22GBPTWD%22,%22AUDTWD%22,%22CADTWD%22,%22SGDTWD%22,%22CHFTWD%22,%22JPYTWD%22,%22ZARTWD%22,%22SEKTWD%22,%22NZDTWD%22,%22THBTWD%22,%22PHPTWD%22,%22IDRTWD%22,%22EURTWD%22,%22KRWTWD%22,%22VNDTWD%22,%22MYRTWD%22,%22CNYTWD%22)&env=store://datatables.org/alltableswithkeys"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSOperationQueue *queue = [NSOperationQueue new];
    
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:queue
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *error) {
                               if([data length] > 0 && error == nil)
                               {
                                   NSString *currency = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   //NSLog(@"%@", currency);
                                   //印出xml內容
                               }
                               else
                               {
                                   NSLog(@"Error!");
                               }
                           }];
    //end
    
    //解析
    NSData *xmlData = [NSData dataWithContentsOfURL:url];
    NSXMLParser *xml = [[NSXMLParser alloc] initWithData:xmlData];
    [xml setDelegate:self];
    [xml parse];
    //end
}
//取得xml標籤中的起始標籤
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    tagName = nil;
    if([elementName isEqualToString:@"Rate"])
        tagName = elementName;
    if([elementName isEqualToString:@"Date"])
        tagName = elementName;
}
//取得xml起始標籤與結束標籤中的內容
-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{

    if([tagName isEqualToString:@"Rate"]){
       // NSLog(@"匯率：%@", string);
        rateArr[count]=[string doubleValue];
        count++;
    }
    if([tagName isEqualToString:@"Date"])
        date = string;
        
}
//取得結束標籤
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    tagName = nil;
}



//pickerview初始化
-(void)initPicker
{
    list2 = [NSMutableArray new];
    [list2 addObject:@"美國-美金(USD)"];
    [list2 addObject:@"香港-港幣(HKD)"];
    [list2 addObject:@"英國-英鎊(GBP)"];
    [list2 addObject:@"澳洲-澳幣(AUD)"];
    [list2 addObject:@"加拿大-加幣(CAD)"];
    [list2 addObject:@"新加坡-新幣(SGD)"];
    [list2 addObject:@"瑞士-瑞士法郎(CHF)"];
    [list2 addObject:@"日本-日圓(JPY)"];
    [list2 addObject:@"南非-南非幣(ZAR)"];
    [list2 addObject:@"瑞典-瑞典克朗(SEK)"];
    [list2 addObject:@"紐西蘭-紐元(NZD)"];
    [list2 addObject:@"泰國-泰銖(THB)"];
    [list2 addObject:@"菲律賓-菲國比索(PHP)"];
    [list2 addObject:@"印尼-印尼盾(IDR)"];
    [list2 addObject:@"歐盟-歐元(EUR)"];
    [list2 addObject:@"韓國-韓元(KRW)"];
    [list2 addObject:@"越南-越南盾(VND)"];
    [list2 addObject:@"馬來西亞-馬幣(MYR)"];
    [list2 addObject:@"中國-人民幣(CNY)"];
}
//產生的滾筒數
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
//滾筒中呈現資料筆數
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(component == 0)
    {
        return [list2 count];
    }
    return 0;
}
//滾筒資料內容
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if(component == 0)
    {
        return [list2 objectAtIndex:row];
    }
    return nil;
}
//使用者所選到的資料
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    if(component == 0)
    {
        //myDoubleNumber是為了把number形態的匯率轉回string供label顯示
        if([[list2 objectAtIndex:row] isEqualToString:@"美國-美金(USD)"]){
            flagImage.image = [UIImage imageNamed:@"usa.png"];
            selrow=1;
            currentDollar.text = (@"美金(USD) : 台幣(TWD)");
            myDoubleNumber = [NSNumber numberWithDouble:rateArr[0]];
        }
        if([[list2 objectAtIndex:row] isEqualToString:@"香港-港幣(HKD)"]){
            flagImage.image = [UIImage imageNamed:@"hongkong.png"];
            selrow=2;
            currentDollar.text = (@"港幣(HKD) : 台幣(TWD)");
            myDoubleNumber = [NSNumber numberWithDouble:rateArr[1]];
        }
        if([[list2 objectAtIndex:row] isEqualToString:@"英國-英鎊(GBP)"]){
            flagImage.image = [UIImage imageNamed:@"uk.png"];
            selrow=3;
            currentDollar.text = (@"英鎊(GBP) : 台幣(TWD)");
            myDoubleNumber = [NSNumber numberWithDouble:rateArr[2]];
        }
        if([[list2 objectAtIndex:row] isEqualToString:@"澳洲-澳幣(AUD)"]){
            flagImage.image = [UIImage imageNamed:@"australia.png"];
            selrow=4;
            currentDollar.text = (@"澳幣(AUD) : 台幣(TWD)");
            myDoubleNumber = [NSNumber numberWithDouble:rateArr[3]];
        }
        if([[list2 objectAtIndex:row] isEqualToString:@"加拿大-加幣(CAD)"]){
            flagImage.image = [UIImage imageNamed:@"canada.png"];
            selrow=5;
            currentDollar.text = (@"加幣(CAD) : 台幣(TWD)");
            myDoubleNumber = [NSNumber numberWithDouble:rateArr[4]];
        }
        if([[list2 objectAtIndex:row] isEqualToString:@"新加坡-新幣(SGD)"]){
            flagImage.image = [UIImage imageNamed:@"singapore.png"];
            selrow=6;
            currentDollar.text = (@"新幣(SGD) : 台幣(TWD)");
            myDoubleNumber = [NSNumber numberWithDouble:rateArr[5]];
        }
        if([[list2 objectAtIndex:row] isEqualToString:@"瑞士-瑞士法郎(CHF)"]){
            flagImage.image = [UIImage imageNamed:@"switzerland.jpg"];
            selrow=7;
            currentDollar.text = (@"瑞士法郎(CHF) : 台幣(TWD)");
            myDoubleNumber = [NSNumber numberWithDouble:rateArr[6]];
        }
        if([[list2 objectAtIndex:row] isEqualToString:@"日本-日圓(JPY)"]){
            flagImage.image = [UIImage imageNamed:@"japan.png"];
            selrow=8;
            currentDollar.text = (@"日圓(JPY) : 台幣(TWD)");
            myDoubleNumber = [NSNumber numberWithDouble:rateArr[7]];
        }
        if([[list2 objectAtIndex:row] isEqualToString:@"南非-南非幣(ZAR)"]){
            flagImage.image = [UIImage imageNamed:@"southafrica.png"];
            selrow=9;
            currentDollar.text = (@"南非幣(ZAR) : 台幣(TWD)");
            myDoubleNumber = [NSNumber numberWithDouble:rateArr[8]];
        }
        if([[list2 objectAtIndex:row] isEqualToString:@"瑞典-瑞典克朗(SEK)"]){
            flagImage.image = [UIImage imageNamed:@"sweden.png"];
            selrow=10;
            currentDollar.text = (@"瑞典克朗(SEK) : 台幣(TWD)");
            myDoubleNumber = [NSNumber numberWithDouble:rateArr[9]];
        }
        if([[list2 objectAtIndex:row] isEqualToString:@"紐西蘭-紐元(NZD)"]){
            flagImage.image = [UIImage imageNamed:@"newzealand.png"];
            selrow=11;
            currentDollar.text = (@"紐元(NZD) : 台幣(TWD)");
            myDoubleNumber = [NSNumber numberWithDouble:rateArr[10]];
        }
        if([[list2 objectAtIndex:row] isEqualToString:@"泰國-泰銖(THB)"]){
            flagImage.image = [UIImage imageNamed:@"thailand.png"];
            selrow=12;
            currentDollar.text = (@"泰銖(THB) : 台幣(TWD)");
            myDoubleNumber = [NSNumber numberWithDouble:rateArr[11]];
        }
        if([[list2 objectAtIndex:row] isEqualToString:@"菲律賓-菲國比索(PHP)"]){
            flagImage.image = [UIImage imageNamed:@"philippines.png"];
            selrow=13;
            currentDollar.text = (@"菲國比索(PHP) : 台幣(TWD)");
            myDoubleNumber = [NSNumber numberWithDouble:rateArr[12]];
        }
        if([[list2 objectAtIndex:row] isEqualToString:@"印尼-印尼盾(IDR)"]){
            flagImage.image = [UIImage imageNamed:@"indonesia.png"];
            selrow=14;
            currentDollar.text = (@"印尼盾(IDR) : 台幣(TWD)");
            myDoubleNumber = [NSNumber numberWithDouble:rateArr[13]];
        }
        if([[list2 objectAtIndex:row] isEqualToString:@"歐盟-歐元(EUR)"]){
            flagImage.image = [UIImage imageNamed:@"europe.png"];
            selrow=15;
            currentDollar.text = (@"歐元(EUR) : 台幣(TWD)");
            myDoubleNumber = [NSNumber numberWithDouble:rateArr[14]];
        }
        if([[list2 objectAtIndex:row] isEqualToString:@"韓國-韓元(KRW)"]){
            flagImage.image = [UIImage imageNamed:@"korea.png"];
            selrow=16;
            currentDollar.text = (@"韓元(KRW) : 台幣(TWD)");
            myDoubleNumber = [NSNumber numberWithDouble:rateArr[15]];
        }
        if([[list2 objectAtIndex:row] isEqualToString:@"越南-越南盾(VND)"]){
            flagImage.image = [UIImage imageNamed:@"vietnam.png"];
            selrow=17;
            currentDollar.text = (@"越南盾(VND) : 台幣(TWD)");
            myDoubleNumber = [NSNumber numberWithDouble:rateArr[16]];
        }
        if([[list2 objectAtIndex:row] isEqualToString:@"馬來西亞-馬幣(MYR)"]){
            flagImage.image = [UIImage imageNamed:@"malaysia.png"];
            selrow=18;
            currentDollar.text = (@"馬幣(MYR) : 台幣(TWD)");
            myDoubleNumber = [NSNumber numberWithDouble:rateArr[17]];
        }
        if([[list2 objectAtIndex:row] isEqualToString:@"中國-人民幣(CNY)"]){
            flagImage.image = [UIImage imageNamed:@"china.png"];
            selrow=19;
            currentDollar.text = (@"人民幣(CNY) : 台幣(TWD)");
            myDoubleNumber = [NSNumber numberWithDouble:rateArr[18]];
        }
        str = [myDoubleNumber stringValue];
        currentRate.text = [NSString stringWithFormat:@"1 : %@", str];
        [self calculate];
    }
    
}

-(void)calculate{
    
    inputvalue = [inputText.text doubleValue];
    
    if(selrow == 1)
        result = rateArr[0] * inputvalue;    
    if(selrow == 2)
        result = rateArr[1] * inputvalue;
    if(selrow == 3)
        result = rateArr[2] * inputvalue;
    if(selrow == 4)
        result = rateArr[3] * inputvalue;
    if(selrow == 5)
        result = rateArr[4] * inputvalue;
    if(selrow == 6)
        result = rateArr[5] * inputvalue;
    if(selrow == 7)
        result = rateArr[6] * inputvalue;
    if(selrow == 8)
        result = rateArr[7] * inputvalue;
    if(selrow == 9)
        result = rateArr[8] * inputvalue;
    if(selrow == 10)
        result = rateArr[9] * inputvalue;
    if(selrow == 11)
        result = rateArr[10] * inputvalue;
    if(selrow == 12)
        result = rateArr[11] * inputvalue;
    if(selrow == 13)
        result = rateArr[12] * inputvalue;
    if(selrow == 14)
        result = rateArr[13] * inputvalue;
    if(selrow == 15)
        result = rateArr[14] * inputvalue;
    if(selrow == 16)
        result = rateArr[15] * inputvalue;
    if(selrow == 17)
        result = rateArr[16] * inputvalue;
    if(selrow == 18)
        result = rateArr[17] * inputvalue;
    if(selrow == 19)
        result = rateArr[18] * inputvalue;
    
    calResult.text = [NSString stringWithFormat:@"= %.2f 台幣(TWD)",result];
}




/*呼叫pockerview的動畫設定
- (void)ViewAnimation:(UIView*)view willHidden:(BOOL)hidden {
    
    [UIView animateWithDuration:0.2 animations:^{
        if (hidden) {
            view.frame = CGRectMake(0, 430, 375, 260);
        } else {
            [view setHidden:hidden];
            view.frame = CGRectMake(0, 430, 375, 260);
        }
    } completion:^(BOOL finished) {
        [view setHidden:hidden];
    }];
}*/

-(void)JumpAlert{
    UIAlertController *alert =[UIAlertController alertControllerWithTitle:@"" message:@"找不到網路連線，無法獲取即時匯率" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"確認"style:UIAlertActionStyleDefault handler:^(UIAlertAction *alertAction){
        //按鈕按下去之後執行的動作
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    //把確定按鈕加到controller
    [alert addAction:alertAction];
    //顯示controller
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

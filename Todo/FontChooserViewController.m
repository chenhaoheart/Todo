//
//  FontChooserViewController.m
//  Todo
//
//  Created by ltebean on 15/4/3.
//  Copyright (c) 2015年 ltebean. All rights reserved.
//

#import "FontChooserViewController.h"
#import "Settings.h"

@interface FontChooserViewController()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *fonts;
@end

@implementation FontChooserViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.fonts = [UIFont familyNames];
}

#pragma mark UITableViewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fonts.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"FontCell" forIndexPath:indexPath];
    NSString *fontName = self.fonts[indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:fontName size:16];
    cell.textLabel.text = fontName;
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *fontFamily = self.fonts[indexPath.row];
    [Settings useFontFamily:fontFamily];
    [self.navigationController popViewControllerAnimated:YES];
}


@end

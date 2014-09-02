//
//  CollapsibleTableViewCellTests.m
//  SourceKitDemo
//
//  Created by Wei Mao on 12/12/13.
//  Copyright (c) 2013 cdts. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface CollapsibleTableViewCellTests : XCTestCase
{
    
    BOOL showFolder;
    NSIndexPath *showIndex;
    
    UITableView *tableview;
    UIView *foldView;
    NSMutableArray *sectionName;
    NSInteger cellNumber;
    
}

@end

@implementation CollapsibleTableViewCellTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

// 可折叠的TableViewCell
- (void)testExampleWithHostView:(UIView *)hostView
{
    showFolder=NO;
    showIndex=[NSIndexPath indexPathForRow:100 inSection:100];
    cellNumber=2;
    sectionName=[[NSMutableArray alloc] initWithObjects:@"请选择",@"呼叫中心搜索",@"数据库购买",@"媒体广告线索",@"社区活动线索",@"个人自主拓展",@"老客户转介绍",@"机会活动线索",@"其他", nil];
    if (foldView == nil) {
        foldView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
        foldView.backgroundColor = [UIColor lightGrayColor];
    }
    if (!tableview) {
        tableview=[[UITableView alloc] initWithFrame:CGRectMake( 0, 0,hostView.frame.size.width, hostView.frame.size.height) style:UITableViewStylePlain];
    }
    [hostView addSubview:tableview];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return cellNumber;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (showFolder&&[indexPath isEqual:showIndex] ) {
        
        static NSString *Cellid=@"cellid000";
        
        UITableViewCell *cell1=[tableview dequeueReusableCellWithIdentifier:Cellid];
        if (cell1==nil) {
            cell1=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Cellid];
            cell1.selectionStyle=UITableViewCellSelectionStyleNone;
        }
        [cell1.contentView addSubview:foldView];
        return cell1;
        
    }
    else{
        NSString *CELLID=[NSString stringWithFormat:@"cellid%d",(int)indexPath.row];
        
        UITableViewCell *cell=[tableview dequeueReusableCellWithIdentifier:CELLID];
        if (cell==nil) {
            cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELLID];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            
        }
        cell.tag=indexPath.row;
        cell.textLabel.font=[UIFont systemFontOfSize:15];
        cell.textLabel.text=@"点击cell显示UIPickerView";
        return cell;
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (showFolder&&[indexPath isEqual:showIndex]) {
        return 216.0f;
    }
    return 40.0f;
}
//folderView显示
- (void)insertRow:(NSIndexPath *)indexPath
{
    showFolder=YES;
    
    //    [typePicker update];
    
    NSMutableArray* rowToInsert = [[NSMutableArray alloc] init];
    
    NSIndexPath* indexPathToInsert = [NSIndexPath indexPathForRow:(indexPath.row+1) inSection:0];
    showIndex=indexPathToInsert;
    
    [rowToInsert addObject:indexPathToInsert];
    
    cellNumber=3;
    [tableview beginUpdates];
    
    [tableview insertRowsAtIndexPaths:rowToInsert withRowAnimation:UITableViewRowAnimationFade];
    [tableview endUpdates];
    
}

//pickerView消失；

- (void)deleteRow:(NSIndexPath *)RowtoDelete
{
    showFolder=NO;
    NSMutableArray* rowToDelete = [[NSMutableArray alloc] init];
    NSIndexPath* indexPathToDelete = showIndex;
    [rowToDelete addObject:indexPathToDelete];
    cellNumber=2;
    [tableview beginUpdates];
    [tableview deleteRowsAtIndexPaths:rowToDelete withRowAnimation:UITableViewRowAnimationFade];
    [tableview endUpdates];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!showFolder) {
        [self insertRow:indexPath];
    }
    else if(showFolder&&([[NSIndexPath indexPathForRow:(showIndex.row-1) inSection:0] isEqual:indexPath])){
        
        [self deleteRow:indexPath];
        
    }
    else if ([showIndex isEqual:indexPath]&&showFolder){
        NSLog(@"点击picker");
    }
    else if(showIndex&&![[NSIndexPath indexPathForRow:(showIndex.row-1) inSection:0] isEqual:indexPath]){
        
        [self deleteRow:indexPath];
    }
}


@end

//
//  ListingViewController.m
//  GitHub
//
//  Created by Anamika Sharma on 28/04/17.
//  Copyright © 2017 Anamika Sharma. All rights reserved.
//

#import "ListingViewController.h"
#import "CommitTableViewCell.h"

@interface ListingViewController ()


@end

@implementation ListingViewController{
    NSString *message;
    NSString *name;
    NSString *userImageUrl;
    NSString *commitId;
    NSString *userId;
    
    NSMutableArray *gitHubDataArray;
    UIActivityIndicatorView *activityView;
    
    __weak IBOutlet UIBarButtonItem *bookmarkBtn;
    
    __weak IBOutlet UIBarButtonItem *searchBtn;
    
    NSMutableArray* searchedArray;
    BOOL isSearched;
    BOOL isBookMarkClicked;
}
@synthesize bookMarkedCommit;

- (void)viewDidLoad {
    [super viewDidLoad];
    gitHubDataArray = [[NSMutableArray alloc] init];
    activityView = [[UIActivityIndicatorView alloc]
                                             initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    activityView.center=self.view.center;
    [activityView startAnimating];
    [self.view addSubview:activityView];
    isSearched = NO;
    dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul);
    dispatch_async(q, ^{
        [self getGitHubCommits];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
    bookMarkedCommit = [[NSMutableArray alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleUpdatedData:)
                                                 name:@"DataUpdated"
                                               object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(isSearched){
        return searchedArray.count;
    }else if(isBookMarkClicked){
        return self.bookMarkedCommit.count;
    }else{
        return gitHubDataArray.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CommitTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if(isSearched){
        [cell setMessage:[[[searchedArray objectAtIndex:indexPath.row] objectForKey:@"dict"] objectForKey:@"message"]];
        [cell setCommitId:[[[searchedArray objectAtIndex:indexPath.row] objectForKey:@"dict"] objectForKey:@"commitId"]];
//        [cell setUserImageView:[[[searchedArray objectAtIndex:indexPath.row] objectForKey:@"dict"] objectForKey:@"imageUrl"]];
        [cell setUserName:[[[searchedArray objectAtIndex:indexPath.row] objectForKey:@"dict"] objectForKey:@"name"]];
    }else if (isBookMarkClicked){
        [cell setMessage:[[[self.bookMarkedCommit objectAtIndex:indexPath.row] objectForKey:@"dict"] objectForKey:@"message"]];
        [cell setCommitId:[[[self.bookMarkedCommit objectAtIndex:indexPath.row] objectForKey:@"dict"] objectForKey:@"commitId"]];
        //        [cell setUserImageView:[[[searchedArray objectAtIndex:indexPath.row] objectForKey:@"dict"] objectForKey:@"imageUrl"]];
        [cell setUserName:[[[self.bookMarkedCommit objectAtIndex:indexPath.row] objectForKey:@"dict"] objectForKey:@"name"]];
    }else{
        [cell setMessage:[[[gitHubDataArray objectAtIndex:indexPath.row] objectForKey:@"dict"] objectForKey:@"message"]];
        [cell setCommitId:[[[gitHubDataArray objectAtIndex:indexPath.row] objectForKey:@"dict"] objectForKey:@"commitId"]];
        [cell setUserImageView:[[[gitHubDataArray objectAtIndex:indexPath.row] objectForKey:@"dict"] objectForKey:@"imageUrl"]];
        [cell setUserName:[[[gitHubDataArray objectAtIndex:indexPath.row] objectForKey:@"dict"] objectForKey:@"name"]];
    }
    
    // Configure the cell...
    
    return cell;
}

#pragma mark - GitHub API
-(void)getGitHubCommits{
    NSURL *url = [NSURL URLWithString:@"https://api.github.com/repos/rails/rails/commits"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *sessiontask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(!error){
            NSError *err;
            NSArray *dictData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
            NSMutableArray* newArray = [[NSMutableArray alloc] init];
            for (int i = 0; i<dictData.count; i++) {
                message = [[[dictData objectAtIndex:i] objectForKey:@"commit"] objectForKey:@"message"];
                commitId= [[dictData objectAtIndex:i] objectForKey:@"sha"];
                name = [[[[dictData objectAtIndex:i] objectForKey:@"commit"] objectForKey:@"author"] objectForKey:@"name"];
                userImageUrl = [[[dictData objectAtIndex:i] objectForKey:@"author"] objectForKey:@"avatar_url"];
                userId = [[[dictData objectAtIndex:i] objectForKey:@"author"] objectForKey:@"id"];
                
                NSDictionary *dict = @{@"message": message,
                                       @"commitId": commitId,
                                       @"name": name,
                                       @"imageUrl": userImageUrl};
                
                NSDictionary *myDict = @{@"userId" : userId,
                                         @"dict": dict};
                [newArray addObject:myDict];
            }
            [self sortMyArray:newArray];
            [activityView stopAnimating];
            [self.tableView reloadData];
        }
    }];
    [sessiontask resume];
}
-(void)sortMyArray:(NSArray*)array{
    NSSortDescriptor * descriptor = [[NSSortDescriptor alloc] initWithKey:@"userId" ascending:YES];
    array = [array sortedArrayUsingDescriptors:@[descriptor]];
    gitHubDataArray = [array copy];
    NSLog(@"%@",gitHubDataArray);
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    if(![searchBar.text isEqualToString:@""]){
        searchBar.hidden = YES;
        [self searchFor:searchBar.text];
    }
}
-(void)searchFor:(NSString*)string{
    searchedArray = [[NSMutableArray alloc] init];
    isSearched = YES;
    for (int i =0 ; i< gitHubDataArray.count; i++) {
        if([[[[gitHubDataArray objectAtIndex:i] objectForKey:@"dict"] objectForKey:@"name"] isEqualToString:string]){
            [searchedArray addObject:[gitHubDataArray objectAtIndex:i]];
        }
    }
    [self.tableView reloadData];

}
- (IBAction)didSearchClicked:(id)sender {
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(20, 0, 300, 50)];
    searchBar.delegate = self;
    [self.view addSubview:searchBar];
//    searchedArray = [[NSMutableArray alloc] init];
//    isSearched = YES;
//    for (int i =0 ; i< gitHubDataArray.count; i++) {
//        if([[[[gitHubDataArray objectAtIndex:i] objectForKey:@"dict"] objectForKey:@"name"] isEqualToString:@"Ryuta Kamizono"]){
//            [searchedArray addObject:[gitHubDataArray objectAtIndex:i]];
//        }
//    }
//    [self.tableView reloadData];
    
}
- (IBAction)didBookMarkClicked:(id)sender {
    isBookMarkClicked = YES;
    [self.tableView reloadData];
}

-(void)handleUpdatedData:(NSNotification *)notification {
    NSLog(@"recieved");
    for (int i =0 ; i< gitHubDataArray.count; i++) {
        if([[[[gitHubDataArray objectAtIndex:i] objectForKey:@"dict"] objectForKey:@"commitId"] isEqualToString:notification.object]){
                [self.bookMarkedCommit addObject:[gitHubDataArray objectAtIndex:i]];
        }
    }
    
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

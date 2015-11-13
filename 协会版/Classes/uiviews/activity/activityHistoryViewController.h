//
//  activityHistoryViewController.h
//  xieHui
//
//  Created by siphp on 13-4-25.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "IconDownLoader.h"
#import "DataManager.h"
#import "myImageView.h"

@interface activityHistoryViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,CommandOperationDelegate,IconDownloaderDelegate,myImageViewDelegate>
{
    UITableView *myTableView;
	NSMutableArray *activityItems;
	UIActivityIndicatorView *spinner;
    UILabel *moreLabel;
    BOOL _loadingMore;
    BOOL _isAllowLoadingMore;
    NSMutableDictionary *imageDownloadsInProgress;
	NSMutableArray *imageDownloadsInWaiting;
    CGFloat picWidth;
    CGFloat picHeight;
}

@property(nonatomic,retain) UITableView *myTableView;
@property(nonatomic,retain) NSMutableArray *activityItems;
@property(nonatomic,retain) UIActivityIndicatorView *spinner;
@property(nonatomic,retain) UILabel *moreLabel;
@property (nonatomic, assign) BOOL _loadingMore;
@property(nonatomic,retain) NSMutableArray *imageDownloadsInWaiting;
@property(nonatomic,retain) NSMutableDictionary *imageDownloadsInProgress;

//添加数据表视图
-(void)addTableView;

//滚动loading图片
- (void)loadImagesForOnscreenRows;

//保存缓存图片
-(bool)savePhoto:(UIImage*)photo atIndexPath:(NSIndexPath*)indexPath;

//获取网络图片
- (void)startIconDownload:(NSString*)photoURL forIndexPath:(NSIndexPath*)indexPath;

//回调 获到网络图片后的回调函数
- (void)appImageDidLoad:(NSIndexPath *)indexPath withImageType:(int)Type;

//更新记录
-(void)update;

//更多的操作
-(void)appendTableWith:(NSMutableArray *)data;

//网络获取数据
-(void)accessItemService;

//网络获取更多数据
-(void)accessMoreService;

//回归常态
-(void)backNormal;

//更多回归常态
-(void)moreBackNormal;

//网络请求回调函数
- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver;

@end

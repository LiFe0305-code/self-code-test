//
//  ViewController.m
//  PlayerDemo
//
//  Created by 李铁 on 2021/3/5.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
@interface ViewController ()

@property (nonatomic, strong) UIButton *playButton;

@property (nonatomic, strong) UIButton *pauseButton;

@property (nonatomic, strong) UIButton *resumeButton;

@property (nonatomic, strong) UIButton *stopButton;

@property (nonatomic, strong) UITextField *URLTextField;

@property (nonatomic,strong) AVPlayer *player;

@property (nonatomic,strong) AVPlayerLayer *playerLayer;

@property (nonatomic,strong) AVPlayerItem *currentPlayItem;

@property (nonatomic,strong) NSString *localVideoPath;

@property (nonatomic,strong) NSString *VideoPath;

@property (nonatomic,strong) UIView *containerView;

@property (nonatomic,strong) UISlider *playSlider;

@property (nonatomic,strong) UIButton *okButton;

@property (nonatomic,strong) UILabel *playTimeLabel;

@property (nonatomic ,strong) id timeObser;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 初始化
    self.playButton = [[UIButton alloc] init];
    [self.view addSubview: self.playButton];
    [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
    [self.playButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.playButton.frame = CGRectMake(25, 585, 50, 30);
    self.playButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    self.pauseButton = [[UIButton alloc] init];
    [self.view addSubview: _pauseButton];
    [self.pauseButton setTitle:@"Pause" forState:UIControlStateNormal];
    [self.pauseButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.pauseButton.frame = CGRectMake(25+50+15, 585, 50, 30);
    self.pauseButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    self.resumeButton = [[UIButton alloc] init];
    [self.view addSubview: self.resumeButton];
    [self.resumeButton setTitle:@"Resume" forState:UIControlStateNormal];
    [self.resumeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.resumeButton.frame = CGRectMake(25+50+25+50+15, 585, 70, 30);
    self.resumeButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    self.stopButton = [[UIButton alloc] init];
    [self.view addSubview: self.stopButton];
    [self.stopButton setTitle:@"Stop" forState:UIControlStateNormal];
    [self.stopButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.stopButton.frame = CGRectMake(25+50+25+50+25+50+25, 585, 50, 30);
    self.stopButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    self.URLTextField = [[UITextField alloc] init];
    self.URLTextField.frame = CGRectMake(10, 70, 300, 40);
    [self.view addSubview:self.URLTextField];
    self.URLTextField.borderStyle = UITextBorderStyleRoundedRect;
    
    self.playSlider=[[UISlider alloc] init];
    self.playSlider.frame=CGRectMake(10, 540, 350, 20);
    [self.view addSubview:self.playSlider];
    
    self.okButton = [[UIButton alloc] init];
    self.okButton.frame = CGRectMake(320, 75, 50, 30);
    [self.view addSubview:self.okButton];
    [self.okButton setTitle:@"Done" forState:UIControlStateNormal];
    self.okButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.okButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    self.playTimeLabel=[[UILabel alloc] init];
    self.playTimeLabel.frame=CGRectMake(250, 555, 50, 30);
    self.playTimeLabel.text=@"00:00:00";
    self.playTimeLabel.adjustsFontSizeToFitWidth=YES;
    [self.playTimeLabel setTintColor:[UIColor blackColor]];
    [self.view addSubview:self.playTimeLabel];
    
    //为按钮添加点击事件
    [self.playButton addTarget:self
                        action:@selector (didTapPlayButton:)
                   forControlEvents:UIControlEventTouchUpInside];
    [self.pauseButton addTarget:self
                         action:@selector (didTapPauseButton:)
                   forControlEvents:UIControlEventTouchUpInside];
    [self.resumeButton addTarget:self
                          action:@selector (didTapResumeButton:)
                   forControlEvents:UIControlEventTouchUpInside];
    [self.stopButton addTarget:self
                        action:@selector (didTapStopButton:)
                   forControlEvents:UIControlEventTouchUpInside];
    [self.okButton addTarget:self
                      action:@selector(didTapOkButton)
                    forControlEvents:UIControlEventTouchUpInside];
    //为拖动条添加事件
    [self.playSlider addTarget:self
                        action:@selector (sliderChange:)
                     forControlEvents:UIControlEventValueChanged];
    
}

//转换时间格式的方法
- (NSString *)formatTimeWithTimeInterVal:(NSTimeInterval)timeInterVal {
    int minute = 0, hour = 0, secend = timeInterVal;
    minute = (secend % 3600)/60;
    hour = secend / 3600;
    secend = secend % 60;
    return [NSString stringWithFormat:@"%02d:%02d:%02d", hour, minute, secend];
}

// 添加属性观察
- (void)observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(id)object
                       change:(NSDictionary *)change
                       context:(void *)context {
    AVPlayerItem *playerItem=(AVPlayerItem *)object;
    AVPlayerStatus status = [[change objectForKey:@"new"] intValue];
            switch (status) {
                case AVPlayerStatusReadyToPlay:{
                    //获取视频长度
                    CMTime duration = playerItem.duration;
                    self.playTimeLabel.text=[self formatTimeWithTimeInterVal:CMTimeGetSeconds(self.player.currentItem.duration)];
                    //开始播放视频
                    [self.player play];
                    break;
                }
                case AVPlayerStatusFailed:{//视频加载失败，点击重新加载
                    [self.playButton setTitle:@"资源加载失败，点击继续尝试加载" forState: UIControlStateNormal];
                    break;
                }
                case AVPlayerStatusUnknown:{
                    NSLog(@"加载遇到未知问题:AVPlayerStatusUnknown");
                    break;
                }
                default:
                    break;
            }
}

- (void)didTapPlayButton:(id)sender {
    //本地视频路径
    NSURL *webVideoUrl=[NSURL URLWithString:self.VideoPath];
    //网络视频路径
    NSURL *localVideoUrl = [NSURL fileURLWithPath:self.VideoPath];
    //判断视频路径是网络流或者是本地视频
    if([self.VideoPath rangeOfString:@"http"].location==NSNotFound){
    AVPlayerItem *item=[[AVPlayerItem alloc]initWithURL:localVideoUrl];
    self.player=[[AVPlayer alloc]initWithPlayerItem:item];
    }
    else{
    AVPlayerItem *item=[[AVPlayerItem alloc]initWithURL:webVideoUrl];
    self.player=[[AVPlayer alloc]initWithPlayerItem:item];
    }
    AVPlayerLayer *layer=[AVPlayerLayer playerLayerWithPlayer:self.player];
    //设置播放器画面大小及各种属性
    layer.frame=CGRectMake(0, 120, self.view.bounds.size.width, 400);
    layer.backgroundColor=[UIColor blackColor].CGColor;
    layer.videoGravity=AVLayerVideoGravityResizeAspect;
    [self.view.layer addSublayer:layer];
    //设置监听播放器的状态
    [self.player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    __weak __typeof(self) weakSelf=self;
    self.timeObser = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
    //当前播放时间
    NSTimeInterval currentTime=CMTimeGetSeconds(time);
    //视频总时间
    NSTimeInterval totalTime=CMTimeGetSeconds(weakSelf.player.currentItem.duration);
    //slider滑动进度
    weakSelf.playSlider.value=currentTime/totalTime;
    NSString *currentTimeString=[weakSelf formatTimeWithTimeInterVal:currentTime];
    NSString *totalTimeString=[weakSelf formatTimeWithTimeInterVal:totalTime];
    weakSelf.playTimeLabel.text=[NSString stringWithFormat:@"%@/%@",currentTimeString,totalTimeString];
         
  }];
}
  

- (void)didTapPauseButton:(id)sender {
    //点击停止按钮
    [self.player pause];
}

- (void)didTapResumeButton:(id)sender {
    //点击恢复播放按钮
    [self.player play];
}

- (void)didTapStopButton:(id)sender {
    //点击停止按钮
    [self.player pause];
    CMTime seekTime=CMTimeMake(0, 1);
    [self.player seekToTime:seekTime];
}
- (void)textFildEnd:(id)sender {
    //存储输入的路径url
    self.VideoPath=self.URLTextField.text;
    NSLog(@"hello");
}


- (void)sliderChange:(id)sender {
    //拖动进度条改变当前播放画面
    if(self.player.status == AVPlayerStatusReadyToPlay) {
        NSTimeInterval playTime=self.playSlider.value * CMTimeGetSeconds(self.player.currentItem.duration);
        CMTime seekTime=CMTimeMake(playTime, 1);
        [self.player seekToTime:seekTime completionHandler:^(BOOL finished) {}];
    }
}
- (void)didTapOkButton {
    //点击done后存储输入路径url
    self.VideoPath = self.URLTextField.text;
    NSLog(@"%@",self.VideoPath);
}

- (void)dealloc {
    //不需要实时更新播放时间和播放器后移除Timeobserver
    [self.player removeTimeObserver:self.timeObser];
}

@end

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.08 green:0.08 blue:0.10 alpha:1.0];
    
    // Background Art
    NSString *imgPath = [[NSBundle mainBundle] pathForResource:@"assets/art/promo/capsule_920x430" ofType:@"png"];
    if (imgPath) {
        UIImage *img = [UIImage imageWithContentsOfFile:imgPath];
        self.bgImageView = [[UIImageView alloc] initWithImage:img];
        self.bgImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.bgImageView.frame = self.view.bounds;
        self.bgImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:self.bgImageView];
    }
    
    // Title
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, self.view.bounds.size.height - 80, self.view.bounds.size.width - 40, 50)];
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.titleLabel.text = @"Tuệ Nhãn: Thức Anh Hùng (iOS Build)";
    self.titleLabel.textColor = [UIColor colorWithRed:0.95 green:0.85 blue:0.65 alpha:1.0];
    self.titleLabel.font = [UIFont fontWithName:@"PlayfairDisplay-Regular" size:22] ?: [UIFont boldSystemFontOfSize:20];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.titleLabel];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

@end

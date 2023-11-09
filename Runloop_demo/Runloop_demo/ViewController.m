//
//  ViewController.m
//  Runloop_demo
//
//  Created by maple on 2023/11/9.
//

#import "ViewController.h"

@interface YCThread : NSThread

@end

@implementation YCThread

- (void)dealloc {
    NSLog(@"%s", __func__);
}

@end

@interface ViewController ()

@property (nonatomic, strong) YCThread *thread;
@property (nonatomic, assign, getter=isStoped) BOOL stopped;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) weakSelf = self;
    
    self.thread = [[YCThread alloc] initWithBlock:^{
        NSLog(@"%@ ---begin---", [NSThread currentThread]);
        
        [[NSRunLoop currentRunLoop] addPort:[NSPort new] forMode:NSDefaultRunLoopMode];
        
        while (weakSelf && !weakSelf.isStoped) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
        
        NSLog(@"%@ ---end---", [NSThread currentThread]);
    }];
    [self.thread start];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.thread) return;;
    [self performSelector:@selector(test) onThread:self.thread withObject:nil waitUntilDone:NO];
}

- (void)test {
    NSLog(@"%s %@", __func__, [NSThread currentThread]);
}

- (void)stop {
    if (!self.thread) return;
    // 在子线程调用stop（waitUntilDone设置为YES，代表子线程的代码执行完毕后，这个方法才会往下走）
    [self performSelector:@selector(stopThread) onThread:self.thread withObject:nil waitUntilDone:YES];
}

// 用于停止子线程的RunLoop
- (void)stopThread
{
    // 设置标记为YES
    self.stopped = YES;
    
    // 停止RunLoop
    CFRunLoopStop(CFRunLoopGetCurrent());
    NSLog(@"%s %@", __func__, [NSThread currentThread]);
    
    // 清空线程
    self.thread = nil;
}

- (void)dealloc
{
    NSLog(@"%s", __func__);
    
    [self stop];
}

- (void)run {
    NSLog(@"%s %@", __func__, [NSThread currentThread]);
    
    [[NSRunLoop currentRunLoop] addPort:[NSPort new] forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] run];
    NSLog(@"%s ----end----", __func__);
}

@end

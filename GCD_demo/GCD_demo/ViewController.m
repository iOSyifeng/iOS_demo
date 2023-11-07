
//  ViewController.m
//  GCD_demo
//
//  Created by maple on 2023/11/7.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) dispatch_queue_t readWriteQueue;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //[self serialQueue];
    // [self multiSerialQueue];
    //[self concurrentQueue];
    
    //  [self barrier];
    // [self initReadWrite];
    
    //[self groupTest01];
   // [self groupTest02];
    
   // [self noSemaphore];
 //   [self semaphore];
    [self semaphoreControlThreadCount];
    
    //  [self interview01];
    //[self interview02];
    // [self interview03];
    
    // [self interview04];
    //[self interview05];
    //[self interview06];
}

-(void)interview01 {
    dispatch_queue_t queue = dispatch_queue_create("com.demo.queue", DISPATCH_QUEUE_CONCURRENT);
    NSLog(@"test____1"); // 任务1
    dispatch_async(queue, ^{
        NSLog(@"test____2"); // 任务2
        dispatch_sync(queue, ^{
            NSLog(@"test____3"); // 任务3
        });
        NSLog(@"test____4"); // 任务4
    });
    usleep(200);
    NSLog(@"test____5"); // 任务5
}

-(void)interview02 {
    dispatch_queue_t queue = dispatch_queue_create("com.demo.queue", DISPATCH_QUEUE_SERIAL);
    NSLog(@"test____1"); // 任务1
    dispatch_async(queue, ^{
        NSLog(@"test____2"); // 任务2
        dispatch_sync(queue, ^{
            NSLog(@"test____3"); // 任务3
        });
        NSLog(@"test____4"); // 任务4
    });
    NSLog(@"test____5"); // 任务5
}

- (void)interview03 {
    dispatch_queue_t queue = dispatch_queue_create("com.demo.serial", DISPATCH_QUEUE_SERIAL);
    NSLog(@"---任务1");
    dispatch_sync(queue, ^{
        NSLog(@"---任务2");
    });
    NSLog(@"---任务3");
}

- (void)interview04 {
    //全局队列
    dispatch_queue_t globQueue = dispatch_get_global_queue(0, 0);
    __block int a = 0;
    while (a < 100) {
        dispatch_async(globQueue, ^{
            //  NSLog(@"内部： %d  - %@",a,[NSThread currentThread]);
            a++;
        });
    };
    NSLog(@"外部打印_____ %d",a);
}

- (void)interview05 {
    dispatch_queue_t globalQueue = dispatch_get_global_queue(0, 0);
    __block int a = 0;
    for (int i = 0; i < 100; i++) {
        dispatch_async(globalQueue, ^{
            a++;
        });
    }
    NSLog(@"外部答应_____ %d",a);
}

//同步函数+并发队列 =》 在并发队列中进行插队，并不会等之前的任务执行完成，再执行这个同步任务，而是优先执行同步任务
//同步函数+串行队列 同步函数相同于栅栏函数，会等待队列中之前的任务完成之后再执行当前任务
- (void)interview06 {
    dispatch_queue_t queue = dispatch_queue_create("com.osDemo.concurrent", DISPATCH_QUEUE_CONCURRENT);
    for (int i = 0; i < 20; i++) {
        dispatch_async(queue, ^{
            NSLog(@"任务1");
        });
    }
    dispatch_sync(queue, ^{
        NSLog(@"任务2");
    });
}

- (void)noSemaphore {
    __block int a = 0;
    while (a < 5) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSLog(@"里面的a的值：%d-----%@", a, [NSThread currentThread]);
            a++;
        });
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2), dispatch_get_global_queue(0, 0), ^{
        NSLog(@"外面的a的值：%d", a);
    });
}

- (void)semaphore {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        __block int a = 0;
        while (a < 5) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSLog(@"里面的a的值：%d-----%@", a, [NSThread currentThread]);
                dispatch_semaphore_signal(semaphore);
                a++;
            });
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2), dispatch_get_global_queue(0, 0), ^{
        NSLog(@"外面的a的值：%d", a);
    });
}

//信号量控制并发队列线程数量
- (void)semaphoreControlThreadCount {
    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.osDemo.semaphore.queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(2);
    for (int i = 0; i < 10; i++) {
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        dispatch_async(concurrentQueue, ^{
            usleep(arc4random_uniform(1000));
            NSLog(@"做完了一个耗时任务%@",[NSThread currentThread]);
            dispatch_semaphore_signal(semaphore);
        });
    }
}

- (void)barrier {
    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.osDemo.concurrent", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(concurrentQueue, ^{
        usleep(20);
        NSLog(@"任务1---%@",[NSThread currentThread]);
    });
    dispatch_async(concurrentQueue, ^{
        usleep(30);
        NSLog(@"任务2---%@",[NSThread currentThread]);
    });
    dispatch_async(concurrentQueue, ^{
        usleep(40);
        NSLog(@"任务3---%@",[NSThread currentThread]);
    });
    dispatch_barrier_async(concurrentQueue, ^{
        usleep(40);
        NSLog(@"任务4---%@",[NSThread currentThread]);
    });
    
    dispatch_async(concurrentQueue, ^{
        usleep(40);
        NSLog(@"任务5---%@",[NSThread currentThread]);
    });
    dispatch_async(concurrentQueue, ^{
        usleep(40);
        NSLog(@"任务6---%@",[NSThread currentThread]);
    });
}

- (void)groupTest01 {
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    [self asyncInvoke:^{
        NSLog(@"网络请求A回来了");
        dispatch_group_leave(group);
    }];
    dispatch_group_enter(group);
    [self asyncInvoke:^{
        NSLog(@"网络请求B回来了");
        dispatch_group_leave(group);
    }];
    
    dispatch_group_enter(group);
    [self asyncInvoke:^{
        NSLog(@"网络请求C回来了");
        dispatch_group_leave(group);
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"绘制ui");
    });
}

//模仿异步执行
- (void)asyncInvoke:(dispatch_block_t)block {
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_async(queue, block);
}

//任务1，任务2在子线程并发执行，任务3等任务1和任务2完成后再在子线程执行
- (void)groupTest02 {
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    dispatch_group_async(group, queue, ^{
        for (int i = 0 ; i < 10; i++) {
            NSLog(@"%s-任务 1 - %@",__func__, [NSThread currentThread]);
        }
    });
    
    dispatch_group_async(group, queue, ^{
        for (int i = 0 ; i < 15; i++) {
            NSLog(@"%s-任务 2 - %@",__func__, [NSThread currentThread]);
        }
    });
    
    dispatch_group_notify(group, queue, ^{
        NSLog(@" %@", [NSThread currentThread]);
        dispatch_async(dispatch_get_main_queue(), ^{
            for (int i = 0 ; i < 5; i++) {
                NSLog(@"%s-任务 3 - %@",__func__, [NSThread currentThread]);
            }
        });
    });
}


//栅栏函数实现多读单写
- (void)initReadWrite {
    self.readWriteQueue = dispatch_queue_create("com.demo.readWrite", DISPATCH_QUEUE_CONCURRENT);
}

- (void)write:(NSString *)str {
    dispatch_barrier_async(self.readWriteQueue, ^{
        usleep(40);
        NSLog(@"我是一个写任务");
    });
}

- (void)readWithId:(NSString *)taskId completion:(void (^)(NSString *str, NSError *error))completion{
    dispatch_async(self.readWriteQueue, ^{
        usleep(40);
        NSLog(@"我是一个读任务");
        completion(@"result",nil);
    });
}


//并发队列
- (void)concurrentQueue {
    dispatch_queue_t queue = dispatch_queue_create("concurrent queue", DISPATCH_QUEUE_CONCURRENT);
    for (NSInteger index = 0; index < 10; index++) {
        dispatch_async(queue, ^{
            NSLog(@"task index %ld in concurrent queue", index);
        });
    }
}

//多个串行队列， 多个线程
- (void)multiSerialQueue {
    for (NSInteger index = 0; index < 10; index++) {
        dispatch_queue_t queue = dispatch_queue_create("different Serial queue", NULL);
        dispatch_async(queue, ^{
            NSLog(@"serial queue index : %ld", index);
        });
    }
}

//串行队列
- (void)serialQueue {
    dispatch_queue_t queue = dispatch_queue_create("serial queue", DISPATCH_QUEUE_SERIAL);
    for (NSInteger index = 0; index < 10; index++) {
        dispatch_async(queue, ^{
            NSLog(@"task index %ld in serial queue", index);
        });
    }
}


@end


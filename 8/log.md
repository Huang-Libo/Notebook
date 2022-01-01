# log

## 知乎架构组

```objectivec
int i = 10;
NSLog(@"before:%p\n", &i);

dispatch_async(dispatch_get_main_queue(), ^{
    NSLog(@"%d\n",i);
    NSLog(@"in block:%p\n", &i);
});

i = 20;
NSLog(@"after:%p\n", &i);
```

输出：

```plaintext
before:0x7ffeed4ab00c
after:0x7ffeed4ab00c
10
in block:0x600001a11e50
```

用 `i` 用 `__block` 修饰后：

```objectivec
__block int i = 10;
NSLog(@"before:%p\n", &i);

dispatch_async(dispatch_get_main_queue(), ^{
    NSLog(@"%d\n",i);
    NSLog(@"in block:%p\n", &i);
});

i = 20;
NSLog(@"after:%p\n", &i);
```

输出：

```plaintext
before:0x7ffeeac16008
after:0x600003a691f8
20
in block:0x600003a691f8
```

## 快看漫画

**问题一**，请指出下面代码存在的问题：

```objectivec
typedef enum {
    Normal;
    VIP;
} CustomerType;

@interface CustomerModel: NSObject

@property (nonatomic, copy) NSString * name;
@property (nonatomic, strong) UIImageView *profileImage;
@property (assign, nonatomic) CustomerType customerType;
@property (atomic, strong) NSMutableArray* shoppingList;
@property (nonatomic, strong) id<UITableViewDelegate> delegate;
@property (nonatomic, assign) id<UITableViewDataSource> Datasource;

@end
```

**问题二**，请问下面代码打印出什么：

```objectivec
- (void)isEqualString {
    NSString *firstStr = @"helloworld";
    NSString *secondStr = @"helloworld";

    if (firstStr == secondStr) {
        NSLog(@”Equal”);
    } else {
        NSLog(@”Not Equal”);
    }
}
```

**问题三**，请说明下面代码能否按预期执行：

```objectivec
NSInteger global_foo_6 = 0;

- (void)function
{
    NSMutableArray *array_1 = [NSMutableArray array];
  __block NSMutableArray *array_2 = nil;
    
  __block NSInteger foo_3 = 0;
    NSInteger *foo_4 = (NSInteger *)malloc(sizeof(NSInteger));
    
    static NSInteger static_foo_5 = 0;
    
    void (^bar)(void) = ^{
        [array_1 addObject:@1];
        array_2 = array_1;
        
        foo_3 = 3; 
        *foo_4 = 4;
        
        static_foo_5 = 5;
        global_foo_6 = 6;
    };
    bar();

    NSLog(@"%@, %@", array_1, array_2);
    
    free(foo_4);
    NSLog(@"%@, %@", @(foo_3), @(foo_4));
    
    NSLog(@"%@, %@", @(foo_5), @(foo_6));
}
```

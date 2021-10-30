# UIKit Tips

## 在 UIAlertController 中修改 UIAlertAction 的 label 上文字颜色和字体

**1、文字颜色**

颜色可以通过 `kvc` 设置私有属性的值，比如：

```objectivec
[action1 setValue:actionColor forKey:@"titleTextColor"];
```

**2、字体**

> 修改字体参考：<https://stackoverflow.com/questions/25988639/is-it-possible-to-edit-uialertaction-title-font-size-and-style>

字体不好改，根本没有 `font` 相关私有属性，对应的 `UILabel` 的嵌套层级很深。也不好直接去操作相应的 label 控件，因为如果新系统改了层级关系可能会出问题。

这里可以使用 `appearanceWhenContainedIn` 属性来改 `font` 。（ [MBProgressHUD](https://github.com/jdg/MBProgressHUD) 也用到了 `appearanceWhenContainedIn` 属性）

给 `UILabel` 添加一个分类：

```objectivec
#import <UIKit/UIKit.h>

@interface UILabel (FontAppearance)
@property (nonatomic, strong) UIFont *appearanceFont UI_APPEARANCE_SELECTOR;
@end
```

```objectivec
#import "UILabel+FontAppearance.h"

@implementation UILabel (FontAppearance)
- (void)setAppearanceFont:(UIFont *)font {
    if (font)
        [self setFont:font];
}

- (UIFont *)appearanceFont {
    return self.font;
}
@end
```

**修改文字颜色和字体的示例：**

导入 `#import "UILabel+FontAppearance.h"` 后即可使用，示例：

```objectivec
// 拍摄
- (void)stickerInputViewShootButtonClicked:(MJYPStickerInputView *)inputView {
    UIAlertController * hintVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"拍照片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // ...
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"录视频" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // ...
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIColor *actionColor = [MJYPColorUtils colorWithRGB:0x99621a];
    UIColor *cancelColor = [MJYPColorUtils colorWithRGB:0x000000 alpha:0.8];
    [action1 setValue:actionColor forKey:@"titleTextColor"];
    [action2 setValue:actionColor forKey:@"titleTextColor"];
    [cancel setValue:cancelColor forKey:@"titleTextColor"];
    [hintVC addAction:action1];
    [hintVC addAction:action2];
    [hintVC addAction:cancel];
    // 使用 appearanceWhenContainedIn 取出 label
    UILabel * appearanceLabel = [UILabel appearanceWhenContainedIn:UIAlertController.class, nil];
    [appearanceLabel setAppearanceFont:[UIFont systemFontOfSize:18.f]]; 
    [self presentViewController:hintVC animated:YES completion:nil];
}
```

警告 ⚠️⚠️⚠️ ：点击一下，字体又恢复成原始大小了。。。

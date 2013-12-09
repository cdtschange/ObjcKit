MHTextField 是 iOS 上扩展了 UITextField 的视图控件，实现内建的工具条、数据验证以及滚动支持。

#MHTextField
MHTextField is an iOS drop-in class that extends UITextField  with built-in toolbar, validation and scrolling support.

[![](http://mehfuzh.github.io/MHTextField/shot2_thumb.png)](http://mehfuzh.github.io/MHTextField/shot2.png)
[![](http://mehfuzh.github.io/MHTextField/shot3_thumb.png)](http://mehfuzh.github.io/MHTextField/shot3.png)
[![](http://mehfuzh.github.io/MHTextField/shot4_thumb.png)](http://mehfuzh.github.io/MHTextField/shot4.png)
[![](http://mehfuzh.github.io/MHTextField/shot5_thumb.png)](http://mehfuzh.github.io/MHTextField/shot5.png)

##Requirements
MHTextField works on iOS 5 and above and is compatible with ARC projects. It depends on the following Apple frameworks:

* Foundation.framework
* UIKit.framework
* QuartzCore.framework


##Including MHTextField to your project

### Source files

You can directly add the `MHTextField.h` and `MHTextField.m` source files to your project.

1. Download the latest zip from github or clone the source in your desired directory.
2. Open your project in Xcode, then drag and drop `MHTextField.h` and `MHTextField.m` onto your project (use the "Product Navigator view"). Make sure to select Copy items when asked if you extracted the code archive outside of your project. 
3. Include MHTextField with `#import "MHTextField.h"`.


### Cocoapods
[CocoaPods](http://cocoapods.org) is the recommended way to add MHTextField to your project.

1. Add a pod entry for MHTextField to your Podfile `pod 'MHTextField', '~> 0.0.1'`
2. Install the pod(s) by running `pod install`.
3. Include MHTextField with `#import "MHTextField.h"`.


## License

This code is distributed under the terms and conditions of the [MIT license](LICENSE). 

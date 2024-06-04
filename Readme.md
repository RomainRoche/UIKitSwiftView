# UIKitSwiftView

> This package should have been named `SwiftUIKitView`, turns out it already exists 🤓
> 
> https://github.com/AvdLee/SwiftUIKitView

## Bring some SwiftUI in your UIKit

This package allows you to directly insert **SwiftUI** components and syntax inside your **UIKit** legacy code. 

```
final class MyViewController: UIViewController {

    // this is UIKit 
    override func viewDidLoad() {
        super.viewDidLoad()

        let button = UIKitSwiftView {
            // and this is SwiftUI 🎉
            Button {
                print("some action")
            } label: {
                Text("This is a SwiftUI Button")
            }
        }

        view.addSubview(button)
  }

}
```




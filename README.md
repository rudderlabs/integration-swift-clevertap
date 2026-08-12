# RudderIntegrationCleverTap

RudderStack Swift SDK device mode integration for CleverTap.

## Installation

### Swift Package Manager

Add the following dependency to your `Package.swift`:

```swift
.package(url: "https://github.com/rudderlabs/integration-swift-clevertap.git", .upToNextMajor(from: "1.0.0"))
```

Or add it via Xcode:
1. Go to **File > Add Package Dependencies**
2. Enter the repository URL: `https://github.com/rudderlabs/integration-swift-clevertap`
3. Select **Up to Next Major Version** from `1.0.0`

## Usage

### Swift

```swift
import RudderStackAnalytics
import RudderIntegrationCleverTap

let config = Configuration(writeKey: "<WRITE_KEY>", dataPlaneUrl: "<DATA_PLANE_URL>")
let analytics = Analytics(configuration: config)

let cleverTapIntegration = CleverTapIntegration()
analytics.add(plugin: cleverTapIntegration)
```

### Objective-C

```objc
@import RudderStackAnalytics;
@import RudderIntegrationCleverTap;

RSSConfigurationBuilder *builder = [[RSSConfigurationBuilder alloc] initWithWriteKey:@"<WRITE_KEY>"
                                                                       dataPlaneUrl:@"<DATA_PLANE_URL>"];
RSSAnalytics *analytics = [[RSSAnalytics alloc] initWithConfiguration:[builder build]];

RSSCleverTapIntegration *cleverTapIntegration = [[RSSCleverTapIntegration alloc] init];
[analytics addPlugin:cleverTapIntegration];
```

## Dashboard configuration

Set these values in the CleverTap destination of the RudderStack dashboard:

| Field | Description |
|---|---|
| Account ID | The CleverTap account identifier. |
| Account Token | The CleverTap account token. |
| Region | The CleverTap account region. Select `none` to use the default region. |

The integration reports an error when the account identifier or the account token is absent.

## Supported calls

| Call | CleverTap behavior |
|---|---|
| `identify` | Calls `onUserLogin`. The user identifier becomes the `Identity` attribute. |
| `track` | Records a custom event with the event properties. |
| `track("Order Completed")` | Records a charged event. `order_id` becomes `Charged ID`, and `revenue` becomes `Amount`. Each product becomes an item, and `product_id` becomes `id`. |
| `screen` | Records a custom event with the name `Screen Viewed: <screen name>`. |
| `reset` | No effect. CleverTap keeps the profile until the next user login. |

### Trait mapping

| RudderStack trait | CleverTap attribute |
|---|---|
| `userId` | `Identity` |
| `email` | `Email` |
| `name` | `Name` |
| `phone` | `Phone` |
| `gender` | `Gender` (`M` or `F`) |
| `birthday` | `DOB`. Send the date in the `yyyy-MM-dd` format. |
| `address` / `company` | The nested values become flat attributes. The nested `id` becomes `companyId`, and the nested `name` becomes `companyName`. |

CleverTap accepts primitive values, dates, and string arrays. The integration drops every other
nested trait.

## Push notifications and in-app messages

This integration does not forward push notifications or in-app messages. Configure those features
directly with the CleverTap iOS SDK. For example:

```swift
CleverTap.sharedInstance()?.setPushToken(deviceToken)
CleverTap.sharedInstance()?.handleNotification(withData: userInfo)
```

## Sample app

The `Example` directory holds a SwiftUI sample app. Add your write key and data plane URL in
`Example/CleverTapExampleApp.swift`, then run the `Example` scheme.

## Documentation

For more information, see the [RudderStack documentation](https://www.rudderstack.com/docs/destinations/streaming-destinations/clevertap/).

## License

Elastic License 2.0 (ELv2) - see [LICENSE.md](LICENSE.md) for details.

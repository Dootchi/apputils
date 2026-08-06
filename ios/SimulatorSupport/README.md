# DpSDK simulator slice

The upstream DpSDK binary contains only an `ios-arm64` device slice. This
directory contains the source for a no-op simulator slice packaged alongside
the vendor framework so that consuming apps can still compile and launch in an
iOS simulator.

The Flutter adapter deliberately returns `sdk_unavailable` on simulators. No
ticket is generated there. The real vendor implementation is used unchanged on
physical arm64 devices.

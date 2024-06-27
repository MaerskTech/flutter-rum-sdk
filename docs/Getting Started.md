# RUM Flutter - 0.0.1 Alpha

## Getting Started

- Installation
- Initialise RUM

### Onboarding


### Installation

Add the following dependencies to your `pubspec.yaml`

```yml
rum_sdk:
  git:
    url: <git_url>
    path: packages/rum_sdk
    ref: main
```

### Initialise RUM

Add the following snippet to initialize RUM Monitoring with the default configurations

```dart

  HttpOverrides.global = RumHttpOverrides(HttpOverrides.current); // enable http tracking

  RumFlutter().runApp(
    optionsConfiguration: RumConfig(
        appName: "<App_Name>",
        appVersion: "1.0.0",
        appEnv: "Test",
        apiKey: "<API_KEY>",
    ),
    appRunner: () => runApp(
     RumUserInteractionWidget(child: MyApp())
    ),
  );



```


See all [configuration](./Configurations.md) options for RUM Flutter

# App Specification Template

Copy this file to your project's `.planning/APP.md` and fill in the details.

```xml
<app>
  <meta>
    <name>[App Name]</name>
    <bundle-id>com.yourcompany.appname</bundle-id>
    <platform>iOS | macOS | both</platform>
    <minimum-os>iOS 17.0 | macOS 14.0</minimum-os>
    <distribution>App Store | Direct | TestFlight</distribution>
    <devices>iPhone | iPad | Mac | Apple Watch | Apple TV</devices>
  </meta>

  <concept>
    <problem>[What problem does this app solve?]</problem>
    <users>[Who are the target users?]</users>
    <core-flow>[What's the ONE thing users do most?]</core-flow>
    <differentiator>[What makes this different from alternatives?]</differentiator>
  </concept>

  <architecture>
    <ui-framework>SwiftUI | UIKit</ui-framework>
    <pattern>MVVM | TCA | MVC</pattern>
    <data-layer>
      <local>SwiftData | Core Data | UserDefaults</local>
      <sync>CloudKit | Firebase | None</sync>
    </data-layer>
    <auth>Sign in with Apple | Custom | None</auth>
    <monetization>
      <model>Free | Paid | Freemium | Subscription</model>
      <details>[Pricing tiers if applicable]</details>
    </monetization>
  </architecture>

  <apple-technologies>
    <!-- Mark required="true" for must-have frameworks -->
    <framework required="true">SwiftUI</framework>
    <framework required="true">SwiftData</framework>
    <framework required="false">WidgetKit</framework>
    <framework required="false">App Intents</framework>
    <framework required="false">Live Activities</framework>
    <framework required="false">Apple Intelligence</framework>
    <framework required="false">CloudKit</framework>
    <framework required="false">HealthKit</framework>
    <framework required="false">HomeKit</framework>
    <framework required="false">MapKit</framework>
    <framework required="false">StoreKit 2</framework>
    <framework required="false">Push Notifications</framework>
    <framework required="false">SharePlay</framework>
    <framework required="false">Focus Filters</framework>
  </apple-technologies>

  <privacy>
    <data-collected>[What user data do you collect?]</data-collected>
    <permissions>
      <!-- Only include permissions you need -->
      <permission reason="[Why needed]">Camera</permission>
      <permission reason="[Why needed]">Microphone</permission>
      <permission reason="[Why needed]">Location</permission>
      <permission reason="[Why needed]">Photos</permission>
      <permission reason="[Why needed]">Contacts</permission>
      <permission reason="[Why needed]">Calendar</permission>
      <permission reason="[Why needed]">HealthKit</permission>
    </permissions>
    <tracking>None | [Analytics provider and purpose]</tracking>
  </privacy>

  <scope>
    <mvp-features>
      <!-- priority: must | should | could -->
      <feature priority="must">[Essential feature 1]</feature>
      <feature priority="must">[Essential feature 2]</feature>
      <feature priority="should">[Important feature 3]</feature>
      <feature priority="could">[Nice-to-have feature 4]</feature>
    </mvp-features>
    <non-goals>
      <non-goal>[What we explicitly won't build]</non-goal>
      <non-goal>[Another thing out of scope]</non-goal>
    </non-goals>
    <timeline>
      <target-submission>[Target App Store submission date]</target-submission>
    </timeline>
  </scope>
</app>
```

## How to Use

1. Run `/apple:new-app [AppName]` to generate this file through guided questions
2. Or copy this template manually and fill in each section
3. This file drives all subsequent commands (roadmap, plan, build)

## Key Sections

| Section | Purpose |
|---------|---------|
| `<meta>` | Technical identifiers and deployment targets |
| `<concept>` | Problem, users, core flow, differentiation |
| `<architecture>` | Technical stack decisions |
| `<apple-technologies>` | Which Apple frameworks to integrate |
| `<privacy>` | Data collection and permissions |
| `<scope>` | MVP features and explicit non-goals |

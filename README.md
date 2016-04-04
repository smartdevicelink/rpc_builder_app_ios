# RPC Builder v1.0.2

## Introduction

The SmartDeviceLink RPC Builder is designed to allow free testing of the SDL Interface during development. It will allow sending all Remote Procedure Calls (RPCs) to SDL Core. The user has to ensure the right sequence of commands to be send. (E.g. a performInteraction cannot be successful if the user did not send a createInteractionChoiceSet before. Please familiarize yourself with the SDL App Developer documentation.)

## Getting Started
In order to begin using RPC Builder, we must first gather [SDL_iOS](http://www.github.com/smartdevicelink/sdl_ios) and add it to the project. There is already support for cocoapods in this project, so all that is needed is to navigate to the directory and install:

```
cd RPC\ Builder/
pod install
```

## Interface

### Settings Page

<img src="/ReadmeFiles/Settings.png" width=200px>

The settings page allows the user to select the currently used RPC spec file, and the transport layer.

By default, there is a Mobile_API.xml file used to generate the RPC interfaces usable by the app. Please be sure to select this file to proceed. If you wish to use a different version, you may be able to use a new file added via iTunes file sharing to the `SpecXMLs` directory, or via a remote URL.

For the transport layer the current options included USB or TCP/IP. If TCP/IP is selected the user has to input the SDL Server IP Address and Port.

<img src="/ReadmeFiles/RegisterAppInterface.png" width=200px>

Once proceeding, you will be presented with a Register App Interface (RAI) RPC screen. This is required so that when the application first connects we can immediately register the application. These properties can be modified and will be cached for subsequent launches.

<img src="/ReadmeFiles/Connecting.png" width=200px>
> Please note that once "Send" is pressed, the application will not continue until a successful connection and RAI response is received.

### Main RPC Table

<img src="/ReadmeFiles/RPCs.png" width=200px>

The Main RPC Table is create at runtime by the App. The source for all possible RPC requests is the selected Spec XML from the settings.

If the Spec provides additional information, an information button next to the RPC Name is visible.

<img src="/ReadmeFiles/AddCommand.png" width=200px>

To send an RPC select the RPC from the Table

### RPC Commands

<img src="/ReadmeFiles/RPCs.png" width=200px>

When selecting an RPC command the App will show a view with all possible parameters for this RPC command. If a parameter is a struct or array, it will allow you fill this information in a separate view. A struct or array is indicated by a ">".

There are three different ways to send an argument of an RPC.

* Send with data.
  * To send an argument with data just add the information next to the arguments name.
* Send without data
  * To send an argument with an empty string, leave the field next to the argument name empty
* Don't send the argument
  * To disable the argument from being included in the RPC touch the arguments name. The argument will be grayed out and not included in the request. (See example below)


<img src="/ReadmeFiles/EnabledDisabled.png" width=200px>

> mainField1 will not be included in the RPC Request, but mainField2 will be included with an empty string.

Required data will have a red asterisks next to the argument name.

If more information about an argument is provided by the Mobile_API, you can tap and hold the argument name to reveal this information.

<img src="/ReadmeFiles/MainField.png" width=200px>

### Modules

Modules are designed to allow for developers to create more advanced testing. This could be using a combination of multiple RPCs, or requires usage of some Proxy's capabilities not provided from the RPCs tab, because they are not provided in the Spec.

#### Building New Modules
There are a few requirements for building Modules.

##### Modules Must:

1. Be subclasses of `RBModuleViewController`, and all class functions labeled as **Required** must be overridden.
  - These properties will allow other developers to easily understand what the Module will be testing, and will also include the iOS version required in order to use it.
  - Any Module with an iOS version other than 6 as the requirement will be listed.
  - Although other class functions such as `moduleImageName`/`moduleImage` are optional, it is encouraged to add these.

3. Use the provided `SDLProxy`, `SDLManager`, and `RBSettingsManager` that are provided to subclasses of `RBModuleViewController`.

4. Be added to the `Modules.storyboard` storyboard in order to correctly load.
  - When designing your view controller, be sure to use 8px for the vertical and horizontal displacement between views so we have a consistent experience.

5. Not interact with any other Module.

6. Be added to `RBModuleViewController`'s class function `moduleClassNames`. The new Module should added to this list as their Module name falls alphabetically with all other Modules. For an example of how to add this see below:

```
+ (NSArray*)moduleClassNames {
    if (!moduleClassNames) {
        moduleClassNames = @[
                             [RBStreamingModuleViewController classString],  // Streaming
                             [RBNewModuleViewController classString]  // Module Name
                             ];
    }
    return moduleClassNames;
}
```

### Console Log

<img src="/ReadmeFiles/Console.png" width=200px>

The console log shows a simple output of received responses or notifications.

The logs are color coded to quickly identify the types sent.
* White
  * Used for logs with no additional data.
* Blue
  * Used for requests sent to Core.
* Green
  * Used for responses from Core.
* Yellow
  * Used for notifications sent from Core.

Tapping on items in the console will reveal the JSON associated with that item, if applicable.

<img src="/ReadmeFiles/Console-RAI.png" width=200px>

### A Special Note about Putfile
Putfile is the RPC responsible for sending binary data from our mobile libraries to core. This application provides support for adding any type of file; either from the Camera roll (for images) or iTunes shared storage for any other files. Similar to adding custom RPC Spec files, any file located within the `BulkData` directory will be present in Local Storage and be usable for upload.

## Need Help?
If you need general assistance, or have other questions, you can [sign up](http://slack.smartdevicelink.org/) for the [SDL Slack](https://smartdevicelink.slack.com/) and chat with other developers and the maintainers of the project.

## Found a Bug?
If you see a bug, feel free to [post an issue](https://github.com/smartdevicelink/rpc_builder_app_ios/issues/new). Please see the [contribution guidelines](https://github.com/smartdevicelink/rpc_builder_app_ios/blob/master/CONTRIBUTING.md) before proceeding.

## Want to Help?
If you want to help add more features, please [file a pull request](https://github.com/smartdevicelink/rpc_builder_app_ios/compare). Please see the [contribution guidelines](https://github.com/smartdevicelink/rpc_builder_app_ios/blob/master/CONTRIBUTING.md) before proceeding.

## Contributors
#### Alex Muller - [Github](https://github.com/asm09fsu)
Lead Developer and Designer, UI/UX Development, Architecture Design

#### Casey Feldman - [Github](https://github.com/ligerxx) | [Dribbble](https://dribbble.com/ligerxx) | [Web](http://www.caseyfeldman.me)
Lead Visual Design, UI/UX Development

#### Timur Pulathaneli - [Github](https://github.com/tpulatha)
Architecture Design, UI/UX Development

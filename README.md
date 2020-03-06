# Zapp Android Platform

Printing Android Apps in a Zapp via [Zapp CMS](https://zapp.applicaster.com)

## Useful Links

- Helper scripts to make your life easier: https://github.com/applicaster/ScriptTools-Android

## Prerequisites

1. Android Environment installed.

## Initial Setup:

Running the App requires Ruby and Node.js installation, if it is already installed skip to the next step.

### Ruby installation:

In order to install Ruby, we recommend to simply install it through [Homebrew](https://brew.sh/).

Once Homebrew is correctly setup, in the command line run the following:

1. `brew install rbenv`

2. `brew install ruby-build`

3. `brew install imagemagick`

After cloning the repository, in the repository directory, run the following commands:

1. `rbenv install 2.5.1` (minimum required)

2. `gem install bundler -v 1.17.3`

3. `bundle install`

### Node.js installation:

In the command line run the following:

1. `brew install nvm`

2. `nvm install 12.16.1`

## Prepare App for local build

Before you can start building the application locally in your computer, there a few steps required in order to do so.

### Set the environmental variables

In order to build the application successfully, you will need to setup certain environmental variables. There are 3 different variables that are required in order to successfuly build the application locally:

`ZAPP_TOKEN`

`BINTRAY_USER`

`BINTRAY_API_KEY`

**_IMPORTAT NOTE_** - **Mac OS** users have a little bit of pain to suffer here. The normal way to setup this variables would be to set them up in your `.bash_profile` or `.zshrc` files. The problem is that Mac OS has a restriction in which GUI application's can't have access directly to your env variables setup there, therefore Android Studio won't have access to your maven credentials when trying to build the app with Gradle, making it impossible to pull the required dependencies. In order to solve this issue, a couple of options are avaiable. Refer to this [Mac OS and Enviromental variables issues](https://github.com/applicaster/Zapp-Android/wiki/Mac-OS-and-environmental-variables-issues) page for more info.

#### Create a new personal `ZAPP_TOKEN`

Set `ZAPP_TOKEN` environment variable. In case you don't have an access token just yet, follow these steps:

1. Login to [Accounts](https://accounts.applicaster.com/).

2. On the top bar, click in **Users** section.

3. Once inside the **Users** section, on the right hand side you will find a Filters box. Under the email field, enter your Applicaster's email in order to find your own user.

4. Click in the **info** button under the column **Actions**.

5. Under the section **Access Tokens**, simply click the **Add** button.

6. Give your new token an amazing name and create it.

7. Finally, inside the token list, find your newly created token and press the "info" button to reveal it.

#### Set Up Bintray Variables

Bintray credentials enable the build to pull dependencies from Maven.

1. Add `BINTRAY_USER` and `BINTRAY_API_KEY` entries to your environment. BINTRAY_API_KEY can be obtained on [Account page](https://bintray.com/profile/edit)
2. Contact a developer to obtain Applicaster credentials for the above entries.

### Setup Application's Build Parameters

Remember, as **Zapp-Android** is just a shell project which collects and compiles all the information required to build an application, before you can actually start build your application, we need to tell **Zapp-Android** certain configuration details about the application we are about to build.

There are 2 possible ways to actually do this:

#### Option 1 - Setup manually the .env file

The .env file, is just a configuration file which contains all the useful information your app requires in order to be assembled, configured and built by our rake scripts. In order to set this .env properly for the application (and versions of the application) you are trying to build, you can follow this steps:

1. Login to [Zapp](https://zapp.applicaster.com)

2. Search for an app in the filter search box.

3. Click on the app in the results to select it.

4. Click on the menu dropdown for the version you are interested in and select **Info**.

5. On the Info Screen, click on **Reveal Build Parameters**.

6. Copy and paste parameter keys and values into the project's .env file located in the root folder.

#### Option 2 - Include the application version id in the rake command

In this case, instead of manually having to follow the steps required in the section above, you can provide Rake the **version id** of the application/version you are trying to build.

```bash
bundle exec rake prepare_workspace VERSION=cb74ad9b-1b6b-4c92-8a29-fe61625242ba
```

**NOTE:** Remember, that **VERSION** is not the semantic versioning number (e.g. 1.0.3) but actually the hash unique identifier of a specific combination of application/build. (e.g. cb74ad9b-1b6b-4c92-8a29-fe61625242ba)

**PRO TIP:** Follow steps 1 to 3 from the section above. Once you are in the screen with all the builds information, click on the application version number (e.g. 1.0.3) under the **Version** column and the **VERSION** id will appear.

## Prepare workspace for local development

The following steps will "mimic" the behaviour that is happening when pressing the `Build version` in Zapp CMS. It will generate the app code using Maven dependencies with relevant data from Zapp.
Run either `rake prepare_workspace VERSION=<App-Version-ID-as-defined-in-zapp-cms>` or `rake prepare_workspace` depending if you have setup the .env file yourself or not.

## Building the project

After preparing the workspace, run `./gradlew assembleDebug` or run project in Android Studio

### Cleaning workspace

Running `rake clean` will remove all files added in the zapp build process(assets, styles, json files, etc..)
Enjoy coding!

### Contributing

1. Create your feature branch (git checkout -b my-new-feature)
2. Commit your changes (git commit -am 'Add some feature')
3. Push to the branch (git push origin my-new-feature)
4. Create new Pull Request
5. Run `bundle exec rake` to make sure all building scripts are passing
6. Run Android tests.

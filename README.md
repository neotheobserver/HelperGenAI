# HelperGenAI

Flutter based app that uses gemini api to aid people through description of images.

It is designed such that users can upload multiple images either by capturing or selecting from gallery and ask questions.

The text questions is optional. If the optional question is not asked an default question will be used.

Currently 3 languages are supported. Nepali (Default), English, and Hindi

## Getting Started

Api Key for Gemini is required. Get [Here for Free](https://ai.google.dev/aistudio)

### Option 1 (Easiest)

Download the apk from the release section. Only android users are able to do this.

Apple users must follow Option 2 and also they might have to add certain permissions and stuff. I have not done anything specific for iphone but flutter being flutter it should not be hard to get it running on apple devices as well.

### Option 2

Download the source code and build by self

This option requires flutter sdk and android studio installed on the system to build. [Install Flutter](https://docs.flutter.dev/get-started/install)

After Setting up everything run

1. `git clone https://github.com/neotheobserver/HelperGenAI.git`

2. `cd HelperGenAi`

3. `flutter pub get`

4. Either `flutter run` or `flutter build`

# auth_code_view

A new Flutter package project.

## Getting Started

This project is a starting point for a Dart
[package](https://flutter.dev/developing-packages/),
a library module containing code that can be shared easily across
multiple Flutter or Dart projects.

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

TO USE IN WEB PLACE THIS IN THE WEB FOLDER
```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <title>Sign In Succeeded</title>
    <meta
      name="description"
      content="Simple, quick, standalone responsive placeholder without any additional resources"
    />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
  </head>

  <body></body>
  <script>
    window.opener.postMessage(
      {
        type: "callback",
        url: window.location.href,
      },
      "*"
    );
  </script>
</html>
```

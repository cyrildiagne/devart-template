chrome.app.runtime.onLaunched.addListener(function() {
  chrome.app.window.create('temp/app.html', {
    id: "mainwin",
    state: "fullscreen",
    alwaysOnTop: true
  });
});
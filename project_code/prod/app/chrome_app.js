chrome.app.runtime.onLaunched.addListener(function() {
  chrome.app.window.create('temp/app.html', {
    id: "mainwin",
    bounds: {
      width: 400,
      height: 640
    }
  });
});
chrome.app.runtime.onLaunched.addListener(function() {
  chrome.app.window.create('bin/index.html', {
    id: "mainwin",
    bounds: {
      width: 640,
      height: 480
    }
  });
});
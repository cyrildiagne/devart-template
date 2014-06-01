iframe = document.getElementById "frame"
currScene = "1401061237730_018304_birds"

window.onmessage = (e) ->
  if e.data=="ready"
    iframe.contentWindow.postMessage currScene, '*'
  else
    iframe.src = "main.html"
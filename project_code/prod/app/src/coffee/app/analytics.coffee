# ((i, s, o, g, r, a, m) ->
#   i["GoogleAnalyticsObject"] = r
#   i[r] = i[r] or ->
#     (i[r].q = i[r].q or []).push arguments
#     return

#   i[r].l = 1 * new Date()

#   a = s.createElement(o)
#   m = s.getElementsByTagName(o)[0]

#   a.async = 1
#   a.src = g
#   m.parentNode.insertBefore a, m
#   return
# ) window, document, "script", "https://ssl.google-analytics.com/ga.js", "ga"
# ga "create", "UA-51930218-1", "devartmrkalia.com"
# ga "send", "pageview"

# Initialize the Analytics service object with the name of your app.
service = analytics.getService("devartmrkalia.com")
# service.getConfig().addCallback initAnalyticsConfig

# Get a Tracker using your Google Analytics app Tracking ID.
tracker = service.getTracker("UA-51930218-1")

# Record an "appView" each time the user launches your app or goes to a new
# screen within the app.
# tracker.send "pageview"
# console.log tracker
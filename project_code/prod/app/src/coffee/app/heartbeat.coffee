class Heartbeat
  constructor : ->
    setInterval @sendHeartbeat, 45 * 1000
  sendHeartbeat : ->
    $.get 'http://localhost:8083'
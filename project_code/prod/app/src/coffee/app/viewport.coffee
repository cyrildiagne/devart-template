# (function(){
#   var ua = navigator.userAgent.toLowerCase();
#   if (ua.indexOf('iphone') > -1 || (ua.indexOf('android') > -1 && ua.indexOf('mobile') > -1)) {
#     document.write('<meta name="viewport" content="initial-scale=1.0,maximum-scale=1.0,user-scalable=no"' + ' />');
#   }
# })();

(->
  ua = navigator.userAgent.toLowerCase()
  if ua.indexOf("iphone") > -1 or (ua.indexOf("android") > -1 and ua.indexOf("mobile") > -1)
    document.write "<meta name=\"viewport\" content=\"initial-scale=1.0,maximum-scale=1.0,user-scalable=no\"" + " />" 
  return
)()
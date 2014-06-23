setInterval(function(){
  window.location.href = "/last";
}, 10000);

$(function(){
  var $date = $('.last_scene .date');
  var mmt = moment( $date.data('date') );
  var refresh = function() { $date.html( 'recorded ' + mmt.fromNow() ); };
  setTimeout(refresh,1000);
  refresh();
});
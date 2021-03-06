var mmt = null;
var $date = null;

function updateDate() {
  $date.html( 'recorded ' + mmt.fromNow() );
}

setInterval(function(){
  $.ajax({
    url: "/last?json=true"
  }).done(function(res) {
    data = null;
    try {
      data = JSON.parse(res);
    } catch(err) {
      console.log(err);
    }
    if(data) {
      $('a').attr('href', 'http://goo.gl/'+data.urlId);
      $('a').find('span').html(data.urlId);
      mmt = moment( data.date );
      updateDate();
      $('img').attr('src', '/last/m11/'+data.m11+'.svg');
    }
  });
}, 5000);

$(function(){
  $date = $('.last_scene .date');
  mmt = moment( $date.data('date') );
  setInterval(updateDate, 5000);
  updateDate();
});
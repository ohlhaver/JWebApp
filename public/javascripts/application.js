// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
function showMouseOvers( event ){
  event = event || window.event;
  showMouseOverData( event, '.mo_icon', 'inline' );
  showMouseOverData( event, '.mo_menu', 'block' );
}
function hideMouseOvers( event ){
  event = event || window.event;
  hideMouseOverData( event, '.mo_icon' );
  hideMouseOverData( event, '.mo_menu' );
}

function showMouseOverData(event, class_name, display_style ){
  event = event || window.event;
  var target = event.findElement( 'span'+ class_name + '_event_src' );
  if( target ) { 
    var element = target.getElementsBySelector( class_name ).first();
    if( element ) element.setStyle({display:display_style});
  }
}
function hideMouseOverData(event, class_name ) {
  event = event || window.event;
  var target = event.findElement( 'span'+ class_name + '_event_src' );
  if( target ) {
    var element = target.getElementsBySelector( class_name ).first();
    if( element ) element.setStyle({display:'none'});
  }
}

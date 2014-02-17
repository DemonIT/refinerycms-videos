/**
 * Created by demon on 10.02.14.
 */


$(document).ready(function(){

    if ( (window!=window.top) && ($('.video-js').length > 0) ) {
        parent.$('.ui-dialog').find('button[title=close]').bind('click', function(){
            parent.$('iframe.ui-dialog-content').remove();
        })
    }

    if ( $('.video-js > object').length > 0 ){
        $('.vjs-big-play-button').hide();
        $('.vjs-control-bar').show();


    }
    $.each($('.vjs-big-play-button'), function(i, obj){

        var obj_parent = $(obj).parents('.video-js')[0];
        if (obj_parent != undefined) {
            obj.style.display ='block';
            var MyHeight = obj_parent.offsetHeight/2 - (obj.offsetHeight)/2;
            var MyWidth = obj_parent.offsetWidth/2 - (obj.offsetWidth)/2;
            obj.style.top = MyHeight + "px";
            obj.style.left = MyWidth + "px";
        }
    });

})

function centerVJSBigPlayButton(){
    $.each($('.vjs-big-play-button'), function(i, obj){

        var obj_parent = $(obj).parents('.video-js')[0];
        if (obj_parent != undefined) {
            var MyHeight = obj_parent.offsetHeight/2 - (obj.offsetHeight)/2;
            var MyWidth = obj_parent.offsetWidth/2 - (obj.offsetWidth)/2;
            obj.style.top = MyHeight + "px";
            obj.style.left = MyWidth + "px";
            obj.style.display='';
        }
    });
}

window.onload = function(){
    centerVJSBigPlayButton() ;
}
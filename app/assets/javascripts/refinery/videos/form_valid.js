/**
 * Created by demon on 15.02.14.
 */

function showErrorFlash(error_div_id) {
    $('#'+error_div_id).css({'width': 'auto', 'visibility': ''}).fadeIn(550);
}

function alertDiv(divID){
    $('#'+divID).addClass('divAlert');
}

function inputFileIsBig(input_id){
    showErrorFlash('file_big_size');
    alertDiv(input_id);

}

function bindMediaFormSubmit(mediaID){
    $('#'+mediaID +'_file').bind('change', function(){
        $('#upload_file_is_null').hide();
        $('#'+this.id).removeClass('divAlert');
        if(this.files.length > 0) {
            if(this.files[0].size > $('#'+this.id).attr('filesizelimit')) inputFileIsBig(this.id);
            else if($('#'+mediaID +'_title').val() == '') $('#'+mediaID +'_title').val(this.files[0].name);
        }
    }) ;
    $('#new_'+mediaID +'').bind('submit', function(){
        error_valid_result = 0;
        $.each($(this).find('input[type=file]'), function(i, input_obj){
            if(input_obj.attributes['require'] != undefined){
                if (input_obj.files.length == 0) {
                    showErrorFlash('upload_file_is_null');
                    alertDiv(''+mediaID +'_file');
                    $('.save-loader').hide();
                    error_valid_result = 1;
                } else if(this.elements[mediaID+'_file'].files[0].size > $('#'+mediaID +'_file').attr('filesizelimit')){
                    inputFileIsBig(this.id);
                    $('.save-loader').hide();
                    error_valid_result = 1;
                }
            }
        });
        if (error_valid_result > 0) return false; else return true;
    })

}

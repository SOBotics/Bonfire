$(document).ready(function() {
    $(".skip-link").on("click", function(ev) {
        console.log("CLICKED");
        var questionId = $(this).data("questionid");
        var review_action_name = $(this).data("raction");
        var $post = $(this).parent().parent();
        var postId = $post.data("post-id");
        $.ajax({
            'type': 'POST',
            'url': '/review/create',
            'data': {
                'question_id': questionId,
                'review_action': review_action_name
            }
        })
        .done(function(data) {
            $.ajax({
                'type': 'GET',
                'url': '/review/' + postId + '/next'
            })
            .done(function(data) {
                window.location.href = window.location.href.replace(postId, data['next_id'])
            })
            .error(function(xhr, status, error) {
                bonfire.createNotification('danger', JSON.parse(xhr.responseText)['error_message'], $(".skip-link"))
            });
        })
        .error(function(xhr, status, error) {
            bonfire.createNotification('danger', JSON.parse(xhr.responseText)['error_message'], $(".skip-link"))
        });
    }) 
});

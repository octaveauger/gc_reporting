$(function () {
  // Initialise tooltips
  $('[data-toggle="tooltip"]').tooltip();

  // Refresh the syncing loader
  autorefresh_sync_loader();

  // Calls the customer modal via ajax
  $('.modal-link[data-target="#customer-modal"]').on('click', function(e) {
  	$('#customer-modal').find('.modal-content').load($(this).attr('data-path'));
  });

  // Trigger get actions via Ajax (e.g cancel mandate)
  $('a[data-role="ajax-get"]').on('click', function(e) {
  	e.preventDefault();
  	$.getScript($(this).attr('data-target'));
  });
});

function autorefresh_sync_loader() {
  if($('#data-syncing-loader').size() > 0) {
    setTimeout(function() {
      $.ajax({
        type: "GET",
        url: $('#data-syncing-loader').attr('data-target'),
        dataType: 'json',
        success: function(data){
          if(data.is_synced) {
            window.location.reload(true);
          }
        }
      });
      autorefresh_sync_loader(); // create loop
    }, 5000); // every 5s
  }
}
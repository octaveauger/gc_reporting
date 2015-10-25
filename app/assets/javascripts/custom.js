$(function () {
  // Initialise tooltips
  $('[data-toggle="tooltip"]').tooltip();

  // Calls the customer modal via ajax
  $('.modal-link[data-target="#customer-modal"]').on('click', function(e) {
  	$('#customer-modal').find('.modal-content').load($(this).attr('data-path'));
  });
});
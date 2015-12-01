$(function () {
	// Update payment useful data in refunds form
	if($('#refund_request_payment_id').size() > 0) {
		$('#refund_request_payment_id').on('change', function(e) {
			payment_url = $('#refund_request_payment_id').attr('target') + $(this).val() + '.json';
			$.ajax({
				type: "GET",
				url: payment_url,
				dataType: 'json',
				success: function(data){
					if(data.currency) {
						$('#payment_currency').html(data.currency);
					}
					if(data.payment_max_refund) {
						$('#payment_max_refund').html(data.payment_max_refund / 100);
					}
				}
			});
		});
	}
});
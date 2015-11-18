$(document).ready(function(){
	$('#search-go').on('click', function(){
		var item = $('#search-item').val()

		var request = $.ajax({
			method: 'GET',
			url: 'http://svcs.ebay.com/services/search/FindingService/v1',
			headers: {
				'Access-Control-Allow-Origin': '*'
			},
			data: {
				'OPERATION-NAME': 'findItemsByKeywords',
				'SERVICE-VERSION': '1.0.0',
				'SECURITY-APPNAME': 'PriceApp-6d57-4fa0-bd01-63c74270c501',
				'GLOBAL-ID': 'EBAY-US',
				'RESPONSE-DATA-FORMAT': 'JSON',
				'callback': '_cb_findItemsByKeywords',
				'keywords': item
			}
		});

		request.done(function(response){
			$('.results').text(response);
		});

		request.fail(function(response){
			alert('Error: ' + response);
		})
	});
});
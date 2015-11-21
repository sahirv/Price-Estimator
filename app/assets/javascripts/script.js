$(document).ready(function(){
	$('#search-go').on('click', function(){
		var item = $('#search-item').val()

		var request = $.ajax({
			method: 'GET',
			url: 'http://svcs.ebay.com/services/search/FindingService/v1',
			dataType: 'jsonp',
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
			_cb_findItemsByKeywords(response);
			console.log(response);
		});

		request.fail(function(response){
			alert('Error: ' + response);
		})
	});
});

function _cb_findItemsByKeywords(root)
{
    var items = root.findItemsByKeywordsResponse[0].searchResult[0].item || [];
    var priceArray = []
    for (var i = 0; i < items.length; ++i) {
      var item = items[i];
      priceArray.push(item.sellingStatus[0].currentPrice[0].__value__);
    }

  
    $("#priceArray").val(JSON.stringify(items));
    $("#searchButton").click();
}
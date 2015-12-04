"use strict";
/* Put everything in a closure to avoid leaked global variables (with help of "use script" */
(function(exports) {

    // variables global to this closure
    var map;
    var marker;


    /**
     * Called when loading course new/edit view (but not the "show" one).
     * we have to export it for this purpose.
     */
    exports.gmap_initialize = function() {

        var mapOptions = {
            center: new google.maps.LatLng(30.055487, 31.279766),  // default center
            zoom: 8,
            mapTypeId: google.maps.MapTypeId.NORMAL,
            panControl: true,
            scaleControl: false,
            streetViewControl: true,
            overviewMapControl: true
        };
        // initializing map
        map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions);

        // set location data from model if it is already set
        var lat = parseFloat($('#course_latitude').val());
        var long = parseFloat($('#course_longitude').val());
        if ($.isNumeric(lat) && $.isNumeric(long)) {
            var location = new google.maps.LatLng(lat, long);
            map.setCenter(location);
            marker = new google.maps.Marker({
                map: map,
                position: location
            });
        }

        // geocoding
        var geocoding = new google.maps.Geocoder();
        $("#submit_button_geocoding").click(function () {
            codeAddress(geocoding);
        });

    };


    function codeAddress(geocoding) {
        var address = $("#search_box_geocoding").val();
        if (address.length > 0) {
            geocoding.geocode({'address': address}, function (results, status) {
                if (status == google.maps.GeocoderStatus.OK) {
                    map.setCenter(results[0].geometry.location);
                    if (!marker) {
                        marker = new google.maps.Marker({map: map});
                    }
                    marker.setPosition(results[0].geometry.location);
                    var coo = results[0].geometry.location;
                    var lat = ('' + coo).split(',')[0].split('(')[1];
                    var longi = ('' + coo).split(',')[1].split(')')[0];
                    $('#course_latitude').val(lat);
                    $('#course_longitude').val(longi);
                    $('#course_address').val(address);

                } else {
                    alert("Geocode was not successful for the following reason: " + status);
                }
            });
        } else {
            alert("Search field can't be blank");
        }
    }

})(window)
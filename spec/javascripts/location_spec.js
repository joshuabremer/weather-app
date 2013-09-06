describe("Location Model", function() {
  it("location returns error when a bad address is used", function() {
    spyOn( $, 'ajax' ).andCallFake( function (params) { 
      params.success({results:[],status:"ZERO RESULTS"});    
    });
    locationdata = new LocationModel();
    locationdata.updateAddress('9123123127213', function() {
      expect(locationdata.get('locationString')).toBe(undefined);
    })
  });

  it("location returns lat and long when a good address is used", function() {
    
    var callback = jasmine.createSpy();
    
    spyOn( $, 'ajax' ).andCallFake( function (params) { 
       params.success({"results":[{"address_components":[{"long_name":"97213","short_name":"97213","types":["postal_code"]},{"long_name":"Portland","short_name":"Portland","types":["locality","political"]},{"long_name":"Multnomah","short_name":"Multnomah","types":["administrative_area_level_2","political"]},{"long_name":"Oregon","short_name":"OR","types":["administrative_area_level_1","political"]},{"long_name":"United States","short_name":"US","types":["country","political"]}],"formatted_address":"Portland, OR 97213, USA","geometry":{"bounds":{"northeast":{"lat":45.552852,"lng":-122.57867},"southwest":{"lat":45.52276089999999,"lng":-122.6229301}},"location":{"lat":45.5352835,"lng":-122.6037536},"location_type":"APPROXIMATE","viewport":{"northeast":{"lat":45.552852,"lng":-122.57867},"southwest":{"lat":45.52276089999999,"lng":-122.6229301}}},"types":["postal_code"]}],"status":"OK"});   
    });

    locationdata = new LocationModel();
    locationdata.updateAddress('9123123127213', function() {
      expect(locationdata.get('locationString')).toNotBe(undefined);
      expect(true).toBe(true);
    })

    
    
    

  });

});
# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

//= require vendor/respond
//= require jquery

# Load Backbone

//= require vendor/underscore-min
//= require vendor/backbone-min

# Loads all Bootstrap javascripts

//= require vendor/bootstrap/bootstrap.min
//= require vendor/moment
//= require vendor/spin
//= require vendor/d3.v3.min

//= require vendor/skycons



jQuery ->
  

  # Let's build our Location Model
  # Attributes:
  #   address (string, whatever people type)
  #   latlng (array of lat and lng)
  #
  class window.LocationModel extends Backbone.Model
    
    defaults:
      address:'97213'
    initialize: =>
      return
    updateAddress: (address,callBack) =>
      @.set('address',address)

      
      googleURL = "http://maps.googleapis.com/maps/api/geocode/json"
      $.getJSON googleURL,{sensor: true,address: address},(data) =>
        if data.results.length == 0
          @.trigger("geoLocateError")
          if jQuery.isFunction(callBack) then callBack()
          return
        newLatLng = 
          lat:data.results[0].geometry.location.lat
          lng:data.results[0].geometry.location.lng
        @.set('locationString',data.results[0].formatted_address)
        @.set('latlng',newLatLng)
        @.updateWeatherData()
        if jQuery.isFunction(callBack) then callBack()
        return
          
      return
    updateWeatherData: =>
      modelData = @.toJSON()
      $.getJSON "https://api.forecast.io/forecast/b4e531886cc20299182451b1cbc0b793/#{modelData.latlng.lat},#{modelData.latlng.lng}?callback=?",
      null
      ,(data) =>
        @.set('weatherData',data)
        return data
      return 
  
  # End of LocationData Model
  
  
  class window.LocationView extends Backbone.View
    model: LocationModel
    tagName: 'div'
    el: 'body'
    
    events:
      'click #submit-location': 'updateModel'

    initialize: ->

      @.model.bind("geoLocateError", @.showGeoLocateError)
      @.model.bind("change:latlng", @.renderMap)
      @.model.bind("change:weatherData", @.renderWeather)

    updateModel: =>
      $('#google-map-container').animate({opacity:0})
      $('#forecast-io-container').animate({opacity:0})
      @.model.updateAddress($('[name=location]').val())
    showGeoLocateError: =>
      $('.geolocate-error ').remove()
      $('#location-form').after('
      <p class="geolocate-error alert alert-dismissable alert-danger">
      <button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>
      <strong>Oh snap!</strong> Couldn\'t find a location based on your entry Want to try again?
      </p>')


    # This takes the latitude and longitude and appends a google map with 
    # those coordintes as the center

    renderMap: =>
      $('.geolocate-error ').fadeOut().remove()
      modelData = @.model.toJSON()
      mapOptions =
        zoom: 12
        center: new google.maps.LatLng(modelData.latlng.lat, modelData.latlng.lng)
      mapTypeId: google.maps.MapTypeId.ROADMAP
      canvasEl = document.getElementById("map-canvas")
      map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions)
      canvasEl.style.height = '200px'
      $('#google-map-container .panel-title').html("Current Location - #{modelData.locationString}")
      $('#google-map-container').animate({opacity:1})
      return

    # This renders the weather section of the app once the weather data arrives
    renderWeather: =>

      
      modelData = @.model.toJSON()
      # Build out the first panel with all the current data

      $(".current-temp").html("#{Math.round(modelData.weatherData.currently.temperature)}°F")
      $(".current-hi-temp").html("Hi: #{Math.round(modelData.weatherData.daily.data[0].temperatureMax)}°F")
      $(".current-low-temp").html("Lo: #{Math.round(modelData.weatherData.daily.data[0].temperatureMin)}°F")
      $(".current-humidity").html("Humidity: #{Math.round(modelData.weatherData.currently.humidity)}")
      $(".current-humidity").html("Chance of Rain: #{Math.round(modelData.weatherData.currently.precipProbability*100)}%")
      $(".current-weather-description").html("#{modelData.weatherData.currently.summary}")

      # Now let's build out the minute by minute chart
      @.renderWeatherMinuteChart()

      # After all this is done, fade it in
      $('#forecast-io-container').animate({opacity:1})
    
    renderWeatherMinuteChart: =>
      modelData = @.model.toJSON()

      # First build the pretty skycon for the weather and initialize the animation
      skycons = new Skycons(color: "#333")
      skycons.add "current-weather-icon", @.getSkyCon()
      skycons.play()
        
      

      # D3 Visualization of the minute weather

      # For countries with less weather data, they don't get minute-by-minute data, 
      # so show a message if that's the case.
      $("#weather-by-minute-chart").html('')
      if modelData.weatherData.minutely? == false
        $("#weather-by-minute-chart").html('There is no minute-by-minute data for this location.')
        return


      # Let's build our line data. For each minute, push the precipitation probability
      lineData = []
      lineData.push 100*minute.precipProbability for minute,i in modelData.weatherData.minutely.data
      data = lineData

      # Now let's build our SVG
      w = 600
      h = 200
      margin = 40
      y = d3.scale.linear().domain([0, 100]).range([0 + margin, h - margin])
      x = d3.scale.linear().domain([0, data.length]).range([0 + margin, w - margin])
      vis = d3.select("#weather-by-minute-chart").append("svg:svg").attr("width", w).attr("height", h)
      g = vis.append("svg:g").attr("transform", "translate(0, 200)")
      line = d3.svg.line().interpolate("monotone").x((d, i) ->
        x i
      ).y((d) ->
        -1 * y(d)
      )
      g.append("svg:path").attr "d", line(data)
      g.append("svg:line").attr("x1", x(0)).attr("y1", -1 * y(0)).attr("x2", x(w)).attr "y2", -1 * y(0)
      g.append("svg:line").attr("x1", x(0)).attr("y1", -1 * y(0)).attr("x2", x(0)).attr "y2", -1.7 * 100

      # X Labels
      g.selectAll(".xLabel").data(x.ticks(5)).enter().append("svg:text").attr("class", "xLabel").text((d) ->
        moment().add('minutes', d).format("h:mm a")
      ).attr("x", (d) ->
        x d
      ).attr("y", 0).attr "text-anchor", "middle"
      
      # Y Labels 
      g.selectAll(".yLabel").data(y.ticks(4)).enter().append("svg:text").attr("class", "yLabel").text((d) ->
        d + '%'
      ).attr("x", 0).attr("y", (d) ->
        -1 * y(d)
      ).attr("text-anchor", "right").attr "dy", 4

      # X Ticks
      g.selectAll(".xTicks").data(x.ticks(5)).enter().append("svg:line").attr("class", "xTicks").attr("x1", (d) ->
        x d
      ).attr("y1", -1 * y(0)).attr("x2", (d) ->
        x d
      ).attr "y2", -1 * y(-0.3)

      # Y Ticks
      g.selectAll(".yTicks").data(y.ticks(4)).enter().append("svg:line").attr("class", "yTicks").attr("y1", (d) ->
        -1 * y(d)
      ).attr("x1", x(-0.3)).attr("y2", (d) ->
        -1 * y(d)
      ).attr "x2", x(0)


      
    # All those labels that we generate are fun, but forecast.io doesn't give us back
    # the right string, we need to convert them
    # http://darkskyapp.github.io/skycons/
    getSkyCon: ->
      modelData = @.model.toJSON()
      switch modelData.weatherData.currently.icon
        when "rain" then Skycons.RAIN
        when "snow" then Skycons.SNOW
        when "sleet" then Skycons.SLEET
        when "hail" then Skycons.SLEET
        when "wind" then Skycons.WIND
        when "fog" then Skycons.FOG
        when "cloudy" then Skycons.CLOUDY
        when "partly-cloudy-day" then Skycons.PARTLY_CLOUDY_DAY
        when "partly-cloudy-night" then Skycons.PARTLY_CLOUDY_NIGHT
        when "clear-day" then Skycons.CLEAR_DAY
        when "clear-night" then Skycons.CLEAR_NIGHT 
        else Skycons.CLOUDY
    
  # End of LocationView View
  

  initializeApp = ->
    location_model = new LocationModel({address:'97213'})
    location_view = new LocationView({model: location_model})

    # We're just going to initialize the application with some dummy Portland data
    $("#submit-location").click()
    # Binding the Enter button
    $("#location-input").keyup (e) ->
      $("#submit-location").click()  if e.keyCode is 13
    return

  # Start the app once the Google Maps API has been loaded

  google.maps.event.addDomListener window, "load", initializeApp
  


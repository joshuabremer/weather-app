# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

//= require vendor/respond
//= require jquery

# Loads all Bootstrap javascripts

//= require vendor/bootstrap/bootstrap.min
//= require vendor/bootstrap/bootstrap.calendar
//= require vendor/moment
//= require vendor/spin
//= require vendor/d3.v3.min
//= require vendor/skycons



$(document).ready ->


  # SVG Fallback
  (->
    unless Modernizr.svg
      $("img[src*=\"svg\"]").attr "src", ->
        $(this).attr("src").replace ".svg", ".png"
  )()
  return


# Form Handler
(->
  initialize = ->
    $("#submit-location").click ->
      # Get Google Address
      location = $('[name=location]').val()
      objLatLong = _getLatLong location,(geoObj) ->
        console.log(geoObj)
        _buildGoogleMap(geoObj.results[0].geometry.location.lat,geoObj.results[0].geometry.location.lng)
        _buildWeather(geoObj.results[0].geometry.location.lat,geoObj.results[0].geometry.location.lng)
        return
      return
    $("#submit-location").click()
    return
  map = undefined
  google.maps.event.addDomListener window, "load", initialize


  _buildGoogleMap = (lat,lng) ->

    mapOptions =
      zoom: 12
      center: new google.maps.LatLng(lat, lng)
      mapTypeId: google.maps.MapTypeId.ROADMAP
    canvasEl = document.getElementById("map-canvas")
    map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions)
    canvasEl.style.height = '200px'
    return
      
  _getLatLong = (address,callBack) ->
    $.getJSON "http://maps.googleapis.com/maps/api/geocode/json",
      sensor: true
      address: address
    , (data) ->
      callBack(data)
      return data

    return


  _buildWeather = (lat,lng) ->
    $.getJSON "https://api.forecast.io/forecast/b4e531886cc20299182451b1cbc0b793/#{lat},#{lng}?callback=?",
    null
    ,(data) ->
      _displayWeather(data)
      return data
    return

  _skycon_type = (icon) ->
    switch icon
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
  

  _displayWeather = (weatherData) ->
    console.log weatherData
    $(".current-temp").html("#{Math.round(weatherData.currently.temperature)}°F")
    $(".current-hi-temp").html("Hi: #{Math.round(weatherData.daily.data[0].temperatureMax)}°F")
    $(".current-low-temp").html("Lo: #{Math.round(weatherData.daily.data[0].temperatureMin)}°F")
    skycons = new Skycons(color: "#333")
    skycons.add "current-weather-icon", _skycon_type(weatherData.minutely.icon)
    skycons.play()


    # D3 Visualization
    #data = []
   
    console.log "minutely",weatherData.minutely
    console.log data
    
    w = 300
    h = 100
    $("#weather-by-minute-chart").html('')
    svg = d3.select("#weather-by-minute-chart").append("svg").attr("width", w).attr("height", h)

    # make some fake data
    #[
    #  [ {minute:1, val: 0.3343}, ...],
    #  ...
    #]
    #
    line = []
    line.push {minute:i,val:minute.precipProbability} for minute,i in weatherData.minutely.data
    data = [line]
    console.log data
    x = d3.scale.linear().domain([0, 60]).range([0, w])
    y = d3.scale.linear().domain([1, 0]).range([0, h])
    line = d3.svg.line().interpolate("basis").x((d) ->
      x d.minute
    ).y((d) ->
      y d.val
    )
    group = svg.selectAll("path").data(data).enter().append("path").attr("d", line)
    return
  return

  


)()


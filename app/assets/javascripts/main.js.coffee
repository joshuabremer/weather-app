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
    $("#submit-location").click (evt)->
      evt.preventDefault()
      evt.stopPropagation()
      $('.fade-elements').animate({opacity:0})
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
    $('#google-map-container').animate({opacity:1})
    return
      
  _getLatLong = (address,callBack) ->
    $.getJSON "http://maps.googleapis.com/maps/api/geocode/json",
      sensor: true
      address: address
    , (data) ->
      callBack data
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

    $(".current-humidity").html("Humidity: #{Math.round(weatherData.currently.humidity)}")
    $(".current-humidity").html("Chance of Rain: #{Math.round(weatherData.currently.precipProbability*100)}%")
    $(".current-weather-description").html("#{weatherData.minutely.summary}")
    
    skycons = new Skycons(color: "#333")
    skycons.add "current-weather-icon", _skycon_type(weatherData.minutely.icon)
    skycons.play()
      
    # D3 Visualization
   
    console.log "minutely",weatherData.minutely
    
    
    $("#weather-by-minute-chart").html('')
    
    lineData = []
    lineData.push 100*minute.precipProbability for minute,i in weatherData.minutely.data

    # data = [3, 6, 2, 7, 5, 2, 1, 3, 8, 9, 2, 5, 7]
    data = lineData
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
    g.append("svg:line").attr("x1", x(0)).attr("y1", -1 * y(0)).attr("x2", x(0)).attr "y2", -1 * 100

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


    $('#forecast-io-container').animate({opacity:1})


    return
  return

  


)()


# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

//= require vendor/respond
//= require vendor/retina
//= require jquery
//= require jquery_ujs

# Loads all Bootstrap javascripts

//= require vendor/bootstrap/bootstrap.min
//= require vendor/bootstrap/bootstrap.calendar
//= require vendor/moment
//= require vendor/spin
//= require vendor/jquery.scrollTo



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
      console.log data
      return data

    return




  return

  


)()


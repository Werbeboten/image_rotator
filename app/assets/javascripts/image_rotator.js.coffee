# Class for _animating a sprite image, including easing and blur
class @ImageRotator
#public functions

  # creates new object and sets option default values, if necessary
    # @$target: target DOM element
    # @url: url to sprite image
    # @imageCnt: number of images in the sprite image
    # options: add options here
  constructor: (@$target, @url = null, @imageCnt = 1, options = {}) ->
    @options  =
      # activates blurring if true. Default: true
      blur: true                              
      # maximum threshold, reached at the half rotation (then decreasing to 0). Default: 3
      blurThreshold: 3
      # Type of easing. See http://api.jqueryui.com/easings/ for more information. Default: "easeInOutQuart"
      easing: "easeInOutQuart"
      # Speed of rotation in rotations per second. Default: 0.44
      rotationSpeed: 0.44
      # activates log messages if true. Default: false
      debug: false
      # start angle for your image. Default: 0
      startAngle: 0

      # called on each reset call.
        # rotator: ImageRotator object
      onReset: (rotator) ->
      # Called at beginning of rotation (animate_to). 
        # rotator: ImageRotator object
      onAnimateStart: (rotator) ->
      # Called at each rotation step. 
        # rotator: ImageRotator object
      onAnimateStep: (rotator) ->
      # Called at end of rotation (animate_to). 
        # rotator: ImageRotator object
      onAnimateComplete: (rotator) ->
      # called  at end of _changeCanvas function; called on EVERY change of image
        # rotator: ImageRotator object
      onCanvasChange: (rotator) ->
      # called at end of _changeBlur function
        # rotator: ImageRotator object
        # blur: current blur value
      onBlurChange: (rotator, blur) ->
      # called at end of _updateCurDeg
        # rotator: ImageRotator object
      onCurDegUpdate: (rotator) ->
    @options = $.extend( @options, options )
      
    @_init()

    if @url
      rotator = @
      @img = new Image()
      @img.onload = () ->
        rotator.canvasWidth = @width
        console.log @width  
        rotator.canvasHeight = @height / rotator.imageCnt
        rotator._setupCSS()
      console.log @url
      @img.src = @url
    else
      @canvasWidth = parseInt(@$target.css("width"))
      @canvasHeight = parseInt(@$target.css("height"))
      @_setupCSS()


  # Animates until amount of deg is reached
    # deg: amount of degrees you want to rotate the image around
  animate: (deg) =>
    @_log("animate(#{deg})")
    @animateTo(@curDeg + deg)


  # Animates until targetDeg is reached
    # targetDeg: aim degree you want to reach
  animateTo: (targetDeg) =>
    @_log("animateTo(#{targetDeg})")
    
    if @_animating
      @_log("no rotation necessary (animation in progress)")
      return 

    if targetDeg == @curDeg
      @_log("no rotation necessary (degree not changed)")
      return 

    from = {deg: @curDeg, blur: 0}
    to   = {deg: targetDeg, blur: @options.blurThreshold * 2}
    rotator = @
    duration =  @_msPerDeg * Math.abs(to.deg - from.deg)


    $(from).css("transform", "translateZ(0)").animate(to , {
      duration: duration
      easing: @options.easing
      start: ->
        rotator._animating = true
        rotator.options.onAnimateStart(rotator) 
      step: ->
        rotator.options.onAnimateStep(rotator)

        return if rotator.curDegInt == parseInt(@deg)

        rotator._changeCanvas(@deg)
        if rotator.options.blur 
          realBlur = @blur
          if realBlur > rotator.options.blurThreshold 
            realBlur = to.blur - realBlur
          rotator._changeBlur(realBlur)
      complete: ->
        rotator._log("complete")
        rotator._updateCurDeg(to.deg)
        rotator.statistics.animationDuration = duration
        rotator.statistics.totalAnimationDuration += duration
        rotator.statistics.totalDeg += to.deg
        rotator.statistics.rotationCount = parseInt(rotator.statistics.totalDeg / 360)
        rotator._animating = false
        rotator.options.onAnimateComplete(rotator)
      always: ->
        rotator._log("always")
        rotator._animating = false
    }).css("transform", "none")

  #resets the class
  reset: => 
    @_changeCanvas(@options.startAngle)
    @_init()
    @options.onReset()


#private functions

  # Initializes the object. Use this for resetting an animation!
  _init: =>
    # current degree as float number
    @curDeg = 0
    # current degree as integer number
    @curDegInt = 0
    # current degree, normalized between 0 and 360, as float number
    @curAngle = 0
    # current degree, normalized between 0 and 360, as integer number
    @curAngleInt = 0
    # number of the current drawn picture in sprite image
    @curPicNr = 0
    # width of the canvas housing the content
    @canvasWidth = 0
    # height of the canvas housing the content
    @canvasHeight = 0
    # flag which shows is animation is running 
    @_animating = false
    # duration for rotating 1 degree, in ms
    @_msPerDeg = 1000 / (@options.rotationSpeed * 360) 
    @_log("#{@_msPerDeg} ms/deg")

    # statistics for debugging and development
    @statistics = 
      # sum of all degrees since creating the object
      totalDeg: 0
      # sum of complete rotations since creating the object
      rotationCount: 0
      # duration of the last animation
      animationDuration: 0
      # sum of all animation durations
      totalAnimationDuration: 0

    @_changeCanvas(0)
    @_changeBlur(0)
    

  # sets needed css attributes for $target and adds parent div
  _setupCSS: =>
    @_log("_setupCSS")

    @$housing = $("<div />").css
      height: "#{@canvasHeight}px"
      width: "#{@canvasWidth}px"
      overflow: "hidden"
    @$target.wrap(@$housing)

    if @url
      @$target.css
        height: "#{@canvasHeight}px"
        width: "#{@canvasWidth}px"
        backgroundImage: "url(#{@url})"
        backgroundPosition: "0px 0px"

    @_changeCanvas(@options.startAngle)


  # changes css blur option of $target
    # blur: blur value 
  _changeBlur: (blur) =>
    @$target.css
      'filter'         : "blur(#{blur}px)"
      '-webkit-filter' : "blur(#{blur}px)"
      '-moz-filter'    : "blur(#{blur}px)"
      '-o-filter'      : "blur(#{blur}px)"
      '-ms-filter'     : "blur(#{blur}px)"
    @options.onBlurChange(@, blur)


  # call background update with image, calculated from degrees
    # deg: current degree 
  _changeCanvas: (deg) =>
    @_log("_changeCanvas(#{deg})")

    if(@imageCnt == 1)
      @_rotateBackground(deg)
    else
      @_positionBackground(@_degreeToImage(deg))
    @_updateCurDeg(deg)
    @options.onCanvasChange(@)


  # calculate image for current degree, depending on number of single images in your sprite image
    #deg: degree
  _degreeToImage: (deg) =>
    @_log("_degreeToImage(#{deg})")

    delta = 360.0 / @imageCnt
    angle = deg % 360
    Math.floor(angle / delta)


  # sets cur deg to given deg and calculates the angle which is normalized to a value between 0 and 359
    # deg: new degree 
  _updateCurDeg: (deg) =>
    @curDeg = deg
    @curDegInt = parseInt(@curDeg)
    @curAngle = @curDeg % 360
    @curAngleInt = parseInt(@curAngle)
    @options.onCurDegUpdate(@)


  # reposition background for $target by css
    #picNr: number of picture you want to show in sprite image
  _positionBackground: (picNr) =>
    @_log("_positionBackground(#{picNr})")

    @$target.css
      backgroundPosition: "0px #{picNr * @canvasHeight}px"
    @curPicNr = picNr  


  # rotate background if only one or no image is given
    # deg: degree to rotate around
  _rotateBackground: (deg) =>
    @_log("_rotateBackground(#{deg})")

    @$target.css('transform', "rotate(#{deg}deg)")


  # log function which shows logs if debug option is true
  _log: (message) =>
    console.log(message) if @options.debug

#TODO: 
  #3 Phases: beginning, turning, ending
#TODO: 
  #undo method um imageRotator wieder von DOM-Element zu entfernen

(($) ->
  $.fn.imageRotator = () ->
    $selector = $(this)
    key = "imageRotator"
    
    if $selector.data(key)
      rotator = window[$selector.data(key)]
      
      if $.type(arguments[0]) == "string"
        #reset
        if(arguments[0] == "reset" )
          rotator.reset()
        #animate
        else 
          num = if $.type(arguments[1]) == "number" then arguments[1] else 0
          #animate
          if(arguments[0] == "animate")
            rotator.animate(num)
          #animateTo
          else if(arguments[0] == "animateTo")
            rotator.animateTo(num)

      return rotator
    else
      value = "jquery-image-rotator-#{Number(new Date())}-#{Math.floor(Math.random()*1001)}"
      #default values which will be overwritten if available
      url = null
      imageCnt = 1
      options = {}

      # options only
      if $.type(arguments[0]) == "object" 
        options = arguments[0]
      # url
      else if $.type(arguments[0]) == "string" && (arguments[0].match(/\.(jpg|jpeg|png|gif)$/i))#ends with jpg, jpeg, png or gif
        url = arguments[0]
      # url and imageCnt
        if $.type(arguments[1]) == "number"
          imageCnt = arguments[1]
          # url, imageCnt and options
          if $.type(arguments[2]) == "object"
            options = arguments[2]
        #url and options
        else if $.type(arguments[1]) == "object"
          options = arguments[1]

      window[value] = new ImageRotator($selector, url, imageCnt, options)
      $selector.data(key, value)
      return window[value]
)(jQuery)
# ImageRotator

This is a gem for the image_rotator jQuery plugin. It allows you to rotate any html content in a DOM object. It's destined for images. You can also use it for sprite animations. The easing is selectable. Also, rotation blurring is available. The gem's purpose is to easily integrate the imageRotator plugin into your Rails app.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'image_rotator'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install image_rotator

After this, add the following line into your app/assets/javascripts/application.js:
    
    //= require image_rotator_main


## Usage

###Initialization


####Initialization for any html content

If you use "image-rotator" as class name for your images, image_rotator will automatically create an object of this class for each of them with standard argument values. 
The following example will add the image-rotator class to your div (in any view file):

  <div class="image-rotator">
    image_tag("example.jpg")
  </div>  


####Initialization params

Otherwise, you can initialize the imageRotator with some params. These params are:
 * url: Only necessary for single images or sprite animations. URL to the image.
 * imageCnt: Only necessary for sprite animations. Number of single images in the sprite image.
 * Options:
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

There are also some call functions you can use. The argument "rotator" contains the current imageRotator object. These call functions are:
       
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

 In the following example we create an ImageRotator in document ready function with motion blur of 2, rotationSpeed of 0.5 and add a custom call for onAnimateComplete, where we just set an alert:

    $ ->
      options = 
        blurThreshold: 2
        rotationSpeed: 0.5
        onAnimateComplete: (rotator) ->
          alert "Ready!"

      $("#example").imageRotator(options)


####Initialization of sprite images

As written above, we need url and imageCnt params for sprites. Here's an example for a sprite images with 10 single images inside:

    $("#example").imageRotator("example.jpg", 10)

Note: The sprites have to be ordered VERTICALLY!


###Rotating an image or html content

There are two rotation functions: "animate", which means that your image will rotate around a given angle, and "animateTo", which rotates your image until the given angle is reached. The following example will rotate the div "example" with a background image around 360 degrees if you click on it:

    <div id="example" style="background-image:url(assets/example.jpg)" onclick="this.imageRotator("animate", 360 />

In this example we use the animateTo function:
  
    <div id="example" style="background-image:url(assets/example.jpg)" onclick="this.imageRotator("animateTo", 360 />


## Contributing

1. Fork it ( https://github.com/[my-github-username]/image_rotator/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

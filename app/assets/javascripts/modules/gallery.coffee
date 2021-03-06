((win, doc, $) ->

  Gallery =

    options:
      width: 1000

    init: ->
      @els = []
      @hasOpenImage = false
      @eventListeners()

    eventListeners: ->
      App.$win.on 'debouncedresize', =>
        @onWinResize()

      App.$doc.on 'ImageChaosClick': (e, data) =>
        @onThumbClick data.$el, data.$item

    onWinResize: ->
      @positionImages() if @hasOpenImage

    onThumbClick: ($el, $item) ->
      @els.push $el
      @setup $el unless @hasInitalized $el
      @display $el.find('.gallery'), $item
      @setupClose()

    setupClose: ->
      App.$doc.on 'click.Gallery', (e) =>
        @onDocClick(e)

    onDocClick: (e) ->
      $target = $ e.target
      unless !!$target.closest('.gallery-inner').length
        @destroy()

    positionImages: ->
      _ = @

      $('.gallery').each ->
        _.positionImage $(@)

    setup: ($el) ->
      images = $el.data 'images'
      imageCredits = $el.data 'image-credits'
      imageCount = images.split(',').length
      elClass = 'gallery '
      elClass += if imageCount > 1 then 'gallery-multiple' else 'gallery-one'

      galleryHTML = App.Utils.template(
        App.Templates.gallery,
        {
          elClass: elClass
          images: images
          imageCredits: imageCredits
        }
      )

      $el.append galleryHTML
      $el.data 'hasInitalizedGallery', true
      $gallery = $el.find '.gallery'

      @setupPrevAndNextButton $gallery if imageCount > 1

    destroy: ->
      $('.gallery').remove()
      App.$doc.off 'click.Gallery'
      $el.data('hasInitalizedGallery', false) for $el in @els
      @hasOpenImage = false
      @els = []

    showGallery: ($gallery) ->
      $gallery.hide()

    display: ($gallery, $item) ->
      $imageWrapper = $gallery.find '.gallery-image-wrapper'
      $imageCredit = $gallery.find '.gallery-image-credit'

      imageSrc = $item.data 'image-large'
      imageCredit = $item.data 'image-credit'

      image = App.Utils.template(
        App.Templates.image,
        {
          src: imageSrc
          alt: '',
          class: 'gallery-image-image'
        }
      )
      imageButtons = App.Utils.template(
        App.Templates.imageButtons,
        {
          src: encodeURIComponent(imageSrc)
          credit: encodeURIComponent(imageCredit)
        }
      )

      imageAndButtons = image + imageButtons

      $imageWrapper.css 'visibility', 'none'

      $imageCredit.html imageCredit
      $imageWrapper.html imageAndButtons

      $image = $imageWrapper.find '.gallery-image-image'

      $image.imagesLoaded =>
        @positionImage $gallery

      @hasOpenImage = true

    changeImage: ($gallery, src, credit) ->
      $image = $gallery.find '.gallery-image-image'
      $credit = $gallery.find '.gallery-image-credit'
      $image.attr 'src', src
      $credit.html credit

    positionImage: ($gallery) ->
      parentWidth = $gallery.parent().width()
      windowWidth = App.$win.width()
      windowMargin = 20

      if (windowWidth - windowMargin) < @options.width
        $gallery.width(windowWidth - windowMargin)
      else
        $gallery.width(@options.width)

      $gallery.css(
        left: (parentWidth - $gallery.width()) / 2
        visibility: 'visible'
      )

    hasInitalized: ($el) ->
      !!$el.data 'hasInitalizedGallery'

    setupPrevAndNextButton: ($gallery) ->
      _ = @
      $buttons = $gallery.find '.gallery-prev, .gallery-next'

      images = $gallery.data('images').split ','
      imageCredits = $gallery.data('image-credits').split '|||'

      $buttons.click ->
        isNext = $(@).hasClass 'gallery-next'

        if isNext
          index = $gallery.data('image-index') + 1
          unless images[index]
            index = 0
        else
          index = $gallery.data('image-index') - 1
          unless images[index]
            index = images.length - 1

        $gallery.data 'image-index', index
        _.changeImage $gallery, images[index], imageCredits[index]

  win.App.Gallery = Gallery

)(window, document, jQuery)

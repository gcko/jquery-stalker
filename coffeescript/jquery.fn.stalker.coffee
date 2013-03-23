###
https://github.com/luxx/jquery-stalker
Apache 2.0 licence

Stalker is a cool jQuery transition effect plugin - when scrolled past, it attaches specified element to the top of
the screen. As you scroll past it becomes fixed, and when you scroll back beyond the element, it goes back to normal
positioning.

Usage:
jQuery("#stalker").stalker();

https://github.com/luxx/jquery-stalker

Originally part of the AJS library http://docs.atlassian.com/aui/latest/AUI/js/atlassian/jquery/, it has since been
deprecated: https://ecosystem.atlassian.net/browse/AUI-676. AJS dependency removed and released to github by Lane LaRue.
AJS and all modifications are licenced Apache 2.0: http://www.apache.org/licenses/LICENSE-2.0
###

$ = jQuery

$.fn.extend

  stalker: (options = {}) ->

    defaults = {}

    options = $.extend {}, defaults, options

    return @each () ->
      $window = jQuery(window) # jQuery wrapped window
      $document = jQuery(document) # jQuery wrapped document
      $element = $(this) # Element that will follow user scroll (Stalk)
      offsetY = undefined # offset top position of stalker
      placeholder = undefined # A div inserted as placeholder for stalker
      lastScrollPosY = undefined # Position last scrolled to
      stalkerHeight = undefined # Height of stalker
      initialized = undefined # Flag if control is initialized (onscroll)

      initialize = ->

        # need to set overflow to hidden for correct height in IE.
        getPlaceholderCss = ->
          $element.css "overflow", "hidden"
          css = $element.css [
            'height'
            'width'
            'marginTop'
            'marginBottom'
            'marginLeft'
            'marginRight'
            'paddingTop'
            'paddingBottom'
            'paddingLeft'
            'paddingRight'
            'borderTop'
            'borderBottom'
            'borderLeft'
            'borderRight'
          ]
          stalkerHeight = $element.height()
          $element.css "overflow", ""
          # Return the element css
          css = $.extend {}, css, 'visibility': 'hidden'

        # create a placeholder as our stalker bar is now fixed
        createPlaceholder = ->
          placeholder = jQuery("<div />").addClass("stalker-placeholder").css(getPlaceholderCss()).insertBefore($element)

        setPlaceholderHeight = ->
          unless $element.hasClass("detached")
            placeholder.height $element.height()
          else
            placeholder.height $element.removeClass("detached").height()
            $element.addClass "detached"

        offsetY = $element.offset().top - parseInt $element.css('marginTop')

        createPlaceholder()
        setPlaceholderHeight()

        # set calculated fixed (or absolute) position
        $element.css getInactiveProperties()

        # custom event to reset stalker placeholder height
        $element.on "stalkerHeightUpdated", setPlaceholderHeight
        $element.on "positionChanged", setStalkerPosition

        initialized = true

      getInactiveProperties = ->
        position: "fixed"
        top: offsetY - $window.scrollTop()

      setStalkerPosition = ->
        initialize() unless initialized

        if offsetY <= $window.scrollTop()
          $element.css(top: 0, position: "fixed").addClass "detached" unless $element.hasClass("detached")
        else
          $element.css(getInactiveProperties()).removeClass "detached"
        lastScrollPosY = $window.scrollTop()

      offsetPageScrolling = ->

        setScrollPostion = (scrollTarget) ->
          docHeight = jQuery.getDocHeight()
          scrollPos = undefined
          if scrollTarget >= 0 and scrollTarget <= docHeight
            scrollPos = scrollTarget
          else if scrollTarget >= $window.scrollTop()
            scrollPos = docHeight
          else scrollPos = 0  if scrollTarget < 0
          $window.scrollTop scrollPos

        pageUp = ->
          initialize()  unless initialized
          scrollTarget = jQuery(window).scrollTop() - jQuery(window).height()
          setScrollPostion scrollTarget + stalkerHeight

        pageDown = ->
          initialize()  unless initialized
          scrollTarget = jQuery(window).scrollTop() + jQuery(window).height()
          setScrollPostion scrollTarget - stalkerHeight

        jQuery ->
          $document.on "keydown keypress keyup", "pagedown", (e) ->
            pageDown()  if e.type is "keydown"
            e.preventDefault()

          $document.on "keydown keypress keyup", "pageup", (e) ->
            pageUp()  if e.type is "keydown"
            e.preventDefault()

          $document.on "keydown keypress keyup", "space", (e) ->
            pageDown()  if e.type is "keydown"
            e.preventDefault()

          $document.on "keydown keypress keyup", "shift+space", (e) ->
            pageUp()  if e.type is "keydown"
            e.preventDefault()

      offsetPageScrolling()

      # we may need to update the height of the stalker placeholder, a click event could have caused changes to stalker
      # height. This should probably be on all events but leaving at click for now for performance reasons.
      $document.on 'click', (e) ->
        initialize() if jQuery(e.target).is($element) and not initialized

      $document.on "showLayer", (e, type) ->
        # firefox needs to reset the stalker position
        setStalkerPosition()  if jQuery.browser.mozilla and type is "popup"

      # offsets perm links, and any anchor's, scroll position so they are offset under ops bar
      $element.add(".stalker-placeholder").offsetAnchors()

      $window.scroll(setStalkerPosition).resize ->
        $element.trigger "stalkerHeightUpdated" if $element

      this
class ChatClientApp
  constructor: () ->
    $client = @

    $.post '/me', (data) ->
      if data.peer?
        $client.peer = new PeerModel(data.peer)
        $client.view = new ChatClientView({model: $client.peer})

        # fetch facebook data
        $client.peer.fetchFacebookData()


class ChatClientView extends Backbone.View
  el: "#chat-view"
  template: "#chat-app-template"

  initialize: () ->
    $view = @
    @model.on 'change', () ->
      $view.render()

  render: () ->
    contents = $(@template).html()
    $view = @
    $(@el).html(contents)

    @self_video_el = $(@el).find(".self")
    @stream_video_el = $(@el).find(".stream")
    navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia;

    navigator.getUserMedia {audio: true, video: true}, (stream) ->
      $($view.self_video_el).prop('src', URL.createObjectURL(stream))
    , (error) -> 
      console.log(error)

class PeerModel extends Backbone.Model
  initialize: () ->
    console.log("testing2")

  fetchFacebookData: () ->
    @checkFacebookLoginStatus()

  checkFacebookLoginStatus: () ->
    $this = @
    FB.getLoginStatus (response) ->
      if response.status == "connected"
        $this.getPeerId()
        FB.api '/me/picture',{height: 200, width: 200, type: 'square'}, (response) ->
          $this.set 'dp', response.data.url

  getPeerId: () ->
    @peer = new Peer({host: 'localhost', port: 3000, path: '/peer', debug: 3})
    @peer.on 'open', (id) ->
      console.log("peer id is" + id)
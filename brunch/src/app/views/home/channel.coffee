
class exports.HomeView extends Backbone.View

  render: =>
    app.sidebar.render()

  show: =>
    @render()
    app.sidebar.moveIn()

  hide: =>
    app.sidebar.moveOut()



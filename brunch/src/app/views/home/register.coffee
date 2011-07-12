class exports.RegisterView extends Backbone.View
  template : require("templates/home/register")
  initialize : ->

  render : ->
    @el.html do @template
    console.log do @template
    do @after_render
    @el

  after_render : ->
    console.log $('#home_register_submit').length


  finish_view : =>
    @$('.loading').remove()
    @$('#home_register_submit').show()
    @el.fadeOut "slow", -> $(this).remove()
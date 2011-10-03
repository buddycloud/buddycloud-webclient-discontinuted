
class exports.AffiliationStore extends Backbone.Collection
    constructor: (@user) ->
        throw "death"
        @localStorage = new Store("#{@user.get 'jid'}-affiliations")
        app.debug "nr of #{@user.get 'jid'} affiliations in cache: #{@localStorage.records.length}"
        super()

    get: (id, everything) ->
        throw "death"
        return super(id) if everything
        super(id)?.get('value')

    update: (id, value) ->
        throw "death"
        @get(id,yes)?.set({value}) or @create({id, value})
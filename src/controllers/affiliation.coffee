
userspeak =
    'owner':    "Producer"
    'moderator':"Moderator"
    'publisher':"Follower+Post"
    'member':   "Follower"
    'outcast':  "Banned"
    'none':     "Does not follow back"

class_map =
    'owner':    "moderator"
    'moderator':"moderator"
    'publisher':"followerPlus"
    'member':   "follower"
    'outcast':  "none"
    'none':     "none"

affiliations_map =
    'moderator': 'moderator'
    'publisher': 'followerPlus'
    'member':    'follower'
reversed_affiliations_map = {}
reversed_affiliations_map[v] = k for k,v of affiliations_map


validate = (affiliation) ->
    if reversed_affiliations_map[affiliation]
        # when we get the affiliation from the ui, its named weird,
        #  so transform it back to the xmpp naming
        affiliation = reversed_affiliations_map[affiliation]
    unless class_map[affiliation]?
        # we did shit
        throw new Error "This bloody affiliation doesn't exists! → #{affiliation}"
    return affiliation


module.exports = {
    userspeak
    class_map
    affiliations_map
    reversed_affiliations_map
    validate
}

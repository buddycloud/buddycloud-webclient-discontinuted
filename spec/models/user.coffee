describe 'user', ->

  window.Channels = new ChannelCollection
  
  it 'should have a channel', ->
    u = new User { jid : 'ben@ben.com' }
    expect(u.notFound()).toBeFalsy()

    u.getChannel().status = 404
    expect(u.notFound()).toBeTruthy()

    u.getChannel().status = 200
    expect(u.notFound()).toBeFalsy()
    
  it 'should have mood', ->
    u = new User { jid : 'ben@ben.com' }
    expect(u.getMood()).toBeFalsy()

    u.set { mood : 'Charming' }
    expect(u.getMood()).toEqual('Charming')
    

  xml = parse '''<iq from='maitred.buddycloud.com' to='ben@diaspora-x.com/40174474221303280376212089' id='3623:sendIQ' type='result' xml:lang='en-GB'><query xmlns='http://buddycloud.com/protocol/channels'><items id='simon@buddycloud.com' var='member'><item><id>/channel/faq</id><title>Frequently Asked Questions</title><description>Buddycloud FAQ & tips. This channel is read-only!</description><rank>11</rank></item><item><id>/channel/arabichelp</id><title>Arabic help</title><description>من أجل المساعدة في  هذا البرنامج باللغة العربية</description><rank>40</rank></item><item><id>/channel/awesome</id><title>Awesome</title><description>100% awesome.</description><rank>85</rank></item><item><id>/channel/cacloudheadsanonymous</id><title>CA - Cloudheads Anonymous NG</title><description>You know, you are a BC addict, when...</description><rank>91</rank></item><item><id>/channel/quotable-quotes</id><title>Quotable quotes</title><description>Quotes & statuses we love!</description><rank>234</rank></item><item><id>/channel/buddycloudhilfe</id><title>Buddycloud Hilfe</title><description>Du hast Fragen zu buddycloud oder ein Problem? Hier findest du eine Antwort</description><rank>252</rank></item><item><id>/channel/spycodes</id><title>Spy Codes</title><description>To make and teach secret codes</description><rank>528</rank></item><item><id>/channel/spam</id><title>spam</title><rank>972</rank></item><item><id>/channel/lagtest</id><title>Lagtest</title><description>here we test the lag of the connection...</description><rank>1458</rank></item><item><id>/channel/oktoberfest</id><title>Oktoberfest</title><description>o'zapft is</description><rank>1469</rank></item><item><id>/channel/nokia-in-jeju</id><title>nokia in 제주</title><description>노키아 제주사용자 오세요!!</description><rank>1573</rank></item><item><id>/channel/breakfast</id><title>Breakfast</title><description>commentary on the best meal of the day.</description><rank>1807</rank></item><item><id>/channel/private-channel</id><title>Private channel</title><description>...just for member only...</description><rank>1977</rank></item><item><id>/channel/politics</id><title>politics</title><rank>2421</rank></item><item><id>/channel/simonspoppsychologychannel</id><title>Simon's pop-psychology channel</title><description>popular psychology posts</description><rank>3816</rank></item><item><id>/channel/avatar</id><title>AVATAR</title><description>Is life on earth boring sitting with a cell in a couch getting fat? Well experience Pandora while you're waiting for the skiis you ordered. But don't forget to tell how the skii trip was</description><rank>9073</rank></item><item><id>/channel/uba</id><title>익산사랑</title><description>대화</description><rank>10208</rank></item><item><id>/channel/random-facts</id><title>Random Facts</title><description>Stating stuff pple dont kno about so they kno ur smart ;)</description><rank>20286</rank></item></items></query></iq>'''